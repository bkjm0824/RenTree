import 'package:flutter/material.dart';
import '../Home/home.dart';

class MyPageUserGuide extends StatelessWidget {
  final bool isPopup;
  MyPageUserGuide({this.isPopup = false, Key? key}) : super(key: key);

  final List<String> imagePaths = [
    'assets/Guide/1.jpg',
    'assets/Guide/2.jpg',
    'assets/Guide/3.jpg',
    'assets/Guide/4.jpg',
    'assets/Guide/5.jpg',
    'assets/Guide/6.jpg',
    'assets/Guide/7.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final imageSection = Container(
      height: isPopup
          ? MediaQuery.of(context).size.height * 0.3 // 팝업에서는 절반 높이
          : 500, // 전체 화면에선 기존처럼 크게
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
                width: isPopup
                    ? MediaQuery.of(context).size.width * 0.5 // 팝업에서는 절반 높이
                    : 400,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );

    if (isPopup) {
      return Container(
        color: Color(0xffF4F1F1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              '물품보관소 이용가이드',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Pretender',
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16),
            imageSection,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Column(
          children: [
            // 상단바
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
                          fontFamily: 'Pretender',
                          fontWeight: FontWeight.w600,
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
            imageSection,
            SizedBox(height: 10),
            Text('사물함 관련 문의는 031-1111-1111로 문의해주세요')
          ],
        ),
      ),
    );
  }
}
