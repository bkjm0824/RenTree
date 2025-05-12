import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentree/screen/nickname.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  String? _idErrorText;
  String? _pwErrorText;
  bool _loginAttempted = false;
  bool _invalidCredentials = false;

  Future<void> _login() async {
    final studentIdInput = _idController.text.trim();
    final password = _pwController.text.trim();

    setState(() {
      _loginAttempted = true;
      _invalidCredentials = false;

      _idErrorText = studentIdInput.isEmpty ? '학번을 입력해주세요.' : null;
      _pwErrorText = password.isEmpty ? '비밀번호를 입력해주세요.' : null;
    });

    if (_idErrorText != null || _pwErrorText != null) return;

    final url = Uri.parse('http://10.0.2.2:8080/Rentree/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentNum': studentIdInput, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      final studentId = data['id'];
      final nickname = data['nickname'] ?? '1';
      final studentNum = studentIdInput;
      final profileImage = data['profileImage'];
      print('🎯 받은 프로필 이미지 값: $profileImage');
      if (profileImage != null) {
        await prefs.setInt('profileImage', profileImage);
      } else {
        print('❌ 서버 응답에 profileImage가 없음!');
      }
      final rentalCount = data['rentalCount'];
      if (rentalCount != null) {
        await prefs.setInt('rentalCount', rentalCount);
        print('📦 저장된 rentalCount: $rentalCount');
      }

      if (studentId != null) {
        await prefs.setInt('studentId', studentId);
        await prefs.setString('studentNum', studentNum);
        await prefs.setString('nickname', nickname);
        await prefs.setInt('profileImage', data['profileImage']);

        print('✅ 저장된 studentId: $studentId');
        print('✅ 저장된 nickname: $nickname');
        print('🎯 로그인 응답 데이터: $data');
      }

      if (nickname == '1') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NicknameSetupScreen()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        _invalidCredentials = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Center(child: Image.asset('assets/loginLogo.png')),
              SizedBox(height: 40),
              Center(
                child: Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff464646),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Text('학번',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              TextField(
                controller: _idController,
                textInputAction: TextInputAction.next,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorText: _idErrorText,
                ),
              ),
              SizedBox(height: 35),
              Text('비밀번호',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              TextField(
                controller: _pwController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xff8A8282)),
                  ),
                  errorText: _pwErrorText,
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff97C663),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // ✅ 로그인 실패 시 메시지 출력
              if (_loginAttempted && _invalidCredentials) ...[
                SizedBox(height: 16),
                Center(
                  child: Text(
                    '❗ 학번 또는 비밀번호가 올바르지 않습니다. ❗',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
