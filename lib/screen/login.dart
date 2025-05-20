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

      if (profileImage != null) {
        await prefs.setInt('profileImage', profileImage);
      }
      if (data['rentalCount'] != null) {
        await prefs.setInt('rentalCount', data['rentalCount']);
      }

      if (studentId != null) {
        await prefs.setInt('studentId', studentId);
        await prefs.setString('studentNum', studentNum);
        await prefs.setString('nickname', nickname);
        await prefs.setInt('profileImage', data['profileImage']);
        await prefs.setString('accountPassword', password);
      }

      // ✅ 페널티 점수 확인
      final penaltyResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080/penalties/$studentNum'),
      );

      if (penaltyResponse.statusCode == 200) {
        final penaltyData = jsonDecode(utf8.decode(penaltyResponse.bodyBytes));
        final isBanned = penaltyData['banned'];
        final penaltyScore = penaltyData['penaltyScore'];

        if (isBanned == true || penaltyScore >= 3) {
          // ⚠️ 정지 안내 팝업
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("계정 정지 안내"),
              content: Text("페널티 누적으로 계정이 일시 정지되어 로그인할 수 없습니다."),
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
                  },
                  child: Text('확인'),
                ),
              ],
            ),
          );

          // 로그아웃 처리
          await prefs.clear();

          return; // 홈으로 이동하지 않음
        }
      }

      // ✅ 닉네임 설정 여부 확인 후 이동
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
