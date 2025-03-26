// 대여해준 내역
import 'package:flutter/material.dart';
import '../Home/home.dart';
import '../post.dart';

class MyPageHistory2 extends StatefulWidget {
  @override
  _MyPageHistory2State createState() => _MyPageHistory2State();
}

class _MyPageHistory2State extends State<MyPageHistory2> {
  int selectedTabIndex = 0; // 0: 대여중, 1: 대여완료
  
  // 더미 데이터
  List<String> rentalInProgressList = ['상품 A', '상품 B']; // 예시: 2개
  List<String> rentalCompletedList = ['상품 C']; // 예시: 1개

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
                        '대여해준 내역',
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
                  SizedBox(height: 30),
                ],
              ),
            ),

            // 🔹 탭 영역
            Container(
              height: 50,
              child: Row(
                children: [
                  _buildTab('대여중', 0, rentalInProgressList.length),
                  _buildTab('대여완료', 1, rentalCompletedList.length),
                ],
              ),
            ),
            Container(height: 1, color: Colors.grey[300]), // 구분선

            // 🔹 리스트뷰
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: selectedTabIndex == 0
                    ? rentalInProgressList.length
                    : rentalCompletedList.length,
                itemBuilder: (context, index) {
                  final item = selectedTabIndex == 0
                      ? rentalInProgressList[index]
                      : rentalCompletedList[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreen(
                            title: item,
                            description: '$item 설명',
                            imageUrl: 'assets/box.png',
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
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16)),
                                    SizedBox(height: 4),
                                    Text(
                                      selectedTabIndex == 0 ? '대여중 상태' : '반납 완료됨',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 탭 위젯
  Widget _buildTab(String text, int index, int count) {
    final isSelected = selectedTabIndex == index;
    String displayText = '$text $count';

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              displayText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Color(0xff97C663) : Colors.grey,
              ),
            ),
            SizedBox(height: 6),
            Container(
              height: 2,
              color: isSelected ? Color(0xff97C663) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
