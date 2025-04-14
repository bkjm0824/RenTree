import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'mypage_profile.dart';

class NickNameScreen extends StatefulWidget {
  @override
  _NickNameScreenState createState() => _NickNameScreenState();
}

class _NickNameScreenState extends State<NickNameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String? currentNickname;
  bool _submitted = false;
  String? _nicknameErrorText;

  @override
  void initState() {
    super.initState();
    _loadCurrentNickname();
  }

  Future<void> _loadCurrentNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('nickname') ?? '';
    setState(() {
      currentNickname = saved;
    });
  }

  Future<void> _submit() async {
    final nickname = _nicknameController.text.trim();
    setState(() {
      _submitted = true;
      _nicknameErrorText =
          isValidNickname(nickname) ? null : '닉네임은 2~10자의 한글 또는 영문만 사용할 수 있어요.';
    });

    if (_nicknameErrorText != null) return;

    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');

    if (studentNum == null) {
      setState(() {
        _nicknameErrorText = '로그인 정보를 찾을 수 없습니다.';
      });
      return;
    }

    // ✅ 서버 요청
    final url = Uri.parse('http://10.0.2.2:8080/Rentree/nickname/$studentNum');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nickname': nickname}),
    );

    if (response.statusCode == 200) {
      // ✅ SharedPreferences 갱신
      await prefs.setString('nickname', nickname);

      setState(() {
        currentNickname = nickname;
      });

      // ✅ 마이페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPageProfile()),
      );
    } else {
      setState(() {
        _nicknameErrorText = '서버 오류가 발생했습니다. (${response.statusCode})';
      });
    }
  }

  bool isValidNickname(String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.length < 2 || trimmed.length > 10) return false;
    final regex = RegExp(r'^[a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣]+$');
    return regex.hasMatch(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(40, 80, 40, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Center(
                    child: Text(
                      '닉네임 변경',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff464646),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Text('변경 전 닉네임',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currentNickname ?? '',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 35),
                  Text('변경 후 닉네임',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _nicknameController,
                      textInputAction: TextInputAction.done,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '2~10자의 한글 또는 영문 닉네임',
                        hintStyle: TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Color(0xffD9D9D9),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _submitted ? _nicknameErrorText : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff97C663),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '닉네임 변경하기',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔙 뒤로가기
            Positioned(
              top: 10,
              left: 0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 30,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
