// 🔍 검색 화면 - search.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_result.dart';
import '../Home/home.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _likedChangedInSearchResult = false;

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList('searchHistory') ?? [];

    // 중복 제거 및 앞에 삽입
    searches.remove(query);
    searches.insert(0, query);

    // 최대 10개까지만 저장
    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    await prefs.setStringList('searchHistory', searches);
  }

  Future<List<String>> _getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('searchHistory') ?? [];
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('searchHistory');
    setState(() {});
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) return;
    await _saveSearchQuery(query.trim());
    _navigateToSearchResult(query);
  }

  void _navigateToSearchResult(String query) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(searchQuery: query),
      ),
    );

    _searchController.clear();
    setState(() {}); // 검색기록 새로고침

    if (result == true) {
      _likedChangedInSearchResult = true;// 🟢 HomeScreen에 변경 알림
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        icon: Icon(Icons.arrow_back_ios_new),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, _likedChangedInSearchResult); // 여기서만 pop!
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
                            onSubmitted: _onSearch,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search, color: Color(0xff97C663)),
                        onPressed: () => _onSearch(_searchController.text),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),
            // 최근 검색어 타이틀
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최근 검색',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _clearSearchHistory,
                    child: Text('전체 삭제',
                        style:
                            TextStyle(color: Color(0xff969696), fontSize: 14)),
                  ),
                ],
              ),
            ),
            // 검색 기록 리스트
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _getSearchHistory(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  final history = snapshot.data!;
                  if (history.isEmpty) {
                    return Center(child: Text('검색 기록이 없습니다.'));
                  }

                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final query = history[index];
                      return ListTile(
                        leading: Icon(Icons.history, color: Color(0xff97C663)),
                        title: Text(query, style: TextStyle(fontSize: 16)),
                        onTap: () => _onSearch(query),
                      );
                    },
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
