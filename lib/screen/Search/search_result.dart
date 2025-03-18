// 검색 결과 화면
import 'package:flutter/material.dart';

import '../post.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  final TextEditingController _searchController = TextEditingController();

  SearchResultScreen({required this.searchQuery}) {
    // 초기 검색어 설정
    _searchController.text = searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (뒤로가기, 검색창, 검색 버튼)
            Container(
              color: Color(0xffF4F1F1),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔹 뒤로가기 버튼
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context); // 뒤로 가기
                        },
                      ),

                      // 🔹 검색창
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xffEBEBEB),
                            borderRadius: BorderRadius.circular(30), // 둥근 모서리
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '검색어를 입력하세요.',
                              hintStyle: TextStyle(color: Color(0xFF848484)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20), // 위아래 간격을 넓게
                            ),
                            onSubmitted: (query) {
                              _navigateToSearchResult(context, query);
                            },
                          ),
                        ),
                      ),

                      // 🔹 검색 버튼
                      IconButton(
                        icon: Icon(Icons.search, color: Color(0xff97C663)),
                        onPressed: () {
                          String query = _searchController.text;
                          _navigateToSearchResult(context, query);
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
                itemCount: 5,
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

  // 검색 결과 화면으로 이동하는 함수
  void _navigateToSearchResult(BuildContext context, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(searchQuery: query),
      ),
    );
  }
}
