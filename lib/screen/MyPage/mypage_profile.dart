// 프로필 상세 화면
import 'package:flutter/material.dart';

import '../Home/home.dart';

class MyPageProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (뒤로가기, 홈 버튼)
            Container(
              color: Color(0xffF4F1F1),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(left: 10),
                        onPressed: () {
                          Navigator.pop(context); // 🔥 뒤로 가기
                        },
                      ),
                      Text(
                        '내 정보',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.home),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          ); // 🔥 홈으로 이동
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]), // 구분선
                ],
              ),
            ),

            SizedBox(height: 20), // 상단바와 정보 사이 간격

            // 🔹 상세 정보
            Container(
              margin: EdgeInsets.symmetric(horizontal: 32),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE6E9BA), // 박스 배경색
                borderRadius: BorderRadius.circular(35), // 모서리 둥글게
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🔹 프로필 사진, ID, 학번
                  Row(
                    children: [
                      // 프로필 사진
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/Profile/hosick.png'), // 프로필 이미지
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 16), // 이미지와 텍스트 간격

                      // ID & 학번
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '호식이', // 사용자 ID
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '학번: 2000000', // 학번
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20), // 프로필 정보와 버튼 사이 간격

                  // 🔹 프로필 이미지 변경 버튼과 닉네임 변경 버튼을 가로로 정렬
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 간의 간격 균등 분배
                    children: [
                      // 프로필 이미지 변경 버튼
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 프로필 이미지 변경 로직 추가
                          },
                          child: Text(
                            '프로필 이미지 변경',
                            style: TextStyle(
                              color: Colors.black, // 글씨 색상을 검은색으로 설정
                              fontSize: 12, // 글씨 크기 줄이기
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEBEBEB), // 버튼 배경색
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12), // 버튼 간 간격

                      // 닉네임 변경 버튼
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 닉네임 변경 로직 추가
                          },
                          child: Text(
                            '닉네임 변경',
                            style: TextStyle(
                              color: Colors.black, // 글씨 색상을 검은색으로 설정
                              fontSize: 12, // 글씨 크기 줄이기
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEBEBEB), // 버튼 배경색
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 🔹 리스트 메뉴
                  Column(
                    children: [
                      ListTile(
                        title: Text('회원 정보 변경'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 회원정보 변경 화면으로 이동하는 로직 추가
                        },
                      ),
                      ListTile(
                        title: Text('비밀번호 변경'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 비밀번호 변경 화면으로 이동하는 로직 추가
                        },
                      ),
                      ListTile(
                        title: Text('로그아웃'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 로그아웃 로직 추가
                        },
                      ),

                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}