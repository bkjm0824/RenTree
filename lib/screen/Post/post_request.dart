// 대여 요청 글 상세
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Chat/chat_request.dart';
import 'package:rentree/screen/Post/post_request_Change.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Chat/chatlist.dart';

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
  String? writerProfileImagePath;
  String writerStudentNum = '';
  String? studentNum;
  int chatRoomCount = 0;

  @override
  void initState() {
    super.initState();
    fetchItemDetail();
    _loadStudentNum();
  }

  String formatTo24Hour(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _mapIndexToProfileFile(int index) {
    switch (index) {
      case 1:
        return 'Bugi_profile.png';
      case 2:
        return 'GgoGgu_profile.png';
      case 3:
        return 'Nyangi_profile.png';
      case 4:
        return 'Sangzzi_profile.png';
      default:
        return 'Bugi_profile.png';
    }
  }

  Future<void> _loadStudentNum() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studentNum = prefs.getString('studentNum');
    });
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
          writerStudentNum = data['studentNum'] ?? '';

          final profileIndex = data['profileImage'] ?? 1;
          writerProfileImagePath =
              'assets/Profile/${_mapIndexToProfileFile(profileIndex)}';

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
        await fetchChatRoomCountByWriter();
      } else {
        print('불러오기 실패: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      print("❌ 예외 발생: $e");
      print("❌ 스택트레이스: $stacktrace");
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("게시글 삭제"),
          content: Text("정말 삭제하시겠습니까?"),
          actions: [
            TextButton(
              child: Text("취소"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("삭제", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost() async {
    final url = Uri.parse('http://10.0.2.2:8080/ItemRequest/${widget.itemId}');
    final res = await http.delete(url);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('게시글이 삭제되었습니다.')));
      Navigator.of(context).pop(); // 이전 화면으로 이동
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('삭제 실패: ${res.statusCode}')));
    }
  }

  Future<Map<String, dynamic>?> getOrCreateChatRoom(
      int requestItemId, String studentNum) async {
    final existingUrl =
        Uri.parse('http://10.0.2.2:8080/chatrooms/student/$studentNum');
    final existingRes = await http.get(existingUrl);

    if (existingRes.statusCode == 200) {
      final List<dynamic> existingRooms =
          jsonDecode(utf8.decode(existingRes.bodyBytes));
      for (var room in existingRooms) {
        if (room['type'] == 'request' &&
            room['relatedItemId'] == requestItemId) {
          return {
            'chatRoomId': room['roomId'],
            'responderStudentNum': room['responderStudentNum'],
            'requesterStudentNum': room['requesterStudentNum'],
          };
        }
      }
    }

    final createUrl = Uri.parse(
      'http://10.0.2.2:8080/chatrooms/request/$requestItemId?requesterStudentNum=$studentNum',
    );
    final createRes = await http.post(createUrl);

    if (createRes.statusCode == 200) {
      final data = jsonDecode(utf8.decode(createRes.bodyBytes));
      return {
        'chatRoomId': data['roomId'],
        'responderStudentNum': data['responderStudentNum'],
      };
    }

    print('❌ 채팅방 생성 실패: ${createRes.statusCode}');
    return null;
  }

  Future<void> fetchChatRoomCountByWriter() async {
    if (writerStudentNum.isEmpty) return;

    final url =
        Uri.parse('http://10.0.2.2:8080/chatrooms/student/$writerStudentNum');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> rooms = jsonDecode(utf8.decode(response.bodyBytes));
        final count = rooms
            .where((room) => room['relatedItemId'] == widget.itemId)
            .length;

        setState(() {
          chatRoomCount = count;
        });
      } else {
        print('❌ 채팅방 개수 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 20),
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                    writerProfileImagePath ??
                                        'assets/Profile/Bugi_profile.png'),
                                backgroundColor: Colors.white,
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(title,
                                            style: TextStyle(
                                                fontSize: 23,
                                                fontWeight: FontWeight.bold)),
                                        if (writerStudentNum == studentNum)
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert_rounded),
                                            onSelected: (String value) {
                                              if (value == 'change') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        RequestChangeScreen(
                                                            id: widget.itemId),
                                                  ),
                                                ).then(
                                                    (_) => fetchItemDetail());
                                              }
                                              if (value == 'delete') {
                                                _confirmDelete();
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) => [
                                              PopupMenuItem<String>(
                                                value: 'change',
                                                child: Text('수정'),
                                              ),
                                              PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('삭제'),
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text('작성자 : $nickname',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 4),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text('대여시간 : $rentalTimeRangeText',
                                                style: TextStyle(fontSize: 14)),
                                            Text(' | ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xff747474),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${isFaceToFace ? '대면' : '비대면'}',
                                                style: TextStyle(fontSize: 14)),
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
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        (studentNum == writerStudentNum)
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff97C663),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(350, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChatListScreen(), // ChatListScreen은 본인 코드에 맞춰 수정
                                    ),
                                  );
                                },
                                child: Text(
                                  "대화 중인 채팅 $chatRoomCount",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff97C663),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(350, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final studentNum =
                                      prefs.getString('studentNum');
                                  if (studentNum == null) return;

                                  final result = await getOrCreateChatRoom(
                                      widget.itemId, studentNum);
                                  if (result != null) {
                                    final chatRoomId = result['chatRoomId'];

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRequestScreen(
                                          chatRoomId: chatRoomId,
                                          userName: nickname,
                                          title: title,
                                          requestId: widget.itemId,
                                          writerStudentNum: writerStudentNum,
                                          requesterStudentNum: studentNum,
                                          receiverStudentNum: studentNum ==
                                                  writerStudentNum
                                              ? result['requesterStudentNum']
                                              : writerStudentNum,
                                          rentalTimeText: rentalTimeRangeText,
                                          isFaceToFace: isFaceToFace,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "채팅하기",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
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
