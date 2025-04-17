// 물품 글 화면
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  // 생성자에서 제목, 설명, 이미지 URL 받기
  PostScreen({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (뒤로가기 버튼)
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
                        color: Color(0xff918B8B),
                        iconSize: 30,
                        padding: EdgeInsets.only(left: 10),
                        onPressed: () {
                          Navigator.pop(context); // 🔥 뒤로 가기
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            // 🔹 물품 이미지
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl, // 물품의 이미지 URL
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 250,
                      height: 250,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),

            // 🔹 상품 정보 컨테이너
            Expanded(
              child: Container(
                padding: EdgeInsets.all(36),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffE7E9C8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              AssetImage('assets/Profile/hosick.png'),
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text('작성자 : 닉네임', style: TextStyle(fontSize: 16)),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  children: [
                                    TextSpan(text: '대여 가능 시간 : 3시간 '),
                                    TextSpan(
                                        text: '|',
                                        style: TextStyle(
                                            color: Color(0xff918B8B))),
                                    TextSpan(text: ' 대면 '),
                                    TextSpan(
                                        text: '|',
                                        style: TextStyle(
                                            color: Color(0xff918B8B))),
                                    TextSpan(text: ' 2시간 전'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // ✅ 설명 박스는 Row 밖에서 전체 너비를 활용해야 하므로 여기 위치
                    Container(
                      width: double.infinity,
                      height: 150,
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          description,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 하트 아이콘과 채팅하기 버튼을 Row로 묶기
            Container(
              margin:
                  EdgeInsets.only(top: 10, bottom: 20), // 상단 여백을 줄이고 하단 여백 추가
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 하트 아이콘
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                  ),
                  // 채팅하기 버튼
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff97C663),
                      foregroundColor: Colors.white,
                      minimumSize: Size(260, 60), // 좌우 길이 조정
                    ).copyWith(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18), // 둥근 정도 줄이기
                      )),
                    ),
                    onPressed: () {
                      // 물품 대여 요청 또는 관련 액션 추가
                      // 예: Navigator.push()로 다른 화면으로 이동
                    },
                    child: Text(
                      "채팅하기", // 버튼 텍스트
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
