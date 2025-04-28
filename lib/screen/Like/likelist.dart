import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Post/post_rental.dart';
import '../Chat/chatlist.dart';
import '../Home/home.dart';
import '../MyPage/mypage.dart';
import '../Notification/notification.dart';
import '../Post/post_request.dart';
import '../Search/search.dart';
import '../Point/point_first.dart';

class LikeScreen extends StatefulWidget {
  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  int _selectedIndex = 1;
  List<Map<String, dynamic>> likedItems = [];
  String? studentNum;

  @override
  void initState() {
    super.initState();
    loadLikedItems();
  }

  Future<void> loadLikedItems() async {
    final prefs = await SharedPreferences.getInstance();
    studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final res = await http
        .get(Uri.parse('http://10.0.2.2:8080/likes/student/$studentNum'));

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      likedItems = data
          .map((e) => {
                'id': e['rentalItemId'],
                'title': e['rentalItemTitle'],
                'description': e['rentalItemDescription'],
                'imageUrl': 'assets/box.png',
              })
          .toList();
      setState(() {});
    } else {
      print('❌ 찜 목록 불러오기 실패');
    }
  }

  Future<void> toggleLike(int rentalItemId) async {
    if (studentNum == null) return;

    final url = Uri.parse(
        'http://10.0.2.2:8080/likes?studentNum=$studentNum&rentalItemId=$rentalItemId');
    final res = await http.post(url);

    if (res.statusCode == 200) {
      setState(() {
        likedItems.removeWhere((item) => item['id'] == rentalItemId);
      });
    } else {
      print('❌ 좋아요 취소 실패');
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => PointScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatScreen()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MypageScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Column(
          children: [
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
                                  builder: (context) => NotificationScreen()));
                        },
                      ),
                      Text('관심 목록',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.search),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),
            Expanded(
              child: likedItems.isEmpty
                  ? Center(
                      child: Text('찜한 항목이 없습니다.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: likedItems.length,
                      itemBuilder: (context, index) {
                        final item = likedItems[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PostRentalScreen(itemId: item['id']),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  // 상세페이지 이동
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PostRentalScreen(
                                            itemId: item['id']),
                                      ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // 이미지
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Color(0xffEBEBEB),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.asset(
                                            item['imageUrl'],
                                            width: 110,
                                            height: 110,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      // 제목/설명/하트
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start, // 텍스트 위로 정렬
                                          children: [
                                            // 왼쪽 (제목 + 설명)
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['title'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    item['description'],
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // 오른쪽 (좋아요 + 3시간 전)
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                height: 90, // 아이템 높이랑 비슷하게 맞춰주자
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        toggleLike(item['id']);
                                                      },
                                                      child: Icon(
                                                          Icons.favorite,
                                                          size: 30,
                                                          color: Colors.red),
                                                    ),
                                                    Text('3시간 전',
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
    );
  }
}
