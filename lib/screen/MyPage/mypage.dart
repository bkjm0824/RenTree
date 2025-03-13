// 마이페이지 화면
import 'package:flutter/material.dart';
import 'package:rentree/screen/Point/point.dart';

import '../Chat/chatlist.dart';
import '../Home/home.dart';
import '../Like/likelist.dart';
import 'mypage_profile.dart';

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
                    CurrentRentalBox(),

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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xffEBEBEB),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Color(0xff97C663),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '찜'),
          BottomNavigationBarItem(
              icon: Image(image: AssetImage('assets/sangchoo.png'), height: 40),
              label: '포인트'),
          BottomNavigationBarItem(icon: Icon(Icons.messenger_outline_rounded), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }

  // 🔹 프로필 박스
  Widget ProfileBox() {
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
          // 🔹 프로필 이미지
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/Profile/hosick.png'),
            backgroundColor: Colors.white,
          ),
          SizedBox(width: 16),

          // 🔹 이름 및 추가 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '호식이',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '2000000',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 🔹 오른쪽 화살표 아이콘
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPageProfile()), // 🔥 페이지 이동
              );
            },
          ),
        ],
      ),
    );
  }


// 🔹 현재 대여 진행 상태
  Widget CurrentRentalBox() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 5),
      padding: EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [SizedBox(width: 5), Text('내가 대여 받은 물품', style: TextStyle(fontSize: 16))]),
          SizedBox(height: 8),
          _buildRentalItem('assets/box.png', '상품 1', '3시간 10분 남음'),
          SizedBox(height: 8),
          Row(children: [SizedBox(width: 5), Text('내가 대여 해준 물품', style: TextStyle(fontSize: 16))]),
          SizedBox(height: 8),
          _buildRentalItem('assets/box.png', '상품 1', '3시간 10분 남음'),
        ],
      ),
    );
  }

// 🔹 대여 물품 아이템
  Widget _buildRentalItem(String imagePath, String title, String timeLeft) {
    return Container(
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
          CircleAvatar(radius: 40, backgroundImage: AssetImage(imagePath), backgroundColor: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(timeLeft, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
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
          _buildMenuItem('나의 게시글'),
          _buildMenuItem('대여받은 내역'),
          _buildMenuItem('대여해준 내역'),
          _buildMenuItem('나의 상추'),
          _buildMenuItem('이용 가이드'),
          _buildMenuItem('고객 지원', isLast: true), // 마지막 항목은 구분선 없음
        ],
      ),
    );
  }

  // 🔹 메뉴 항목을 생성하는 함수
  Widget _buildMenuItem(String title, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54), // 오른쪽 이동 아이콘
          onTap: () {
            // 🔥 여기에 해당 페이지로 이동하는 코드 추가
          },
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey[400]), // 마지막 항목이 아닐 때만 구분선 추가
      ],
    );
  }

}
