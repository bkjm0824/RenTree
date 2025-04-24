import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<List<Map<String, dynamic>>> fetchItemsWithImage() async {
    final res = await http.get(Uri.parse('http://10.0.2.2:8080/home/items'));

    if (res.statusCode == 204) {
      print('✅ 데이터 없음: 빈 리스트 반환');
      return [];
    } else if (res.statusCode != 200) {
      print('❌ 서버 응답 실패: ${res.statusCode}');
      print('❌ 응답 본문: ${res.body}');
      throw Exception('불러오기 실패');
    }

    final items = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(res.bodyBytes)));

    // type 태그 붙이기 (서버에서 이미 itemType으로 구분해주고 있을 것)
    final rentalItems = items
        .where((item) => item['itemType'] == 'RENTAL')
        .map((item) => {...item, 'type': 'rental'})
        .toList();

    final requestItems = items
        .where((item) => item['itemType'] == 'REQUEST')
        .map((item) => {...item, 'type': 'request'})
        .toList();

    // rental만 이미지 붙이기
    for (var item in rentalItems) {
      final itemId = item['id'];

      final imageRes = await http.get(Uri.parse('http://10.0.2.2:8080/images/api/$itemId'));
      if (imageRes.statusCode == 200) {
        final images = jsonDecode(utf8.decode(imageRes.bodyBytes));
        if (images.isNotEmpty) {
          item['imageUrl'] = 'http://10.0.2.2:8080${images[0]['imageUrl']}';
        } else {
          print('❌ ${item['title']} - 이미지 없음');
        }
      } else {
        print('❗${item['title']} - 이미지 요청 실패: ${imageRes.statusCode}');
      }
    }

    final allItems = [...rentalItems, ...requestItems];
    allItems.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

    return allItems;
  }



  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => LikeScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => PointedScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => MypageScreen()));
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
              child: Text("대여 요청하기", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              child: Text("물품 등록하기", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationScreen())),
                    ),
                    Image.asset('assets/rentree.png', height: 40),
                    IconButton(
                      icon: Icon(Icons.search),
                      color: Color(0xff97C663),
                      iconSize: 30,
                      padding: EdgeInsets.only(right: 10),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen())),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(height: 1, color: Colors.grey[300]),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchItemsWithImage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('에러 발생: ${snapshot.error}'));
                } else if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      '아직 글이 등록되지 않았습니다',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                } else {
                  final items = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final imageUrl = item['imageUrl'];

                      return GestureDetector(
                        onTap: () {
                          if (item['type'] == 'rental') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostRentalScreen(itemId: item['id']),
                              ),
                            );
                          } else if (item['type'] == 'request') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PostRequestScreen(itemId: item['id']),
                              ),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                children: [
                                  if (item['type'] == 'rental')
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: imageUrl != null && imageUrl.toString().isNotEmpty
                                          ? Image.network(
                                        imageUrl,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('❗ 이미지 로딩 실패: $imageUrl');
                                          print('❗ 에러: $error');
                                          return Image.asset(
                                            'assets/box.png',
                                            width: 110,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                          : Image.asset(
                                        'assets/box.png',
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (item['type'] == 'rental') SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(height: 4),
                                        Text(item['description'], style: TextStyle(color: Colors.grey[700])),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.favorite_border, size: 20, color: Colors.red),
                                                SizedBox(width: 5),
                                                Text('좋아요'),
                                              ],
                                            ),
                                            Text('3시간 전', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
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
                  );
                }
              },
            ),
          )
        ],
      ),

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

      floatingActionButton: FloatingActionButton(
        onPressed: _showWriteScreen,
        backgroundColor: Color(0xff97C663),
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}