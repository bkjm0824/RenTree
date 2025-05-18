import 'package:flutter/material.dart';
import 'package:rentree/screen/Point/point_first.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Chat/chatlist.dart';
import 'dart:convert';
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
  List<Map<String, String>> rankingList = [];

  Future<void> _loadRankingList() async {
    final url = Uri.parse('http://10.0.2.2:8080/Rentree/students');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        // 렌탈카운트 내림차순 정렬
        data.sort(
            (a, b) => (b['rentalCount'] ?? 0).compareTo(a['rentalCount'] ?? 0));

        // 전체 학생을 rankingList에 매핑
        setState(() {
          rankingList = List.generate(data.length, (index) {
            final item = data[index];
            return {
              "rank": (index + 1).toString(),
              "name": item["nickname"] ?? "익명",
              "count": item["rentalCount"].toString(),
              "profileImage": item["profileImage"].toString(),
            };
          });
        });
      } else {
        print("❌ 서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 랭킹 불러오기 실패: $e");
    }
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

  Future<void> _deductPoint(String studentNum, int cost) async {
    final url = Uri.parse(
        'http://10.0.2.2:8080/Rentree/students/rental-point?studentNum=$studentNum&rentalPoint=$cost');
    final response = await http.patch(url);

    if (response.statusCode == 200) {
      print('✅ 포인트 차감 성공');
    } else {
      print('❌ 포인트 차감 실패: ${response.body}');
    }
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
  void initState() {
    super.initState();
    _loadMyPoint(); // ✅ 이거 반드시 필요!
    _loadRankingList();
  }

  Future<void> _loadMyPoint() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final url = Uri.parse('http://10.0.2.2:8080/Rentree/students');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final prefs = await SharedPreferences.getInstance();
      final studentNum = prefs.getString('studentNum');

      final me = data.firstWhere((e) => e['studentNum'] == studentNum,
          orElse: () => null);
      if (me != null) {
        setState(() {
          _myPoint = me['rentalPoint'] ?? 0;
        });
      }
    }
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
                                        text: '내 상추 : ',
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
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '이달의 대여왕 ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    height: 1.57,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Image.asset(
                                  'assets/clover.png',
                                  width: 16,
                                  height: 16,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 320,
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
                                  // podium 위 아이콘들
                                  if (rankingList.length >= 3) ...[
                                    Positioned(
                                      top: 33,
                                      left: 70,
                                      child: CircleAvatar(
                                        radius: 21,
                                        backgroundImage: AssetImage(
                                          'assets/Profile/${_mapIndexToProfileFile(
                                            int.tryParse(rankingList[1]
                                                        ['profileImage'] ??
                                                    '') ??
                                                1,
                                          )}',
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 20,
                                      child: Container(
                                        padding: EdgeInsets.all(2), // 테두리 두께
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.amber,
                                              width: 2), // 황금색 테두리
                                        ),
                                        child: CircleAvatar(
                                          radius: 21,
                                          backgroundImage: AssetImage(
                                            'assets/Profile/${_mapIndexToProfileFile(
                                              int.tryParse(rankingList[0]
                                                          ['profileImage'] ??
                                                      '') ??
                                                  1,
                                            )}',
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 38,
                                      right: 70,
                                      child: CircleAvatar(
                                        radius: 21,
                                        backgroundImage: AssetImage(
                                          'assets/Profile/${_mapIndexToProfileFile(
                                            int.tryParse(rankingList[2]
                                                        ['profileImage'] ??
                                                    '') ??
                                                1,
                                          )}',
                                        ),
                                      ),
                                    ),
                                  ],

                                  Positioned(
                                      bottom: 330,
                                      child: Image.asset('assets/podium.png',
                                          width: 214, height: 44)),
                                  // 🟩 podium 밑 랭킹 출력
                                  Positioned.fill(
                                    top: 110,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 77),
                                      child: ListView.builder(
                                        itemCount: rankingList.length,
                                        itemBuilder: (context, index) {
                                          final item = rankingList[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text('${item["rank"]}등',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xff606060),
                                                            fontSize: 16)),
                                                    SizedBox(width: 10),
                                                    Text('${item["name"]}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                                Text('${item["count"]}회',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14)),
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
                            SizedBox(height: 50),
                            Text(
                              '🎁 포인트 교환소',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            _buildExchangeItem(
                                '비교과 포인트 5점', '100 상추', 'assets/clover.png'),
                            _buildExchangeItem('더베이크 아메리카노(I)', '100 상추',
                                'assets/americano.png'),
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

  Widget _buildExchangeItem(String name, String cost, String imagePath) {
    return GestureDetector(
      onTap: () {
        _showExchangeDialog(name, 100); // 100상추 차감 예시
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Image.asset(imagePath, width: 60, height: 60),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              cost,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF41B642),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExchangeDialog(String itemName, int cost) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xffF4F1F1),
          title: Text(
            '포인트 교환',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('$itemName을(를) $cost 상추로 교환하시겠습니까?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff97C663),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // 닫기
                _exchangeItem(cost); // 차감 로직 호출
              },
              child: Text('확인'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  _exchangeItem(int cost) async {
    if (_myPoint >= cost) {
      final prefs = await SharedPreferences.getInstance();
      final studentNum = prefs.getString('studentNum') ?? '';

      await _deductPoint(studentNum, cost); // 서버 반영

      setState(() {
        _myPoint -= cost;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('교환이 완료되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상추가 부족합니다.')),
      );
    }
  }
}
