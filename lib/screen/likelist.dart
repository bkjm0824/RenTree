// 관심 목록 화면
import 'package:flutter/material.dart';
import 'package:rentree/screen/point.dart';

import 'chatlist.dart';
import 'home.dart';
import 'mypage.dart';
import 'post.dart';

class LikeScreen extends StatefulWidget {
  @override
  _LikeScreenState createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  int _selectedIndex = 1;

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
          MaterialPageRoute(builder: (context) => PointScreen()),
        );
        break;
      case 3:
        // 채팅
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
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

  // 🔥 리스트뷰에서 아이템 클릭 시 물품 상세 페이지로 이동
  void _navigateToPostScreen(String title, String description, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          title: title,
          description: description,
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: Column(
        children: [
          Container(
            color: Color(0xffF4F1F1), // 배경색 고정
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(
              children: [
                SizedBox(height: 20), // 상단 여백
                Text(
                  '관심목록',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10), // 상단 여백
                Container(height: 1, color: Colors.grey[300]), // 구분선
              ],
            ),
          ),

          // 🔥 리스트뷰
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 2,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // 해당 아이템 클릭 시 상세 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostScreen(
                          title: '상품 ${index + 1}', // 제목
                          description: '상품 설명 ${index + 1}', // 설명
                          imageUrl: 'assets/box.png', // 이미지 URL
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/box.png',
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '상품 ${index + 1}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text('상품 설명 ${index + 1}',
                                      style: TextStyle(color: Colors.grey[700])),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.favorite_border,
                                              size: 20, color: Colors.red),
                                          SizedBox(width: 5),
                                          Text('좋아요'),
                                        ],
                                      ),
                                      Text('3시간 전',
                                          style: TextStyle(color: Colors.grey)),
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
            ),
          )
        ],
      ),

      // 🔥 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xffEBEBEB),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Color(0xff97C663), // 선택된 아이템 색상 변경
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '찜'),
          BottomNavigationBarItem(
              icon: Image(image: AssetImage('assets/sangchoo.png'), height: 40),
              label: '포인트'),
          BottomNavigationBarItem(
              icon: Icon(Icons.messenger_outline_rounded), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
