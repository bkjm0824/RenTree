import 'package:flutter/material.dart';
import 'package:rentree/screen/Point/point_first.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Chat/chatlist.dart';
import '../Home/addpost_give.dart';
import '../Home/home.dart';
import '../Like/likelist.dart';
import '../MyPage/mypage.dart';

class PointedScreen extends StatefulWidget {
  @override
  _PointedScreenState createState() => _PointedScreenState();
}

class _PointedScreenState extends State<PointedScreen> {
  int _selectedIndex = 2;
  int _myPoint = 0;
  final List<Map<String, String>> rankingList = [
    {"rank": "1", "name": "상상북스딱스", "points": "29"},
    {"rank": "2", "name": "호식이", "points": "27"},
    {"rank": "3", "name": "나옹이", "points": "24"},
    {"rank": "4", "name": "상추쌈", "points": "20"},
    {"rank": "5", "name": "다람쥐", "points": "18"},
    // 더 많은 데이터 추가 가능
  ];

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
  void initState() {
    super.initState();
    _loadMyPoint(); // ✅ 이거 반드시 필요!
  }

  Future<void> _loadMyPoint() async {
    final prefs = await SharedPreferences.getInstance();
    final rentalCount = prefs.getInt('rentalCount') ?? 0;
    final point = rentalCount * 20;

    print('📦 불러온 rentalCount: $rentalCount');

    if (point == 0) {
      Future.delayed(Duration.zero, () {
        showGeneralDialog(
          context: context,
          barrierLabel: "PointPopup",
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.3),
          transitionDuration: Duration(milliseconds: 600), // ⭐ 애니메이션 속도
          pageBuilder: (_, __, ___) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                child: PointScreen(), // ✅ 유지된 레이아웃
              ),
            );
          },
          transitionBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1), // 아래에서 시작
                end: Offset(0, 0), // 제자리 도착
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut, // 부드러운 효과
              )),
              child: child,
            );
          },
        );
      });
    }

    setState(() {
      _myPoint = point;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 레이아웃 변경 방지
      backgroundColor: Color(0xffF4F1F1),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 화면 터치 시 키보드 내리기
        },
        child: SafeArea(
          child: Stack(
            children: [
              // 🔹 나머지 내용은 SingleChildScrollView로 감싸서 스크롤 가능하도록 함
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // 🔹 큰 제목
                          children: [
                            SizedBox(height: 100),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '물건 대여해주고\n',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.38,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '비교과 포인트',
                                    style: TextStyle(
                                      color: Color(0xFF41B642),
                                      fontSize: 26,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.38,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 받기',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.38,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 50),
                            Container(
                              width: 217,
                              height: 207,
                              child: Image.asset('assets/sangchoo.png'),
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '현재 보유 상추 : ',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.38,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$_myPoint',
                                        style: TextStyle(
                                          color: Color(0xFF41B642),
                                          fontSize: 30,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.38,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '/500',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.38,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '이달의 대여왕 ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    height: 1.57,
                                  ),
                                ),
                                Image.asset(
                                  'assets/clover.png',
                                  width: 16,
                                  height: 16,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 300,
                              height: 430,
                              decoration: ShapeDecoration(
                                color: Color(0xFFD3D3D3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 2등 (왼쪽) - 중간 높이
                                  Positioned(
                                    top: 41, // 높이 조정
                                    left: 62,
                                    child: Icon(Icons.account_circle,
                                        size: 38, color: Colors.grey),
                                  ),

                                  // 1등 (가운데) - 가장 높은 위치
                                  Positioned(
                                    top: 28, // 가장 높게 배치
                                    child: Icon(Icons.account_circle,
                                        size: 38, color: Colors.amber),
                                  ),

                                  // 3등 (오른쪽) - 중간 높이
                                  Positioned(
                                    top: 46, // 높이 조정
                                    right: 62,
                                    child: Icon(Icons.account_circle,
                                        size: 38, color: Colors.grey),
                                  ),

                                  // podium 이미지가 일부 아이콘을 가리도록 배치
                                  Positioned(
                                    bottom: 330,
                                    child: Image.asset(
                                      'assets/podium.png',
                                      width: 214,
                                      height: 44,
                                    ),
                                  ),

                                  Center(
                                    // 컨테이너를 가운데 정렬
                                    child: Container(
                                      width: 180, // 컨테이너 가로 크기 제한
                                      height: 200, // 크기 조정 가능
                                      child: ListView.builder(
                                        itemCount: rankingList.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween, // 왼쪽과 오른쪽 정렬
                                              children: [
                                                Text(
                                                  '${rankingList[index]["rank"]}등 ${rankingList[index]["name"]}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '${rankingList[index]["points"]}회',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 전체 화면 왼쪽 상단에 뒤로가기 버튼 배치
              Positioned(
                top: 10,
                left: 10, // 왼쪽 상단에 위치
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 35,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 하단 네비게이션 바
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
}
