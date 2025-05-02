// 채팅 화면
import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String content;
  final bool isMe;

  ChatMessage({required this.content, required this.isMe});

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myStudentNum) {
    return ChatMessage(
      content: json['message'],
      isMe: json['senderStudentNum'] == myStudentNum,
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String imageUrl;
  final String title;
  final String rentalTimeText;
  final bool isFaceToFace;
  final int chatRoomId;

  ChatDetailScreen({
    required this.userName,
    required this.chatRoomId,
    required this.imageUrl,
    required this.title,
    required this.rentalTimeText,
    required this.isFaceToFace,
  });


  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadStudentNumAndConnect();
    fetchChatRoomAndItem();
  }

  Future<void> _loadStudentNumAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum') ?? '';

    ChatService.connect(
      onMessageReceived: (String body) {
        final decoded = jsonDecode(body);
        final message = ChatMessage.fromJson(decoded, studentNum);
        setState(() {
          _messages.add(message);
        });
      },
    );
  }

  Future<void> fetchChatRoomAndItem() async {
    final roomUrl = Uri.parse('http://10.0.2.2:8080/chatrooms/${widget.chatRoomId}');
    final roomRes = await http.get(roomUrl);

    String title = '';
    String imageUrl = '';
    String timeRange = '';
    bool isFaceToFace = true;
    bool isLoading = true;

    if (roomRes.statusCode == 200) {
      final roomData = jsonDecode(utf8.decode(roomRes.bodyBytes));
      final rentalItemId = roomData['rentalItemId'];

      final itemUrl = Uri.parse('http://10.0.2.2:8080/rental-item/$rentalItemId');
      final itemRes = await http.get(itemUrl);

      if (itemRes.statusCode == 200) {
        final itemData = jsonDecode(utf8.decode(itemRes.bodyBytes));
        final start = DateTime.parse(itemData['rentalStartTime']);
        final end = DateTime.parse(itemData['rentalEndTime']);

        setState(() {
          title = itemData['title'];
          imageUrl = itemData['imageUrl'] ?? ''; // 너가 별도로 /images 호출했다면 여기에 적용
          timeRange = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} ~ ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
          isFaceToFace = itemData['isFaceToFace'];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바
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
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(left: 10),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        widget.userName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),

            // 🔹 상품 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(
                      widget.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/box.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '대여시간: ${widget.rentalTimeText} | ${widget.isFaceToFace ? '대면' : '비대면'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff97C663),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '대여 요청',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey[300]),

            // 🔹 채팅 메시지 영역
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: message.isMe ? Color(0xff97C663) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: message.isMe ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 입력창
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: Color(0xff97C663)),
                  SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xff97C663)),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final senderStudentNum = prefs.getString('studentNum') ?? '';
                        final text = _messageController.text.trim();
                        if (text.isNotEmpty) {
                          ChatService.sendMessage(widget.chatRoomId, senderStudentNum, text); // 채팅방ID는 필요에 따라 넘겨줘야 해
                          _messageController.clear();
                        }
                      }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
