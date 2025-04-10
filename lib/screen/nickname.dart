// 닉네임 초기 설정 화면
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'guide.dart';

class NicknameSetupScreen extends StatefulWidget {
  @override
  _NicknameSetupScreenState createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  String? _nicknameErrorText;

  Future<void> _saveNickname() async {
    final nickname = _nicknameController.text.trim();

    setState(() {
      _nicknameErrorText = nickname.isEmpty ? '닉네임을 입력해주세요.' : null;
    });

    if (_nicknameErrorText != null) return;

    if (nickname.length < 2 || nickname.length > 10) {
      setState(() {
        _nicknameErrorText = '닉네임은 2자 이상 10자 이하로 입력해주세요.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);

    print('✅ 저장된 닉네임: $nickname');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GuideScreen()),
    );
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
              Center(child: Image.asset('assets/loginLogo.png')), // 원하는 로고 넣기
              SizedBox(height: 40),
              Center(
                child: Text(
                  '닉네임 설정',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff464646),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Text('닉네임',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              TextField(
                controller: _nicknameController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorText: _nicknameErrorText,
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveNickname,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff97C663),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '설정 완료',
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
