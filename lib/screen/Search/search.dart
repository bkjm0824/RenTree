// 검색 화면
import 'package:flutter/material.dart';

import 'search_result.dart';

class SearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

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

            // 🔹 최근 검색과 전체 삭제 문구
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 최근 검색
                  Text(
                    '최근 검색',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // 전체 삭제
                  TextButton(
                    onPressed: () {
                      print('전체 삭제 클릭됨');
                    },
                    child: Text(
                      '전체 삭제',
                      style: TextStyle(
                        color: Color(0xff969696),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 검색 내역 리스트 (예시 데이터)
            Expanded(
              child: ListView.builder(
                itemCount: 5, // 예시로 5개 항목을 보여줌
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.history, color: Color(0xff97C663)),
                    title: Text('검색 내역 ${index + 1}', style: TextStyle(fontSize: 16)),
                    onTap: () {
                      print('검색 내역 ${index + 1} 클릭됨');
                    },
                  );
                },
              ),
            ),
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
