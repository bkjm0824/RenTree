// 대여 요청 글 상세
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostRequestScreen extends StatefulWidget {
  final int itemId;

  PostRequestScreen({required this.itemId});

  @override
  _PostRequestScreenState createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  String title = '';
  String description = '';
  String nickname = '';
  bool isFaceToFace = true;
  DateTime? rentalStartTime;
  DateTime? rentalEndTime;
  String rentalTimeRangeText = '';
  DateTime? createdAt;
  String timeAgoText = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItemDetail();
  }

  String formatTo24Hour(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return minute == '00' ? '${hour}시' : '${hour}시 ${minute}분';
  }

  Future<void> fetchItemDetail() async {
    final baseUrl = 'http://10.0.2.2:8080/ItemRequest/${widget.itemId}';

    try {
      print("🔍 요청 URL: $baseUrl");
      final response = await http.get(Uri.parse(baseUrl));
      print("📦 응답 상태 코드: ${response.statusCode}");
      print("📦 응답 바디: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);

        setState(() {
          title = data['title'] ?? '제목 없음';
          description = data['description'] ?? '내용 없음';
          nickname = data['nickname'] ?? '익명';
          isFaceToFace = data['isFaceToFace'] ?? true;
          rentalStartTime = DateTime.parse(data['rentalStartTime']);
          rentalEndTime = DateTime.parse(data['rentalEndTime']);
          createdAt = DateTime.parse(data['createdAt']);

          rentalTimeRangeText =
          '${formatTo24Hour(rentalStartTime!)} ~ ${formatTo24Hour(rentalEndTime!)}';

          final now = DateTime.now();
          final difference = now.difference(createdAt!);

          if (difference.inMinutes < 1) {
            timeAgoText = '방금 전';
          } else if (difference.inMinutes < 60) {
            timeAgoText = '${difference.inMinutes}분 전';
          } else if (difference.inHours < 24) {
            timeAgoText = '${difference.inHours}시간 전';
          } else {
            timeAgoText = '${difference.inDays}일 전';
          }

          isLoading = false;
        });
      } else {
        print('불러오기 실패: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print("❌ 예외 발생: $e");
      print("❌ 스택트레이스: $stacktrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
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
                        color: Color(0xff918B8B),
                        iconSize: 30,
                        padding: EdgeInsets.only(left: 10),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(36),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffE7E9C8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                          AssetImage('assets/Profile/hosick.png'),
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text('작성자 : $nickname',
                                  style: TextStyle(fontSize: 16)),
                              SizedBox(height: 4),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text('대여 가능 시간 : $rentalTimeRangeText',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black)),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '대면 여부 : ${isFaceToFace ? '대면' : '비대면'}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black),
                                      ),
                                      Text(
                                        timeAgoText,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 425,
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          description,
                          style: TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 🔹 하트 아이콘과 채팅하기 버튼
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff97C663),
                      foregroundColor: Colors.white,
                      minimumSize: Size(350, 60),
                    ).copyWith(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // TODO: 채팅하기 버튼 기능 추가
                    },
                    child: Text(
                      "채팅하기",
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
