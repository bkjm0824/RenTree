// 마이페이지 화면
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rentree/screen/Point/point_first.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Chat/chatlist.dart';
import '../Home/home.dart';
import '../Like/likelist.dart';
import '../Notification/notification.dart';
import '../Post/post_request.dart';
import '../Search/search.dart';
import '../Point/point_second.dart';
import '../guide.dart';
import '../Post/post_rental.dart';
import 'mypage_profile.dart';
import 'mypage_mypost.dart';
import 'mypage_history.dart';
import 'mypage_customersupport.dart';
import 'mypage_userguide.dart';

class MypageScreen extends StatefulWidget {
  @override
  _MypageScreenState createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  int _selectedIndex = 4;
  String? _nickname;
  String? _studentNum;
  int? _profileImageIndex = 1;
  bool _isLoading = true;
  Map<String, dynamic>? _latestReceived;
  Map<String, dynamic>? _latestGiven;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadLatestHistories();
  }

  Future<void> _loadLatestHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final res1 = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/history/rentals/my?studentNum=$studentNum'));
    final res2 = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/history/requests/got?studentNum=$studentNum'));
    final res3 = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/history/rentals/given?studentNum=$studentNum'));
    final res4 = await http.get(Uri.parse(
        'http://10.0.2.2:8080/api/history/requests/my?studentNum=$studentNum'));

    final rentalMy = jsonDecode(utf8.decode(res1.bodyBytes));
    final requestGot = jsonDecode(utf8.decode(res2.bodyBytes));
    final rentalGiven = jsonDecode(utf8.decode(res3.bodyBytes));
    final requestMy = jsonDecode(utf8.decode(res4.bodyBytes));

    List<Map<String, dynamic>> received = [];
    List<Map<String, dynamic>> given = [];

    for (var item in rentalMy) {
      final rentalItem = item['rentalItem'];
      received.add({
        'source': 'rental',
        'id': rentalItem['id'],
        'title': rentalItem['title'],
        'description': rentalItem['description'],
        'imageUrl': await _fetchImageUrl(rentalItem['id']),
        'startTime': rentalItem['rentalStartTime'],
        'endTime': rentalItem['rentalEndTime'],
        'createdAt': rentalItem['createdAt'],
      });
    }

    for (var item in requestGot) {
      final responder = item['responder'];
      if (responder['studentNum'] == studentNum) {
        final requestItem = item['requestItem'];
        received.add({
          'source': 'request',
          'id': requestItem['id'],
          'title': requestItem['title'],
          'description': requestItem['description'],
          'imageUrl': null,
          'startTime': requestItem['rentalStartTime'],
          'endTime': requestItem['rentalEndTime'],
          'createdAt': requestItem['createdAt'],
        });
      }
    }

    for (var item in rentalGiven) {
      final rentalItem = item['rentalItem'];
      given.add({
        'source': 'rental',
        'id': rentalItem['id'],
        'title': rentalItem['title'],
        'description': rentalItem['description'],
        'imageUrl': await _fetchImageUrl(rentalItem['id']),
        'startTime': rentalItem['rentalStartTime'],
        'endTime': rentalItem['rentalEndTime'],
        'createdAt': rentalItem['createdAt'],
      });
    }

    for (var item in requestMy) {
      final requestItem = item['requestItem'];
      given.add({
        'source': 'request',
        'id': requestItem['id'],
        'title': requestItem['title'],
        'description': requestItem['description'],
        'imageUrl': null,
        'startTime': requestItem['rentalStartTime'],
        'endTime': requestItem['rentalEndTime'],
        'createdAt': requestItem['createdAt'],
      });
    }

    received.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
    given.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

    setState(() {
      _latestReceived = received.isNotEmpty ? received.first : null;
      _latestGiven = given.isNotEmpty ? given.first : null;
    });
  }

  Future<String?> _fetchImageUrl(int rentalItemId) async {
    final res = await http
        .get(Uri.parse('http://10.0.2.2:8080/images/api/item/$rentalItemId'));
    if (res.statusCode == 200) {
      final List<dynamic> images = jsonDecode(utf8.decode(res.bodyBytes));
      if (images.isNotEmpty) return images[0]['imageUrl'];
    }
    return null;
  }

  String _mapIndexToProfileFile(int index) {
    switch (index) {
      case 1:
        return 'Bugi_profile.png';
      case 2:
        return 'GgoGgu_profile.png';
      case 3:
        return 'Nyangi_profile.png';
      case 4:
        return 'Sangzzi_profile.png';
      default:
        return 'Bugi_profile.png';
    }
  }

  String formatDateTime(String dateTimeStr) {
    final dt = DateTime.parse(dateTimeStr);
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String formatTimeAgo(String dateTimeStr) {
    try {
      final createdAt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(createdAt);

      if (diff.inMinutes < 1) return '방금 전';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      return '${diff.inDays}일 전';
    } catch (e) {
      return '';
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? '사용자';
      _studentNum = prefs.getString('studentNum') ?? '학번 정보 없음'; // ← 여기 수정
      _profileImageIndex = prefs.getInt('profileImage') ?? 1;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // 홈 화면
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        // 찜 목록
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LikeScreen()),
        );
        break;
      case 2:
        // 포인트
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PointedScreen()),
        );
        break;
      case 3:
        // 채팅
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatListScreen()),
        );
        break;
      case 4:
        // 마이페이지
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MypageScreen()),
        );
        break;
      default:
        setState(() {
          _selectedIndex = index;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (알림, 검색 포함)
            Container(
              color: Color(0xffF4F1F1),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_rounded),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(left: 10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NotificationScreen()), // notification.dart에서 NotificationScreen 클래스로 변경
                          );
                        },
                      ),
                      Text(
                        '마이페이지',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SearchScreen()), // SearchScreen으로 이동
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]), // 구분선
                ],
              ),
            ),

            // 🔹 스크롤 가능 영역
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 프로필 박스
                    ProfileBox(),

                    // 현재 대여 진행 내역
                    CurrentRentalBox(context),

                    // 🔥 새로운 메뉴 박스 추가
                    MenuBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔥 하단 네비게이션 바
      bottomNavigationBar: Container(
        color: Color(0xffEBEBEB), // 배경색 유지
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
    );
  }

  Widget ProfileBox() {
    if (_isLoading) {
      return SizedBox(height: 100); // 혹은 CircularProgressIndicator()
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE6E9BA),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(
              'assets/Profile/${_mapIndexToProfileFile(_profileImageIndex ?? 1)}',
            ),
            backgroundColor: Colors.white,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nickname ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  _studentNum ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPageProfile()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget CurrentRentalBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 5),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SizedBox(width: 5),
            Text('최근 대여 받은 물품', style: TextStyle(fontSize: 16))
          ]),
          SizedBox(height: 8),
          _latestReceived != null
              ? _buildRentalItemFromData(_latestReceived!)
              : Container(
                  height: 100,
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F1F1),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '대여해준 물품이 없어요',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      )
                    ],
                  ),
                ),
          SizedBox(height: 16),
          Row(children: [
            SizedBox(width: 5),
            Text('최근 대여 해준 물품', style: TextStyle(fontSize: 16))
          ]),
          SizedBox(height: 8),
          _latestGiven != null
              ? _buildRentalItemFromData(_latestGiven!)
              : Container(
                  height: 100,
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F1F1),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '대여해준 물품이 없어요',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRentalItemFromData(Map<String, dynamic> item) {
    final imageUrl = item['imageUrl'];
    final title = item['title'] ?? '';
    final description = item['description'] ?? '';
    final start = item['startTime'];
    final end = item['endTime'];
    final type = item['source']; // ← 'type'이 아니라 'source'
    final itemId = item['id'];
    final isAvailable = item['isAvailable']; // ← 이 필드가 API에 포함되어 있어야 함

    String timeStatusText = '';
    try {
      if (end != null) {
        final endTime = DateTime.parse(end);
        final now = DateTime.now().add(Duration(hours: 9));
        final diff = now.difference(endTime);

        if (diff.isNegative) {
          // 아직 대여 중
          final left = endTime.difference(now);
          if (left.inHours > 0) {
            timeStatusText = '${left.inHours}시간 ${left.inMinutes % 60}분 남음';
          } else {
            timeStatusText = '${left.inMinutes}분 남음';
          }
        } else {
          // 대여 종료됨 → 경과 시간 표시
          if (diff.inDays > 0) {
            timeStatusText = '${diff.inDays}일 지남';
          } else if (diff.inHours > 0) {
            timeStatusText = '${diff.inHours}시간 ${diff.inMinutes % 60}분 지남';
          } else {
            timeStatusText = '${diff.inMinutes}분 지남';
          }
        }
      } else {
        timeStatusText = '대여 시간 없음';
      }
    } catch (e) {
      timeStatusText = '시간 파싱 오류';
    }

    return GestureDetector(
      onTap: () {
        if (type == 'rental') {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostRentalScreen(itemId: item['id']),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostRequestScreen(itemId: item['id']),
              ));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFFF4F1F1),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl)
                  : AssetImage('assets/requestIcon.png') as ImageProvider,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(timeStatusText,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// 🔹 대여 물품 아이템
  Widget _buildRentalItem(BuildContext context, int itemId, String imagePath,
      String title, String timeLeft, String description) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostRentalScreen(itemId: itemId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFFF4F1F1),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imagePath),
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(timeLeft,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// 🔹 메뉴 박스
  Widget MenuBox() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem('나의 게시글', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPageMypost()),
            );
          }),
          _buildMenuItem('대여 내역', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPageHistory()),
            );
          }),
          _buildMenuItem('나의 상추', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PointedScreen()),
            );
          }),
          _buildMenuItem('이용 가이드', onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GuideScreen()),
            );
          }),
          _buildMenuItem('고객 지원', isLast: true, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPageCustomerSupport()),
            );
          }), // 마지막 항목은 구분선 없음
        ],
      ),
    );
  }

  // 🔹 메뉴 항목을 생성하는 함수
  Widget _buildMenuItem(String title,
      {bool isLast = false, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          trailing:
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey[400]),
      ],
    );
  }
}
