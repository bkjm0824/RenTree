import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_service.dart';

class setPasswordPopup extends StatefulWidget {
  final int rentalItemId;

  const setPasswordPopup({
    Key? key,
    required this.rentalItemId,
  }) : super(key: key);

  @override
  State<setPasswordPopup> createState() => _setPasswordPopupState();
}

class _setPasswordPopupState extends State<setPasswordPopup> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  Future<void> _handleSubmit() async {
    final password = _controller.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorText = '비밀번호를 입력해주세요';
      });
      return;
    }

    // PATCH 요청만 수행
    final patchUrl = Uri.parse(
        'http://10.0.2.2:8080/rental-item/${widget.rentalItemId}/generate-password?password=$password');

    final res = await http.patch(patchUrl);

    if (res.statusCode == 200) {
      print('✅ 비밀번호 설정 성공');
      Navigator.pop(context); // 팝업 닫기
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: screenWidth * 0.8,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '대여 승인용 비밀번호 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
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
    );
  }
}
