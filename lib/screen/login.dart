import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'guide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  String? _idErrorText;
  String? _pwErrorText;

  Future<void> _login() async {
    final studentIdInput = _idController.text.trim();
    final password = _pwController.text.trim();

    setState(() {
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

      if (data['id'] != null) {
        await prefs.setInt('studentId', data['id']);
        print('✅ 저장된 studentId: ${data['id']}');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GuideScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: 아이디 또는 비밀번호 확인')),
      );
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
            ],
          ),
        ),
      ),
    );
  }
}
