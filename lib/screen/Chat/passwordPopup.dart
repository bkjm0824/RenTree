import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class passwordPopup extends StatefulWidget {
  final int rentalItemId;
  final String type; // 'rental' 또는 'request'

  const passwordPopup({
    Key? key,
    required this.rentalItemId,
    required this.type,
  }) : super(key: key);

  @override
  State<passwordPopup> createState() => _passwordPopupState();
}

class _passwordPopupState extends State<passwordPopup> {
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;
  bool _isVerified = false;
  String? _lockerPassword;

  Future<void> _submit() async {
    final input = _passwordController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _errorText = '비밀번호를 입력하세요';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('accountPassword');

    if (input == saved) {
      final endpoint = widget.type == 'request' ? 'ItemRequest' : 'rental-item';

      final res = await http.get(Uri.parse(
          'http://10.0.2.2:8080/$endpoint/${widget.rentalItemId}/password'));

      if (res.statusCode == 200) {
        final password = utf8.decode(res.bodyBytes).trim();

        setState(() {
          _errorText = null;
          _isVerified = true;
          _lockerPassword = password;
        });
      } else {
        print('❌ 비밀번호 조회 실패: ${res.statusCode}');
        setState(() {
          _errorText = '사물함 비밀번호를 가져오지 못했습니다';
        });
      }
    } else {
      setState(() {
        _errorText = '비밀번호가 일치하지 않습니다';
      });
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
              _isVerified ? '🔓 사물함 비밀번호' : '계정 비밀번호 입력',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (_isVerified)
              Text(
                _lockerPassword ?? '비밀번호 없음',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6DB129),
                ),
              )
            else ...[
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호',
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff6DB129),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
