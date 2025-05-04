// 채팅 화면
import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String content;
  final bool isMe;
  final DateTime? sentAt;

  ChatMessage({required this.content, required this.isMe, this.sentAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myStudentNum) {
    return ChatMessage(
      content: json['message'],
      isMe: json['senderStudentNum'] == myStudentNum,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
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
  final String writerStudentNum;       // 글 작성자 학번
  final String requesterStudentNum;
  final String receiverStudentNum;

  ChatDetailScreen({
    required this.userName,
    required this.chatRoomId,
    required this.imageUrl,
    required this.title,
    required this.rentalTimeText,
    required this.isFaceToFace,
    required this.writerStudentNum,          // ✅ 추가
    required this.requesterStudentNum,
    required this.receiverStudentNum,
  });


  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  String? _myStudentNum;
  String? _receiverStudentNum;

  @override
  void initState() {
    super.initState();
    _loadStudentNumAndConnect();
    _loadPreviousMessages(); // 🔥 이거 꼭 추가
  }

  Future<void> _loadStudentNumAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final myStudentNum = prefs.getString('studentNum') ?? '';
    _myStudentNum = myStudentNum;

    // 상대방 학번 계산
    _receiverStudentNum = (_myStudentNum == widget.requesterStudentNum)
        ? widget.receiverStudentNum
        : widget.requesterStudentNum;

    ChatService.connect(
      chatRoomId: widget.chatRoomId,
      myStudentNum: myStudentNum,
      isMounted: () => mounted,
      onMessageReceived: (String body) {
        if (!mounted) return; // 👈 이거 꼭 필요함!!
        final decoded = jsonDecode(body);
        final message = ChatMessage.fromJson(decoded, myStudentNum);

        // try-catch로 안전하게 감싸기
        try {
          if (mounted) {
            setState(() {
              _messages.add(message);
            });
          }
        } catch (e) {
          print("⚠️ setState 에러 발생: $e");
        }
      },
    );
  }

  Future<void> _loadPreviousMessages() async {
    final url = Uri.parse('http://10.0.2.2:8080/chatmessages/room/${widget.chatRoomId}');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final studentNum = prefs.getString('studentNum') ?? '';
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));

      setState(() {
        _messages = data.map((json) => ChatMessage.fromJson(json, studentNum)).toList();
      });
    } else {
      print("❌ 메시지 불러오기 실패: ${res.statusCode}");
    }
  }

  void _confirmDeleteChatRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('채팅방 나가기'),
        content: Text('정말 이 채팅방을 나가시겠습니까?\n채팅 내역은 복구되지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기
              await _deleteChatRoom(); // 삭제 요청
            },
            child: Text('확인', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChatRoom() async {
    final url = Uri.parse('http://10.0.2.2:8080/chatrooms/${widget.chatRoomId}');
    final res = await http.delete(url);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방이 삭제되었습니다.')),
      );
      Navigator.of(context).pop(true); // ✅ true 반환
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${res.statusCode}')),
      );
    }
  }

  @override
  void dispose() {
    ChatService.disconnect(); // ✅ 연결 완전히 종료 + 콜백 끊기
    _messageController.dispose();
    super.dispose();
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
                          Navigator.pop(context, true); // ✅ 무조건 true로 반환해서 새로고침 유도
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
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Colors.redAccent,
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: _confirmDeleteChatRoom, // 👇 함수로 분리
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                        // ✅ 동적으로 receiver 설정
                        final receiverStudentNum =
                        (senderStudentNum == widget.writerStudentNum)
                            ? widget.requesterStudentNum
                            : widget.writerStudentNum;

                        ChatService.sendMessage(
                          widget.chatRoomId,
                          _myStudentNum!,
                          _receiverStudentNum!, // ✅ receiver는 위에서 계산된 값을 사용
                          text,
                        );

                        _messageController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
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