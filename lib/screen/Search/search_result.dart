import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../post.dart';
import 'search.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;

  SearchResultScreen({required this.searchQuery});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late TextEditingController _searchController;
  List<String> _searchResults = []; // 실제 검색결과는 백엔드 연동 시 사용

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _performSearch(widget.searchQuery);
    _saveSearchQuery(widget.searchQuery);
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentSearches =
        prefs.getStringList('recentSearches') ?? [];

    // 중복 제거 후 맨 앞에 추가
    recentSearches.remove(query);
    recentSearches.insert(0, query);

    // 최대 10개까지만 저장
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }

    await prefs.setStringList('recentSearches', recentSearches);
  }

  void _performSearch(String query) {
    // 여기에 검색 API 호출 또는 필터링 로직 추가
    setState(() {
      _searchResults = List.generate(5, (index) => '$query');
    });
  }

  void _navigateToSearchResult(String query) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
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
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xffEBEBEB),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: '검색어를 입력하세요.',
                              hintStyle: TextStyle(color: Color(0xFF848484)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 20),
                            ),
                            onSubmitted: (query) {
                              _navigateToSearchResult(query);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search, color: Color(0xff97C663)),
                        onPressed: () {
                          _navigateToSearchResult(_searchController.text);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),

            // 🔥 리스트뷰
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostScreen(
                            title: _searchResults[index],
                            description: _searchResults[index],
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
                                      _searchResults[index],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text('${_searchResults[index]}',
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
                                            style:
                                                TextStyle(color: Colors.grey)),
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
