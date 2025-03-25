// 가이드 화면
import 'package:flutter/material.dart';

import 'Home/home.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> guideData = [
    {
      'image': 'assets/box.png',
      'text': '다양한 물품을 대여하고 대여해줄 수 있어요.',
    },
    {
      'image': 'assets/sangchoo.png',
      'text': '상추를 모으면 비교과포인트로 바꿀 수 있어요.',
    },
    {
      'image': 'assets/cabinet.png',
      'text': '캐비넷을 통해 비대면으로 대여가 가능해요.',
    },
    {
      'image': 'assets/rentreestart.png',
      'text': '렌트리와 함께 즐거운 대여생활을 시작해봐요!',
    },
  ];

  void _goToHomeScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()), // 홈 화면으로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: guideData.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return GuidePage(
              imagePath: guideData[index]['image']!,
              description: guideData[index]['text']!,
              currentIndex: _currentPage,
              totalPages: guideData.length,
              isLastPage: index == guideData.length - 1,
              onStartPressed: () => _goToHomeScreen(context),
            );
          },
        ),
      ),
    );
  }
}

class GuidePage extends StatelessWidget {
  final String imagePath;
  final String description;
  final int currentIndex;
  final int totalPages;
  final bool isLastPage;
  final VoidCallback? onStartPressed;

  const GuidePage({
    super.key,
    required this.imagePath,
    required this.description,
    required this.currentIndex,
    required this.totalPages,
    this.isLastPage = false,
    this.onStartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff464646),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    width: currentIndex == index ? 14 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Color(0xff97C663)
                          : Color(0xffD6D6D6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // 시작하기 버튼
        if (isLastPage)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '시작하기',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

