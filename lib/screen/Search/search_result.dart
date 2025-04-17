import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../post.dart';

enum SearchType { rental, request }

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;
  SearchResultScreen({required this.searchQuery});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;
  List<dynamic> _results = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _tabController = TabController(length: 2, vsync: this);

    _saveSearchQuery(widget.searchQuery);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        _fetchResults(_searchController.text);
      }
    });

    _fetchResults(widget.searchQuery);
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recentSearches =
        prefs.getStringList('searchHistory') ?? [];

    recentSearches.remove(query);
    recentSearches.insert(0, query);

    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }

    await prefs.setStringList('searchHistory', recentSearches);
  }

  void _fetchResults(String keyword) async {
    final rentalUrl =
        Uri.parse('http://10.0.2.2:8080/rental-item/search?keyword=$keyword');
    final requestUrl =
        Uri.parse('http://10.0.2.2:8080/ItemRequest/search?keyword=$keyword');

    final rentalResponse = await http.get(rentalUrl);
    final requestResponse = await http.get(requestUrl);

    final rentalList = rentalResponse.statusCode == 200
        ? json.decode(utf8.decode(rentalResponse.bodyBytes))
        : [];

    final requestList = requestResponse.statusCode == 200
        ? json.decode(utf8.decode(requestResponse.bodyBytes))
        : [];

    // 탭 자동 전환
    if (rentalList.isEmpty && requestList.isNotEmpty) {
      _tabController.index = 0; // 대여 요청 탭
      setState(() {
        _results = requestList;
      });
    } else if (requestList.isEmpty && rentalList.isNotEmpty) {
      _tabController.index = 1; // 물품 대여 탭
      setState(() {
        _results = rentalList;
      });
    } else {
      // 현재 탭 기준으로 결과 설정
      setState(() {
        _results = _tabController.index == 1 ? rentalList : requestList;
      });
    }
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xffF4F1F1),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 15),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    color: Color(0xff97C663),
                    iconSize: 30,
                    onPressed: () => Navigator.pop(context),
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

              // 🔹 TabBar UI
              Container(
                color: Color(0xffF4F1F1),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Color(0xff97C663),
                  indicatorWeight: 1.0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Color(0xff97C663),
                  unselectedLabelColor: Color(0xff918B8B),
                  labelStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  unselectedLabelStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: '대여 요청'),
                    Tab(text: '물품 대여'),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.grey[300]),

              // 🔥 리스트뷰
              Expanded(
                child: _results.isEmpty
                    ? Center(
                        child: Text('검색 결과가 없습니다',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          final title = item['title'] ?? '';
                          final description = item['description'] ?? '';
                          final imageUrl = item['imageUrl'] ?? 'assets/box.png';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostScreen(
                                    title: title,
                                    description: description,
                                    imageUrl: imageUrl,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          'assets/box.png',
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 110,
                                              height: 110,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(title,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text(
                                              description,
                                              style: TextStyle(
                                                  color: Colors.grey[700]),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.favorite_border,
                                                        size: 20,
                                                        color: Colors.red),
                                                    SizedBox(width: 5),
                                                    Text('좋아요'),
                                                  ],
                                                ),
                                                Text('3시간 전',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
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
      ),
    );
  }
}
