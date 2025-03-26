import 'package:flutter/material.dart';
import 'package:rentree/screen/Chat/chatlist.dart';
import 'package:rentree/screen/MyPage/mypage.dart';
import 'package:rentree/screen/Point/point_first.dart';
import 'package:rentree/screen/Point/point_second.dart';
import 'package:rentree/screen/login.dart';
import 'screen/Home/home.dart';
import 'screen/Like/likelist.dart';
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
      //home: FirstScreen(), // 초기 화면을 FirstScreen으로 설정
      home: LoginScreen(), //로그인 스크린 만드느라 경로 설정
      routes: {
        '/home': (context) => HomeScreen(),
        '/Like': (context) => LikeScreen(),
        '/Point': (context) => PointedScreen(),
        '/Mypage': (context) => MypageScreen(),
        '/Chat': (context) => ChatScreen(),
      },
    );
  }
}
