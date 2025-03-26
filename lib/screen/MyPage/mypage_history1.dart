// 대여받은 내역
import 'package:flutter/material.dart';

import '../Home/home.dart';
import '../post.dart';

class MyPageHistory1 extends StatelessWidget {
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
                        '대여받은 내역',
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

            // 🔥 리스트뷰
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // 해당 아이템 클릭 시 상세 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreen(
                            title: '상품 ${index + 1}', // 제목
                            description: '상품 설명 ${index + 1}', // 설명
                            imageUrl: 'assets/box.png', // 이미지 URL
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/box.png',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported,
                                          color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '상품 ${index + 1}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text('상품 설명 ${index + 1}',
                                        style:
                                        TextStyle(color: Colors.grey[700])),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.favorite_border,
                                                size: 20, color: Colors.red),
                                            SizedBox(width: 5),
                                            Text('좋아요'),
                                          ],
                                        ),
                                        Text('3시간 전',
                                            style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                      ],
                    ),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}