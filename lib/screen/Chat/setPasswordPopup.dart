import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class setPasswordPopup extends StatefulWidget {
  final int postId;
  final String type; // 'rental' 또는 'request'

  const setPasswordPopup({
    Key? key,
    required this.postId,
    required this.type,
  }) : super(key: key);

  @override
  State<setPasswordPopup> createState() => _setPasswordPopupState();
}

class _setPasswordPopupState extends State<setPasswordPopup> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  Future<void> _handleSubmit() async {
    final password = _controller.text.trim();

    // 숫자 4자리 검증
    if (password.length != 4 || int.tryParse(password) == null) {
      setState(() {
        _errorText = '숫자 4자리를 입력해주세요';
      });
      return;
    }

    final String url = widget.type == 'request'
        ? 'http://10.0.2.2:8080/ItemRequest/${widget.postId}/password?password=$password'
        : 'http://10.0.2.2:8080/rental-item/${widget.postId}/generate-password?password=$password';

    final res = await http.patch(Uri.parse(url));

    if (res.statusCode == 200) {
      print('✅ 비밀번호 설정 성공');
      Navigator.pop(context);
    } else {
      print('❌ 비밀번호 설정 실패: ${res.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 설정 실패: ${res.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 방지
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: screenWidth * 0.8,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '비밀번호 설정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.text, // 👉 키패드 원래대로
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호 입력',
                  errorText: _errorText,
                  filled: true,
                  fillColor: Color(0xffF0F0F0),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff6DB129),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('확인', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
