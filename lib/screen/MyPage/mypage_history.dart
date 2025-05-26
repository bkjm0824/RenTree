import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Home/home.dart';
import '../Post/post_rental.dart';
import '../Post/post_request.dart';

class MyPageHistory extends StatefulWidget {
  @override
  _MyPageHistoryState createState() => _MyPageHistoryState();
}

class _MyPageHistoryState extends State<MyPageHistory> {
  int selectedTabIndex = 0;
  List<Map<String, dynamic>> receivedList = [];
  List<Map<String, dynamic>> givenList = [];
  String? myStudentNum;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  String formatDateTime(String dateTimeStr) {
    final dt = DateTime.parse(dateTimeStr);
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String formatTimeAgo(String dateTimeStr) {
    try {
      final createdAt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(createdAt);

      if (diff.inMinutes < 1) return '방금 전';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      return '${diff.inDays}일 전';
    } catch (e) {
      return '';
    }
  }

  bool isValidImageUrl(String? url) {
    return url != null &&
        url.trim().isNotEmpty &&
        url.trim().toLowerCase() != 'null';
  }

  Future<void> _loadHistories() async {
    final prefs = await SharedPreferences.getInstance();
    myStudentNum = prefs.getString('studentNum');
    if (myStudentNum == null) return;

    final rentalMyRes = await http.get(Uri.parse(
        'http://54.79.35.255:8080/api/history/rentals/my?studentNum=$myStudentNum'));
    final rentalGivenRes = await http.get(Uri.parse(
        'http://54.79.35.255:8080/api/history/rentals/given?studentNum=$myStudentNum'));
    final requestMyRes = await http.get(Uri.parse(
        'http://54.79.35.255:8080/api/history/requests/got?studentNum=$myStudentNum'));
    final requestGivenRes = await http.get(Uri.parse(
        'http://54.79.35.255:8080/api/history/requests/my?studentNum=$myStudentNum'));

    List<dynamic> parseToList(dynamic body) {
      if (body is List) return body;
      if (body is Map && body['data'] is List) return body['data'];
      return []; // fallback
    }

    final rentalMy =
        parseToList(jsonDecode(utf8.decode(rentalMyRes.bodyBytes)));
    final rentalGiven =
        parseToList(jsonDecode(utf8.decode(rentalGivenRes.bodyBytes)));
    final requestMy =
        parseToList(jsonDecode(utf8.decode(requestMyRes.bodyBytes)));
    final requestGiven =
        parseToList(jsonDecode(utf8.decode(requestGivenRes.bodyBytes)));
    print('🧪 rentalMy 응답: $rentalMy');
    print('🧪 rentalGiven 응답: $rentalGiven');
    print('🧪 requestMy 응답: $requestMy');
    print('🧪 requestGiven 응답: $requestGiven');

    List<Map<String, dynamic>> received = [];
    List<Map<String, dynamic>> given = [];

    Future<String?> fetchImageUrl(int rentalItemId) async {
      final res = await http.get(
          Uri.parse('http://54.79.35.255:8080/images/api/item/$rentalItemId'));
      if (res.statusCode == 200) {
        final List<dynamic> images = jsonDecode(utf8.decode(res.bodyBytes));
        if (images.isNotEmpty) {
          final url = images[0]['imageUrl']?.toString();
          if (url != null && url.startsWith('/images/')) {
            return 'http://54.79.35.255:8080$url'; // 상대경로 → 절대경로로 변환
          }
        }
      }
      return null; // 절대경로이거나 잘못된 경우에는 null → box.png 사용
    }

    Future<int> fetchLikeCount(int rentalItemId) async {
      final res = await http.get(Uri.parse(
          'http://54.79.35.255:8080/likes/rentalItem/$rentalItemId/count'));
      if (res.statusCode == 200) {
        return int.tryParse(res.body) ?? 0;
      } else {
        print('❌ 좋아요 수 가져오기 실패: ${res.statusCode}');
        return 0;
      }
    }

    for (var item in rentalMy) {
      final rentalItem = item["rentalItem"];
      if (rentalItem == null) continue;
      final rentalItemId = rentalItem["id"];
      final imageUrl = await fetchImageUrl(rentalItemId);
      final likeCount = await fetchLikeCount(rentalItemId);

      received.add({
        "id": rentalItemId,
        "title": rentalItem["title"],
        "type": "rental",
        "profile": rentalItem["profileImage"],
        "isFaceToFace": rentalItem["isFaceToFace"],
        "time": rentalItem["rentalStartTime"],
        "endTime": rentalItem["rentalEndTime"],
        "imageUrl": imageUrl,
        "createdAt": rentalItem["createdAt"],
        "likeCount": likeCount,
      });
    }

    for (var item in requestMy) {
      final requestItem = item["requestItem"];
      if (requestItem == null) continue;
      given.add({
        "id": requestItem["id"],
        "title": requestItem["title"],
        "type": "request",
        "profile": requestItem["profileImage"],
        "isFaceToFace": requestItem["isFaceToFace"],
        "time": requestItem["rentalStartTime"],
        "endTime": requestItem["rentalEndTime"],
        "createdAt": requestItem["createdAt"],
      });
    }

    for (var item in rentalGiven) {
      final rentalItem = item["rentalItem"];
      if (rentalItem == null) continue;
      final rentalItemId = rentalItem["id"];
      final imageUrl = await fetchImageUrl(rentalItemId);
      final likeCount = await fetchLikeCount(rentalItemId);

      given.add({
        "id": rentalItemId,
        "title": rentalItem["title"],
        "type": "rental",
        "profile": rentalItem["profileImage"],
        "isFaceToFace": rentalItem["isFaceToFace"],
        "time": rentalItem["rentalStartTime"],
        "endTime": rentalItem["rentalEndTime"],
        "imageUrl": imageUrl,
        "createdAt": rentalItem["createdAt"],
        "likeCount": likeCount,
      });
    }

    for (var item in requestGiven) {
      final requestItem = item["requestItem"];
      final responder = item["responder"];
      if (requestItem == null || responder == null) continue;

      final responderNum = responder["studentNum"];
      if (responderNum == null) continue;

      if (responderNum == myStudentNum) {
        received.add({
          "id": requestItem["id"],
          "title": requestItem["title"],
          "type": "request",
          "profile": requestItem["profileImage"],
          "isFaceToFace": requestItem["isFaceToFace"],
          "time": requestItem["rentalStartTime"],
          "endTime": requestItem["rentalEndTime"],
          "createdAt": requestItem["createdAt"],
        });
      }
    }

    setState(() {
      received.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      given.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      receivedList = received;
      givenList = given;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listToShow = selectedTabIndex == 0 ? receivedList : givenList;

    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 상단바
                  _buildTopBar(),
                  // 탭
                  _buildTabBar(),
                  Container(height: 1, color: Colors.grey[300]),
                  // 리스트
                  Expanded(
                    child: listToShow.isEmpty
                        ? Center(child: Text('대여 내역이 없습니다.'))
                        : ListView.builder(
                            itemCount: listToShow.length,
                            itemBuilder: (context, index) {
                              final item = listToShow[index];
                              return _buildHistoryItem(item);
                            },
                          ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
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
                onPressed: () => Navigator.pop(context),
              ),
              Text('대여 내역',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.home),
                color: Color(0xff97C663),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => HomeScreen())),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      child: Row(
        children: [
          _buildTab('대여받은 내역', 0, receivedList.length),
          _buildTab('대여해준 내역', 1, givenList.length),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final selected = selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTabIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('$label $count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? Color(0xff97C663) : Colors.grey,
                )),
            SizedBox(height: 6),
            Container(
                height: 2,
                color: selected ? Color(0xff97C663) : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final imageUrl = item['imageUrl'];
    final startTime = item['time'];
    final endTime = item['endTime'];
    final createdAt = item['createdAt'];
    final likeCount = item['likeCount'] ?? 0;
    print('🔍 imageUrl: $imageUrl');
    String timeText = (startTime != null && endTime != null)
        ? '${formatDateTime(startTime)} ~ ${formatDateTime(endTime)}'
        : '양도(무료나눔)';

    return GestureDetector(
      onTap: () async {
        if (item['type'] == 'rental') {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostRentalScreen(itemId: item['id']),
            ),
          );

          if (changed == true) {
            // 좋아요 변경됨 → 다시 불러오기
            _loadHistories(); // 👈 찜 수 반영 위해 다시 불러옴
          }
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
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 좌측 이미지 or 아이콘
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Color(0xffEBEBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item['type'] == 'rental'
                        ? (isValidImageUrl(imageUrl)
                            ? Image.network(imageUrl, fit: BoxFit.cover)
                            : Image.asset('assets/box.png', fit: BoxFit.cover))
                        : Image.asset('assets/requestIcon.png',
                            fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 20),
                // ✅ 중앙 텍스트 블럭
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text(timeText,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                ),
                // ✅ 우측 상단: 작성 시간, 하단: 좋아요
                Container(
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (createdAt != null)
                        Text(formatTimeAgo(createdAt),
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      if (item['type'] == 'rental')
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.grey, size: 18),
                            SizedBox(width: 4),
                            Text('$likeCount', style: TextStyle(fontSize: 13)),
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
  }
}
