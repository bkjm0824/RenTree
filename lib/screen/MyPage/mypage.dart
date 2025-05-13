// 마이페이지 화면
import 'package:flutter/material.dart';
import 'package:rentree/screen/Point/point_first.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Chat/chatlist.dart';
import '../Home/home.dart';
import '../Like/likelist.dart';
import '../Notification/notification.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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

// 🔹 현재 대여 진행 상태
  Widget CurrentRentalBox(BuildContext context) {
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
          Row(children: [
            SizedBox(width: 5),
            Text('내가 대여 받은 물품', style: TextStyle(fontSize: 16))
          ]),
          SizedBox(height: 8),
          _buildRentalItem(
            context,
            1,
            'assets/box.png',
            '상품 1',
            '3시간 10분 남음',
            '상품 1에 대한 설명입니다.',
          ),
          SizedBox(height: 8),
          Row(children: [
            SizedBox(width: 5),
            Text('내가 대여 해준 물품', style: TextStyle(fontSize: 16))
          ]),
          SizedBox(height: 8),
          _buildRentalItem(
            context,
            2,
            'assets/box.png',
            '상품 2',
            '5시간 20분 남음',
            '상품 2에 대한 설명입니다.',
          ),
        ],
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
