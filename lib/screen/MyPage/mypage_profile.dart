// 프로필 상세 화면
import 'package:flutter/material.dart';
import 'package:rentree/screen/MyPage/mypage.dart';
import 'package:rentree/screen/MyPage/mypage_changeNM.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/home.dart';
import '../login.dart';

class MyPageProfile extends StatefulWidget {
  @override
  _MyPageProfileState createState() => _MyPageProfileState();
}

class _MyPageProfileState extends State<MyPageProfile> {
  String _nickname = '사용자';
  String _studentNum = ''; // 학번 변수 추가

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname') ?? '사용자';
      _studentNum = prefs.getString('studentNum') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (뒤로가기, 홈 버튼)
            Container(
              color: Color(0xffF4F1F1),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(left: 10),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MypageScreen()),
                          );
                        },
                      ),
                      Text(
                        '내 정보',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.home),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 🔹 상세 정보 박스
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
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
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('assets/Profile/hosick.png'),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nickname,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '학번: $_studentNum',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 프로필 이미지 변경 로직
                          },
                          child: Text('프로필 이미지 변경',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEBEBEB),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NickNameScreen()),
                            );
                          },
                          child: Text('닉네임 변경',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEBEBEB),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      ListTile(
                        title: Text('회원 정보 변경'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('비밀번호 변경'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('로그아웃'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('로그아웃'),
                              content: Text('정말로 로그아웃하시겠습니까?'),
                              actions: [
                                TextButton(
                                  child: Text('취소',
                                      style: TextStyle(color: Colors.grey)),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.clear(); //공유변수 초기화
                                    Navigator.pushAndRemoveUntil(
                                      //초기화 후 로그인 화면 이동
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff97C663),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  child: Text(
                                    '확인',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
