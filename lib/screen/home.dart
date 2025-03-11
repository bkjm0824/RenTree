import 'package:flutter/material.dart';
import 'point.dart';
import 'chat.dart';
import 'like.dart';
import 'mypage.dart';
import 'post_give.dart'; // 글쓰기 화면 추가

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LikeScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PointScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
      case 4:
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

  // 🔹 글쓰기 화면 모달 열기
  void _showWriteScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 화면 크기 조정 가능
      backgroundColor: Colors.black.withOpacity(0.5), // 어두운 배경 효과
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95, // 화면의 90% 차지
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: PostGiveScreen(), // 글쓰기 화면으로 이동
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: Column(
        children: [
          Container(
            color: Color(0xffF4F1F1),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                      onPressed: () {},
                    ),
                    Image.asset('assets/rentree.png', height: 40),
                    IconButton(
                      icon: const Icon(Icons.search),
                      color: Color(0xff97C663),
                      iconSize: 30,
                      padding: EdgeInsets.only(right: 10),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(height: 1, color: Colors.grey[300]),
              ],
            ),
          ),

          // 🔥 리스트뷰
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Column(
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text('상품 설명 ${index + 1}',
                                    style: TextStyle(color: Colors.grey[700])),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                );
              },
            ),
          ),
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

      // 🔹 우측 하단 녹색 플러스 버튼 추가
      floatingActionButton: FloatingActionButton(
        onPressed: _showWriteScreen, // 글쓰기 화면으로 이동
        backgroundColor: Color(0xff97C663), // 녹색 버튼
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // 우측 하단 배치
    );
  }
}
