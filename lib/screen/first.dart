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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/firstScreen.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
