import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Post/post_rental.dart';
import '../Post/post_request.dart';
import '../Home/addpost_give.dart';
import '../Home/addpost_request.dart';

class MyPageMypost extends StatefulWidget {
  @override
  _MyPageMypostState createState() => _MyPageMypostState();
}

class _MyPageMypostState extends State<MyPageMypost>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? myStudentNum;
  List<Map<String, dynamic>> _allPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadMyStudentNum();
  }

  Future<void> loadMyStudentNum() async {
    final prefs = await SharedPreferences.getInstance();
    myStudentNum = prefs.getString('studentNum');
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final res = await http.get(Uri.parse('http://10.0.2.2:8080/home/items'));

    if (res.statusCode != 200) {
      throw Exception('서버 통신 실패');
    }

    final List<dynamic> decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final List<Map<String, dynamic>> loadedPosts =
        decoded.map((e) => Map<String, dynamic>.from(e)).toList();

    for (var item in loadedPosts) {
      item['isLiked'] = false;
    }

    _allPosts = loadedPosts
        .where((post) => post['studentNum'] == myStudentNum)
        .toList();
    setState(() {});
  }

  List<Map<String, dynamic>> getFilteredPosts(String type) {
    if (type == '대여 요청') {
      return _allPosts.where((post) => post['itemType'] == 'REQUEST').toList();
    } else if (type == '물품 대여') {
      return _allPosts.where((post) => post['itemType'] == 'RENTAL').toList();
    }
    return _allPosts;
  }

  String formatTimeDifference(String createdAt) {
    final created = DateTime.parse(createdAt);
    final now = DateTime.now();
    final diff = now.difference(created);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 30) return '${diff.inDays}일 전';
    final months = diff.inDays ~/ 30;
    if (months < 12) return '${months}달 전';
    return '${created.year}.${created.month.toString().padLeft(2, '0')}.${created.day.toString().padLeft(2, '0')}';
  }

  String formatDateTime(String dateTimeStr) {
    final dt = DateTime.parse(dateTimeStr);
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                      color: Colors.grey[700],
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Text(
                      '나의 게시글',
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showWriteModal,
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xff97C663),
                        padding:
                            EdgeInsets.symmetric(horizontal: 1, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        '글쓰기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              color: Color(0xffF4F1F1),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Color(0xff97C663),
                labelColor: Color(0xff97C663),
                unselectedLabelColor: Color(0xff918B8B),
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: '대여 요청'),
                  Tab(text: '물품 대여'),
                ],
              ),
            ),
            Container(height: 1, color: Colors.grey[300]),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList('대여 요청'),
                  _buildList('물품 대여'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String type) {
    final posts = getFilteredPosts(type);

    if (posts.isEmpty) {
      return Center(
          child: Text('등록된 글이 없습니다.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final item = posts[index];
        return _buildPostItem(item);
      },
    );
  }

  Widget _buildPostItem(Map<String, dynamic> item) {
    final bool isRental = item['itemType'] == 'RENTAL';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          if (isRental) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostRentalScreen(itemId: item['id']),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostRequestScreen(itemId: item['id']),
              ),
            );
          }
        },
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isRental
                        ? (item['imageUrl'] != null
                            ? Image.network(item['imageUrl'], fit: BoxFit.cover)
                            : Image.asset('assets/box.png', fit: BoxFit.cover))
                        : Image.asset('assets/requestIcon.png',
                            fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${formatDateTime(item['rentalStartTime'] ?? item['startTime'])} ~ ${formatDateTime(item['rentalEndTime'] ?? item['endTime'])}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                item['isLiked'] = !(item['isLiked'] ?? false);
                              });
                            },
                            child: Icon(
                              item['isLiked']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: item['isLiked'] ? Colors.red : Colors.grey,
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(formatTimeDifference(item['createdAt']),
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ],
            ),
            Divider(height: 20, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  void _showWriteModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  foregroundColor: Colors.white,
                  minimumSize: Size(230, 60),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToScreen(RequestScreen());
                },
                child: Text("대여 요청하기",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  foregroundColor: Colors.white,
                  minimumSize: Size(230, 60),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToScreen(PostGiveScreen());
                },
                child: Text("물품 등록하기",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToScreen(Widget screen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.5),
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: screen,
      ),
    );
  }
}
