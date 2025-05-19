import 'package:flutter/material.dart';
import '../Home/home.dart';

class MyPageUserGuide extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/Guide/1.jpg',
    'assets/Guide/2.jpg',
    'assets/Guide/3.jpg',
    'assets/Guide/4.jpg',
    'assets/Guide/5.jpg',
    'assets/Guide/6.jpg',
    'assets/Guide/7.jpg',
    // 필요에 따라 더 추가
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바
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
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        '물품보관소 이용가이드',
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
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),

            SizedBox(height: 100),

            // 🔹 가로 스크롤 이미지 영역
            Container(
              height: 500, // 이미지 높이 지정
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePaths[index],
                        width: 400, // 각 이미지의 너비
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
