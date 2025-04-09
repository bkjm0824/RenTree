// 시작 로딩 화면
import 'package:flutter/material.dart';
import 'dart:async';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 3초 후에 LoginScreen으로 이동
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/rentree.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}