import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Post/post_rental.dart';
import '../Post/post_request.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;
  SearchResultScreen({required this.searchQuery});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

String formatTimeDifference(DateTime createdAt) {
  final now = DateTime.now();
  final diff = now.difference(createdAt);

  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  if (diff.inDays < 30) return '${diff.inDays}일 전';

  final months = diff.inDays ~/ 30;
  if (months < 12) return '${months}달 전';

  return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
}

String formatDateTime(String dateTimeStr) {
  final dt = DateTime.parse(dateTimeStr);
  return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _results = [];
  Set<int> likedItemIds = {}; // 좋아요 누른 아이디 저장
  bool _likedChanged = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _loadLikedItems().then((_) => _fetchResults(widget.searchQuery));
  }

  Future<void> _loadLikedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final res = await http
        .get(Uri.parse('http://10.0.2.2:8080/likes/student/$studentNum'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      likedItemIds = data.map<int>((e) => e['rentalItemId'] as int).toSet();
    }
  }

  Future<void> _fetchResults(String keyword) async {
    final rentalUrl =
        Uri.parse('http://10.0.2.2:8080/rental-item/search?keyword=$keyword');
    final requestUrl =
        Uri.parse('http://10.0.2.2:8080/ItemRequest/search?keyword=$keyword');

    final rentalResponse = await http.get(rentalUrl);
    final requestResponse = await http.get(requestUrl);

    final rentalList = rentalResponse.statusCode == 200
        ? List<Map<String, dynamic>>.from(
            jsonDecode(utf8.decode(rentalResponse.bodyBytes)))
        : [];

    final requestList = requestResponse.statusCode == 200
        ? List<Map<String, dynamic>>.from(
            jsonDecode(utf8.decode(requestResponse.bodyBytes)))
        : [];

    // rental 글에 좋아요 상태 추가
    for (var item in rentalList) {
      item['isLiked'] = likedItemIds.contains(item['id']);
      item['type'] = 'rental';
      item['likeCount'] = await _fetchLikeCount(item['id']);

      final imageRes = await http.get(
        Uri.parse('http://10.0.2.2:8080/images/api/item/${item['id']}'),
      );
      if (imageRes.statusCode == 200) {
        final imageList = jsonDecode(utf8.decode(imageRes.bodyBytes));
        if (imageList.isNotEmpty) {
          item['imageUrl'] = 'http://10.0.2.2:8080${imageList[0]['imageUrl']}';
        }
      }
    }

    for (var item in requestList) {
      item['type'] = 'request';
    }

    setState(() {
      _results = [...rentalList, ...requestList];
    });
  }

  Future<int> _fetchLikeCount(int rentalItemId) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/likes/rentalItem/$rentalItemId/count');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return int.parse(res.body);
    } else {
      return 0;
    }
  }

  Future<void> _toggleLike(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final url = Uri.parse(
        'http://10.0.2.2:8080/likes?studentNum=$studentNum&rentalItemId=${item['id']}');
    final res = await http.post(url);

    if (res.statusCode == 200) {
      setState(() {
        item['isLiked'] = !(item['isLiked'] ?? false);
        item['likeCount'] =
            (item['likeCount'] ?? 0) + (item['isLiked'] ? 1 : -1);
        _likedChanged = true;
      });
    } else {
      print('좋아요 토글 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  onPressed: () {
                    Navigator.pop(context, _likedChanged); // true or false 전달
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
                        hintText: '검색어를 입력하세요',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                      onSubmitted: (query) {
                        _fetchResults(query);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Color(0xff97C663)),
                  onPressed: () {
                    _fetchResults(_searchController.text);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text('검색 결과가 없습니다.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        final createdAt = DateTime.parse(item['createdAt']);
                        final timeAgo = formatTimeDifference(createdAt);
                        final imageUrl = item['imageUrl'];

                        return GestureDetector(
                          onTap: () async {
                            if (item['type'] == 'rental') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostRentalScreen(itemId: item['id']),
                                ),
                              );
                              if (result == true) {
                                _loadLikedItems().then((_) {
                                  _fetchResults(_searchController.text);
                                  _likedChanged = true; // ✅ 검색 결과에서 뒤로 갈 때도 Home에 전달할 수 있도록
                                });
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PostRequestScreen(itemId: item['id']),
                                ),
                              );
                            }
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item['type'] == 'rental'
                                          ? (imageUrl != null && imageUrl.toString().startsWith('http')
                                          ? Image.network(imageUrl,
                                          width: 90, height: 90, fit: BoxFit.cover)
                                          : Image.asset('assets/box.png',
                                          width: 90, height: 90, fit: BoxFit.cover))
                                          : Image.asset('assets/requestIcon.png',
                                          width: 90, height: 90, fit: BoxFit.cover),
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['title'] ?? '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          SizedBox(height: 4),
                                          Text(
                                            '${formatDateTime(item['rentalStartTime'] ?? item['startTime'])} ~ ${formatDateTime(item['rentalEndTime'] ?? item['endTime'])}',
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              if (item['type'] == 'rental') ...[
                                                GestureDetector(
                                                  onTap: () =>
                                                      _toggleLike(item),
                                                  child: Icon(
                                                    item['isLiked']
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 20,
                                                    color: item['isLiked']
                                                        ? Colors.red
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                    '${item['likeCount'] ?? 0}'),
                                              ]
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      children: [
                                        Text(timeAgo,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13)),
                                      ],
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
}
