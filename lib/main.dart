import 'package:flutter/material.dart';
import 'package:rentree/screen/chatlist.dart';
import 'package:rentree/screen/mypage.dart';
import 'package:rentree/screen/point.dart';
import 'screen/home.dart';
import 'screen/likelist.dart';
import 'screen/first.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(), // 초기 화면을 FirstScreen으로 설정
      routes: {
        '/home': (context) => HomeScreen(),
        '/Like': (context) => LikeScreen(),
        '/Point': (context) => PointScreen(),
        '/Mypage': (context) => MypageScreen(),
        '/Chat': (context) => ChatScreen(),
      },
    );
  }
}
