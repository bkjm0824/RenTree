// 마이페이지 화면
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Chat/chatlist.dart';
import '../Home/home.dart';
import '../Like/likelist.dart';
import '../Post/post_request.dart';
import '../Search/search.dart';
import '../Point/point_second.dart';
import '../Post/post_rental.dart';
import 'mypage_profile.dart';
import 'mypage_mypost.dart';
import 'mypage_history.dart';
import 'mypage_customersupport.dart';
import 'mypage_userguide.dart';
import '../login.dart';

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
  int _penaltyScore = 0;

  @override
  void initState() {
    super.initState();
    checkPenaltyAndForceLogout(context);
    _loadUserInfo();
    _loadLatestHistories();
    _loadPenaltyScore();
  }

  Future<void> checkPenaltyAndForceLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final response = await http.get(
      Uri.parse('http://54.79.35.255:8080/penalties/$studentNum'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final isBanned = data['banned'];
      final penaltyScore = data['penaltyScore'];

      if (isBanned == true || penaltyScore >= 3) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Row(
              children: [
                Text("계정 정지 안내", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Image.asset(
                  'assets/redCard.png', // ← 경로 확인 필수
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            content: Text("페널티 누적으로 계정이 정지되었습니다.\n로그아웃 후 로그인 화면으로 이동합니다."),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  Navigator.of(context).pop(); // 팝업 먼저 닫고

                  // pop 이후 반드시 context mounted 체크
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _loadPenaltyScore() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final response = await http.get(
      Uri.parse('http://54.79.35.255:8080/penalties/$studentNum'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _penaltyScore = data['penaltyScore'] ?? 0;
      });
    } else {
      print("❌ 페널티 점수 불러오기 실패");
    }
  }

  Future<void> _loadLatestHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    try {
      final resMy = await http.get(Uri.parse(
          'http://54.79.35.255:8080/api/history/rentals/my?studentNum=$studentNum'));
      final resGiven = await http.get(Uri.parse(
          'http://54.79.35.255:8080/api/history/rentals/given?studentNum=$studentNum'));
      final resRequestMy = await http.get(Uri.parse(
          'http://54.79.35.255:8080/api/history/requests/got?studentNum=$studentNum'));
      final resRequestGot = await http.get(Uri.parse(
          'http://54.79.35.255:8080/api/history/requests/my?studentNum=$studentNum'));

      final decodedMy = jsonDecode(utf8.decode(resMy.bodyBytes));
      final decodedGiven = jsonDecode(utf8.decode(resGiven.bodyBytes));
      final decodedRequestMy = jsonDecode(utf8.decode(resRequestMy.bodyBytes));
      final decodedRequestGot =
          jsonDecode(utf8.decode(resRequestGot.bodyBytes));

      final rentalMy = decodedMy is List ? decodedMy : <dynamic>[];
      final rentalGiven = decodedGiven is List ? decodedGiven : <dynamic>[];
      final requestMy =
          decodedRequestMy is List ? decodedRequestMy : <dynamic>[];
      final requestGot =
          decodedRequestGot is List ? decodedRequestGot : <dynamic>[];

      Map<String, dynamic>? latestMyItem;
      Map<String, dynamic>? latestGivenItem;

      final combinedReceived = [...rentalMy, ...requestGot]
          .map((item) {
            final data = item['rentalItem'] ?? item['requestItem'];
            final id = data['id'];
            return {
              'source': item.containsKey('rentalItem') ? 'rental' : 'request',
              'id': id is int ? id : int.tryParse(id.toString()),
              'title': data['title'],
              'description': data['description'],
              'imageUrl': null,
              'startTime': data['rentalStartTime'],
              'endTime': data['rentalEndTime'],
              'actualReturnTime': data['actualReturnTime'],
              'isAvailable': data['isAvailable'],
            };
          })
          .where((item) => item['actualReturnTime'] != null)
          .toList();

      if (combinedReceived.isNotEmpty) {
        combinedReceived.sort((a, b) => b['actualReturnTime']
            .toString()
            .compareTo(a['actualReturnTime'].toString()));
        latestMyItem = combinedReceived.first;
      }

      final combinedGiven = [...rentalGiven, ...requestMy]
          .map((item) {
            final data = item['rentalItem'] ?? item['requestItem'];
            final id = data['id'];
            return {
              'source': item.containsKey('rentalItem') ? 'rental' : 'request',
              'id': id is int ? id : int.tryParse(id.toString()),
              'title': data['title'],
              'description': data['description'],
              'imageUrl': null,
              'startTime': data['rentalStartTime'],
              'endTime': data['rentalEndTime'],
              'actualReturnTime': data['actualReturnTime'],
              'isAvailable': data['isAvailable'],
            };
          })
          .where((item) => item['actualReturnTime'] != null)
          .toList();

      if (combinedGiven.isNotEmpty) {
        combinedGiven.sort((a, b) => b['actualReturnTime']
            .toString()
            .compareTo(a['actualReturnTime'].toString()));
        latestGivenItem = combinedGiven.first;
      }

      if (latestMyItem != null && latestMyItem['source'] == 'rental') {
        final imageUrl = await _fetchImageUrl(latestMyItem['id']);
        latestMyItem['imageUrl'] = imageUrl;
      }

      if (latestGivenItem != null && latestGivenItem['source'] == 'rental') {
        final imageUrl = await _fetchImageUrl(latestGivenItem['id']);
        latestGivenItem['imageUrl'] = imageUrl;
      }

      setState(() {
        _latestReceived = latestMyItem;
        _latestGiven = latestGivenItem;
      });

      print('✅ 최신 대여 기록 세팅 완료');
    } catch (e, stack) {
      print('❌ 최신 대여 기록 로딩 실패: \$e');
      print(stack);
    }
  }

  Future<String?> _fetchImageUrl(int rentalItemId) async {
    final res = await http.get(
        Uri.parse('http://54.79.35.255:8080/images/api/item/$rentalItemId'));
    if (res.statusCode == 200) {
      final List<dynamic> images = jsonDecode(utf8.decode(res.bodyBytes));
      if (images.isNotEmpty) {
        final url = images[0]['imageUrl']?.toString();
        if (url != null && url.startsWith('/images/')) {
          return 'http://54.79.35.255:8080$url'; // 상대경로 → 절대경로로 변환
        }
      }
    }
    return null; // 절대경로이거나 잘못된 경우에는 null → box.png 사용
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
                      Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          '마이페이지',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff747A82),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchScreen()),
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
                Row(
                  children: [
                    Text(
                      _nickname ?? '',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_penaltyScore > 0 && _penaltyScore < 3)
                      Row(
                        children: List.generate(
                          _penaltyScore,
                          (_) => Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Image.asset(
                              'assets/yellowCard.png',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
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
    final end = item['endTime'];
    final type = item['source']; // ← 'type'이 아니라 'source'
    final itemId = item['id'];
    final isAvailable = item['isAvailable'];
    final actualReturnTime = item['actualReturnTime'];

    String timeStatusText = '';
    Color timeTextColor = Colors.grey[600]!;

    try {
      if (end != null) {
        final endTime = DateTime.parse(end);
        final now = DateTime.now().toUtc().add(Duration(hours: 9)); // 한국 기준
        final actualReturn = DateTime.parse(actualReturnTime);
        final isWarning = endTime.difference(actualReturn);
        if (isWarning.isNegative) {
          if (isWarning.inDays < 0) {
            timeStatusText = '${isWarning.inDays.abs()}일 늦게 반납 완료됨';
          } else if (isWarning.inHours < 0) {
            timeStatusText =
                '${isWarning.inHours.abs()}시간 ${isWarning.inMinutes.abs() % 60}분 늦게 반납 완료됨';
          } else {
            timeStatusText = '${isWarning.inMinutes.abs()}분 늦게 반납 완료됨';
          }
          timeTextColor = Colors.red;
        } else {
          timeStatusText = '반납 완료됨';
        }
      } else {
        timeStatusText = '대여 시간 없음';
      }
    } catch (e) {
      timeStatusText = '시간 파싱 오류';
    }
    ImageProvider imageProvider;
    if (type == 'request') {
      imageProvider = AssetImage('assets/requestIcon.png');
    } else if (imageUrl != null && imageUrl.toString().startsWith('http')) {
      imageProvider = NetworkImage(imageUrl);
    } else {
      imageProvider = AssetImage('assets/box.png');
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
              backgroundImage: imageProvider,
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
                  Text(
                    timeStatusText,
                    style: TextStyle(fontSize: 12, color: timeTextColor),
                  ),
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
              MaterialPageRoute(builder: (context) => MyPageUserGuide()),
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
