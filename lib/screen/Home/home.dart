import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../Point/point_first.dart';
import '../Chat/chatlist.dart';
import '../Like/likelist.dart';
import '../MyPage/mypage.dart';
import '../Point/point_second.dart';
import 'addpost_give.dart';
import 'addpost_request.dart';
import '../Post/post_rental.dart';
import '../Post/post_request.dart';
import '../Notification/notification.dart';
import '../Search/search.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedFilter = '최신순';
  List<Map<String, dynamic>> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkPenaltyAndForceLogout(context);
    fetchItemsWithImage();
  }

  Future<void> checkPenaltyAndForceLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final response = await http.get(
      Uri.parse('http://54.79.35.255:8080/penalties/$studentNum'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final isBanned = data['banned'];
      final penaltyScore = data['penaltyScore'];

      if (isBanned == true || penaltyScore >= 3) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Row(
              children: [
                Text("계정 정지 안내", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Image.asset(
                  'assets/redCard.png', // ← 경로 확인 필수
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            content: Text("페널티 누적으로 계정이 정지되었습니다.\n자동으로 로그아웃 됩니다."),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  Navigator.of(context).pop(); // 팝업 먼저 닫고

                  // pop 이후 반드시 context mounted 체크
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> fetchItemsWithImage() async {
    final res =
        await http.get(Uri.parse('http://54.79.35.255:8080/home/items'));

    if (res.statusCode == 204) {
      _allItems = [];
      setState(() {
        _isLoading = false;
      });
      return;
    } else if (res.statusCode != 200) {
      throw Exception('불러오기 실패');
    }
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');

// ✅ 추가 : 내가 누른 좋아요 목록 받아오기
    Set<int> likedRentalItemIds = {};
    if (studentNum != null) {
      final likeRes = await http
          .get(Uri.parse('http://54.79.35.255:8080/likes/student/$studentNum'));
      if (likeRes.statusCode == 200) {
        final List<dynamic> likeData =
            jsonDecode(utf8.decode(likeRes.bodyBytes));
        likedRentalItemIds =
            likeData.map<int>((e) => e['rentalItemId'] as int).toSet();
      }
    }

    final items =
        List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(res.bodyBytes)));

    final rentalItems = items
        .where((item) => item['itemType'] == 'RENTAL')
        .map((item) => {...item, 'type': 'rental'})
        .toList();
    final requestItems = items
        .where((item) => item['itemType'] == 'REQUEST')
        .map((item) => {...item, 'type': 'request'})
        .toList();

    for (var item in rentalItems) {
      final itemId = item['id'];

      final imageRes = await http
          .get(Uri.parse('http://54.79.35.255:8080/images/api/item/$itemId'));
      if (imageRes.statusCode == 200) {
        final images = jsonDecode(utf8.decode(imageRes.bodyBytes));
        if (images.isNotEmpty) {
          item['imageUrl'] = images[0]['imageUrl'];
        }
      }

      // 🔥 추가: 좋아요 여부 체크
      item['isLiked'] = likedRentalItemIds.contains(itemId);

      item['likeCount'] = await fetchLikeCount(itemId);
    }

    for (var item in requestItems) {
      item['isLiked'] = false;
    }

    setState(() {
      _allItems = [...rentalItems, ...requestItems];
      _allItems.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      _isLoading = false;
    });
  }

  Future<int> fetchLikeCount(int rentalItemId) async {
    //좋아요 수 가져오기
    final url = Uri.parse(
        'http://54.79.35.255:8080/likes/rentalItem/$rentalItemId/count');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      return int.parse(res.body);
    } else {
      print('❌ 좋아요 개수 가져오기 실패: ${res.statusCode}');
      return 0;
    }
  }

  List<Map<String, dynamic>> getFilteredItems() {
    if (_selectedFilter == '최신순') {
      return _allItems;
    } else if (_selectedFilter == '대여글') {
      return _allItems.where((item) => item['type'] == 'rental').toList();
    } else if (_selectedFilter == '요청글') {
      return _allItems.where((item) => item['type'] == 'request').toList();
    }
    return _allItems;
  }

  String formatTimeDifference(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 30) return '${diff.inDays}일 전';

    final months = diff.inDays ~/ 30;
    if (months < 12) return '${months}달 전';

    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
  }

  String formatDateTime(String dateTimeStr) {
    final dt = DateTime.parse(dateTimeStr);
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => LikeScreen()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => PointedScreen()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => ChatListScreen()));
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => MypageScreen()));
        break;
    }
  }

  void _showWriteScreen() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff97C663),
                foregroundColor: Colors.white,
                minimumSize: Size(230, 60),
              ),
              onPressed: () {
                Navigator.pop(context);
                _navigateToScreen(RequestScreen());
              },
              child: Text("대여 요청하기",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff97C663),
                foregroundColor: Colors.white,
                minimumSize: Size(230, 60),
              ),
              onPressed: () {
                Navigator.pop(context);
                _navigateToScreen(PostGiveScreen());
              },
              child: Text("물품 등록하기",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.5),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Color(0xffF4F1F1),
            child: Column(
              children: [
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_rounded),
                      color: Color(0xff97C663),
                      iconSize: 30,
                      padding: EdgeInsets.only(left: 10),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NotificationScreen())),
                    ),
                    Image.asset('assets/rentree.png', height: 40),
                    IconButton(
                        icon: Icon(Icons.search),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SearchScreen()),
                          );

                          if (result == true) {
                            await fetchItemsWithImage(); // 🔁 찜 반영 새로고침
                          }
                        }),
                  ],
                ),
                SizedBox(height: 10),
                Container(height: 1, color: Colors.grey[300]),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButton2<String>(
                  value: _selectedFilter,
                  items: ['최신순', '대여글', '요청글'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _allItems.isEmpty
                    ? Center(
                        child: Text(
                          "등록된 항목이 없습니다.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        itemCount: getFilteredItems().length,
                        itemBuilder: (context, index) {
                          final item = getFilteredItems()[index];
                          final createdAt = DateTime.parse(item['createdAt']);
                          final timeAgo = formatTimeDifference(createdAt);
                          final imageUrl = item['imageUrl'];

                          return GestureDetector(
                            onTap: () async {
                              if (item['type'] == 'rental') {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PostRentalScreen(itemId: item['id']),
                                  ),
                                );
                                await fetchItemsWithImage(); // ✅ 무조건 최신 정보로 반영
                              } else {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PostRequestScreen(itemId: item['id']),
                                  ),
                                );
                                await fetchItemsWithImage(); // ✅ 요청글도 마찬가지
                              }
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Color(0xffEBEBEB),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: item['type'] == 'rental'
                                              ? (imageUrl != null && imageUrl.toString().isNotEmpty
                                              ? Image.network(
                                            'http://54.79.35.255:8080$imageUrl',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Image.asset('assets/box.png', fit: BoxFit.cover),
                                          )
                                              : Image.asset('assets/box.png', fit: BoxFit.cover))
                                              : Image.asset('assets/requestIcon.png', fit: BoxFit.cover),
                                        )

                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item['title'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(
                                              (item['rentalStartTime'] ??
                                                          item['startTime']) ==
                                                      null
                                                  ? '양도(무료나눔)'
                                                  : '${formatDateTime(item['rentalStartTime'] ?? item['startTime'])} ~ ${formatDateTime(item['rentalEndTime'] ?? item['endTime'])}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        height: 90,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(timeAgo,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13)),
                                            Row(
                                              children: [
                                                if (item['type'] ==
                                                    'rental') ...[
                                                  Icon(
                                                    Icons.favorite,
                                                    color: Colors.grey,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                      '${item['likeCount'] ?? 0}'),
                                                ],
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(height: 1, color: Colors.grey[300]),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Color(0xffEBEBEB),
        padding: const EdgeInsets.only(bottom: 5),
        child: BottomNavigationBar(
          backgroundColor: Color(0xffEBEBEB),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Color(0xff97C663),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 27), label: '홈'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite, size: 27), label: '찜'),
            BottomNavigationBarItem(
                icon: Icon(Icons.control_point_duplicate_rounded, size: 27),
                label: '포인트'),
            BottomNavigationBarItem(
                icon: Icon(Icons.messenger_outline_rounded, size: 27),
                label: '채팅'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 27), label: '마이페이지'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showWriteScreen,
        backgroundColor: Color(0xff97C663),
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
