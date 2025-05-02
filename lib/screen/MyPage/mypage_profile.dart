import 'package:flutter/material.dart';
import 'package:rentree/screen/MyPage/mypage.dart';
import 'package:rentree/screen/MyPage/mypage_changeNM.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/home.dart';
import '../login.dart';
import 'package:http/http.dart' as http;

class MyPageProfile extends StatefulWidget {
  @override
  _MyPageProfileState createState() => _MyPageProfileState();
}

class _MyPageProfileState extends State<MyPageProfile> {
  String _nickname = '사용자';
  String _studentNum = '';
  int _profileImageIndex = 1;
  String _selectedProfileImage = 'assets/Profile/Bugi_profile.png'; // 기본 이미지
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('profileImage') ?? 1;
    setState(() {
      _nickname = prefs.getString('nickname') ?? '사용자';
      _studentNum = prefs.getString('studentNum') ?? '';
      _profileImageIndex = index;
      _selectedProfileImage = 'assets/Profile/${_mapIndexToProfileFile(index)}';
      _isLoading = false; // ✅ 데이터 로딩 완료
    });
  }

  void _showProfileImageDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xffF4F1F1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('프로필 이미지를 선택하세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                  children: List.generate(4, (index) {
                    return GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final studentNum = prefs.getString('studentNum') ?? '';

                        final res = await http.put(
                          Uri.parse('http://10.0.2.2:8080/Rentree/students/profile-image'
                              '?studentNum=$studentNum&profileImage=${index + 1}'),
                        );

                        if (res.statusCode == 200) {
                          await prefs.setInt('profileImage', index + 1);
                          setState(() {
                            _profileImageIndex = index + 1;
                            _selectedProfileImage = 'assets/Profile/${_mapIndexToProfileFile(index + 1)}'; // 이 줄 추가!
                          });
                          Navigator.pop(context);
                        } else {
                          print("❌ 프로필 이미지 업데이트 실패");
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/Profile/${_mapIndexToProfileFile(index + 1)}'),
                        backgroundColor: Colors.grey[200],
                      ),
                    );
                  }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // ✅ 로딩 중이면 스피너 표시
            : Column(
          children: [
            // 상단바
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
                            MaterialPageRoute(builder: (context) => MypageScreen()),
                          );
                        },
                      ),
                      Text('내 정보',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.home),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
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

            // 상세 정보 박스
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
                        backgroundImage: AssetImage(_selectedProfileImage),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nickname,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('학번: $_studentNum',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700])),
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
                          onPressed: _showProfileImageDialog,
                          child: Text('프로필 이미지 변경',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 12)),
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
                              style: TextStyle(
                                  color: Colors.black, fontSize: 12)),
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
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.clear();
                                    Navigator.pushAndRemoveUntil(
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
                                  child: Text('확인',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
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
