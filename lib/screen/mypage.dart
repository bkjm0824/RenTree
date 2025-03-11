import 'package:flutter/material.dart';
import 'package:rentree/screen/point.dart';

import 'chat.dart';
import 'home.dart';
import 'like.dart';

class MypageScreen extends StatefulWidget {
  @override
  _MypageScreenState createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  int _selectedIndex = 4;

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
                SizedBox(height: 15), // 상단 여백
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
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 10), // 상단 여백
                Container(height: 1, color: Colors.grey[300]), // 구분선
              ],
            ),
          ),
          // 프로필 박스
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFE6E9BA), // 배경색
              borderRadius: BorderRadius.circular(35), // 둥근 모서리
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
                  radius: 40, // 프로필 이미지 크기
                  backgroundImage: AssetImage('assets/Profile/hosick.png'), // 프로필 이미지
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 16), // 간격
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '호식이', // 사용자 이름
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2000000', // 이메일 또는 기타 정보
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 대여 물품 진행 내역
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32, vertical: 5),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFEBEBEB), // 박스 배경색
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(width: 20), // 🔥 텍스트 앞에 여백 추가
                    Text(
                      '내가 대여 받은 물품',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFEBEBEB), // 박스 배경색
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                )
              ],
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
    );
  }
}
