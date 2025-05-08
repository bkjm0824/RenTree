// 대여 요청 채팅
import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Post/post_request.dart';

class ChatMessage {
  final String content;
  final bool isMe;
  final DateTime? sentAt;

  ChatMessage({required this.content, required this.isMe, this.sentAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myStudentNum) {
    DateTime? parsedSentAt;
    try {
      final rawSentAt = json['sentAt'] as String?;
      if (rawSentAt != null) {
        final trimmed = rawSentAt.split('.').first;
        parsedSentAt = DateTime.parse(trimmed);
      }
    } catch (e) {
      print('❌ sentAt 파싱 실패: $e');
    }

    return ChatMessage(
      content: json['message'],
      isMe: json['senderStudentNum'] == myStudentNum,
      sentAt: parsedSentAt,
    );
  }
}

class ChatRequestScreen extends StatefulWidget {
  final String userName;
  final int chatRoomId;
  final String writerStudentNum;
  final String requesterStudentNum;
  final String receiverStudentNum;
  final int requestId;
  final String title;

  ChatRequestScreen({
    required this.userName,
    required this.chatRoomId,
    required this.writerStudentNum,
    required this.requesterStudentNum,
    required this.receiverStudentNum,
    required this.requestId,
    required this.title,
  });

  @override
  _ChatRequestScreenState createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends State<ChatRequestScreen> {
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  String? _myStudentNum;
  String? _receiverStudentNum;

  @override
  void initState() {
    super.initState();
    _loadStudentNumAndConnect();
    _loadPreviousMessages();
  }

  Future<void> _loadStudentNumAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final myStudentNum = prefs.getString('studentNum') ?? '';
    _myStudentNum = myStudentNum;

    _receiverStudentNum = (_myStudentNum == widget.requesterStudentNum)
        ? widget.receiverStudentNum
        : widget.requesterStudentNum;

    ChatService.connect(
      chatRoomId: widget.chatRoomId,
      myStudentNum: myStudentNum,
      isMounted: () => mounted,
      onMessageReceived: (String body) {
        if (!mounted) return;
        final decoded = jsonDecode(body);
        final message = ChatMessage.fromJson(decoded, myStudentNum);
        setState(() {
          _messages.add(message);
        });
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
    }
  }

  void _confirmDeleteChatRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('채팅방 나가기'),
        content: Text('정말 이 채팅방을 나가시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteChatRoom();
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('채팅방이 삭제되었습니다.')));
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    ChatService.disconnect();
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
                        icon: Icon(Icons.arrow_back_ios_new, color: Color(0xff97C663), size: 30),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                      Text(widget.userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 30),
                        onPressed: _confirmDeleteChatRoom,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),

            // 간단한 요청 글 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.description, size: 40, color: Colors.grey),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text('요청글 ID: ${widget.requestId}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey[300]),

            // 채팅 메시지 목록
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment:
                    message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: message.isMe
                            ? Color(0xff97C663)
                            : Colors.white,
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

            // 입력창
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
                          hintText: '메시지를 입력하세요...'
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
                        final receiver = (senderStudentNum == widget.writerStudentNum)
                            ? widget.requesterStudentNum
                            : widget.writerStudentNum;
                        ChatService.sendMessage(
                          widget.chatRoomId,
                          _myStudentNum!,
                          _receiverStudentNum!,
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
