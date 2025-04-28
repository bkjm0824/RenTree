import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostRentalScreen extends StatefulWidget {
  final int itemId;
  PostRentalScreen({required this.itemId});

  @override
  _PostRentalScreenState createState() => _PostRentalScreenState();
}

class _PostRentalScreenState extends State<PostRentalScreen> {
  String title = '';
  String description = '';
  String imageUrl = '';
  String nickname = '';
  bool isFaceToFace = true;
  DateTime? rentalStartTime;
  DateTime? rentalEndTime;
  String rentalTimeRangeText = '';
  DateTime? createdAt;
  String timeAgoText = '';
  bool isLoading = true;

  bool isLiked = false;
  int likeCount = 0;
  String? studentNum;

  @override
  void initState() {
    super.initState();
    fetchItemDetail();
    fetchLikeStatus();
    fetchLikeCount();
  }

  String formatTo24Hour(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> fetchItemDetail() async {
    final baseUrl = 'http://10.0.2.2:8080/rental-item/${widget.itemId}';

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        final imageRes = await http
            .get(Uri.parse('http://10.0.2.2:8080/images/api/${widget.itemId}'));
        if (imageRes.statusCode == 200) {
          final imageData = jsonDecode(utf8.decode(imageRes.bodyBytes));
          if (imageData.isNotEmpty) {
            imageUrl = 'http://10.0.2.2:8080${imageData[0]['imageUrl']}';
          }
        }

        setState(() {
          title = data['title'] ?? '제목 없음';
          description = data['description'] ?? '내용 없음';
          nickname = data['student']['nickname'] ?? '익명';
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
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
    }
  }

  Future<void> fetchLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final url = Uri.parse('http://10.0.2.2:8080/likes/student/$studentNum');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> likedList = jsonDecode(utf8.decode(res.bodyBytes));
      final likedItemIds = likedList.map((e) => e['rentalItemId']).toList();
      setState(() {
        isLiked = likedItemIds.contains(widget.itemId);
      });
    }
  }

  Future<void> fetchLikeCount() async {
    final url = Uri.parse(
        'http://10.0.2.2:8080/likes/rentalItem/${widget.itemId}/count');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      setState(() {
        likeCount = int.parse(res.body);
      });
    }
  }

  Future<void> toggleLike() async {
    if (studentNum == null) return;

    final url = Uri.parse(
        'http://10.0.2.2:8080/likes?studentNum=$studentNum&rentalItemId=${widget.itemId}');
    final res = await http.post(url);

    if (res.statusCode == 200) {
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
    } else {
      print('❌ 좋아요 토글 실패');
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
                  // 상단바
                  // 이미지 + 뒤로가기 버튼을 Stack으로 묶기
                  Stack(
                    children: [
                      // 1. 배경 이미지
                      Container(
                        width: double.infinity,
                        height: 340,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Colors.grey[300],
                        ),
                        child: ClipRRect(
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                        ),
                      ),

                      // 2. 상단바 (투명 배경)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 30), // 버튼 색상 흰색 추천!
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  // 본문
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xffE7E9C8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
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
                                        style: TextStyle(fontSize: 14)),
                                    SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text('대여시간 : $rentalTimeRangeText',
                                            style: TextStyle(fontSize: 14)),
                                        Text(' | ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff747474),
                                                fontWeight: FontWeight.bold)),
                                        Text('${isFaceToFace ? '대면' : '비대면'}',
                                            style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 210,
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  description,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(' 관심 $likeCount',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff747474))),
                              Text(' | ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff747474),
                                      fontWeight: FontWeight.bold)),
                              Text(timeAgoText,
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff747474))),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  // 하트 + 채팅하기
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: toggleLike,
                          child: Column(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 60,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff97C663),
                            foregroundColor: Colors.white,
                            minimumSize: Size(270, 60),
                          ).copyWith(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          onPressed: () {
                            // TODO: 채팅하기 기능 추가
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
