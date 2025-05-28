// 물품 대여 채팅 화면
import 'package:flutter/material.dart';
import 'package:rentree/screen/Chat/passwordPopup.dart';
import 'package:rentree/screen/Chat/setPasswordPopup.dart';
import 'chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Post/post_rental.dart';

class ChatMessage {
  final String content;
  final bool isMe;
  final DateTime? sentAt;

  ChatMessage({required this.content, required this.isMe, this.sentAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myStudentNum) {
    DateTime? parsedSentAt;
    try {
      // 마이크로초 자르기
      final rawSentAt = json['sentAt'] as String?;
      if (rawSentAt != null) {
        final trimmed = rawSentAt.split('.').first; // "2025-05-08T14:25:18"
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

enum RentalState {
  idle, // 대여 요청 전
  requested, // 대여 요청함
  approved, // 승인됨
  returned, // 반납 요청함
  completed // 반납 완료됨
}

class ChatRentalScreen extends StatefulWidget {
  final String userName;
  final String imageUrl;
  final String title;
  final String rentalTimeText;
  final bool isFaceToFace;
  final int chatRoomId;
  final String writerStudentNum; // 글 작성자 학번
  final String requesterStudentNum;
  final String receiverStudentNum;
  final int rentalItemId;
  final int receiverProfileIndex;

  ChatRentalScreen({
    required this.userName,
    required this.chatRoomId,
    required this.imageUrl,
    required this.title,
    required this.rentalTimeText,
    required this.isFaceToFace,
    required this.writerStudentNum,
    required this.requesterStudentNum,
    required this.receiverStudentNum,
    required this.rentalItemId,
    required this.receiverProfileIndex,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatRentalScreen> {
  TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  String? _myStudentNum;
  String? _receiverStudentNum;
  int _receiverProfileIndex = 1;
  DateTime? _lastMessageTime;

  @override
  void initState() {
    super.initState();
    _receiverProfileIndex = widget.receiverProfileIndex;
    _loadStudentNumAndConnect();
    _loadPreviousMessages(); // 🔥 이거 꼭 추가
  }

  String _profileAssetName(int index) {
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
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());
          }
        } catch (e) {
          print("⚠️ setState 에러 발생: $e");
        }
      },
    );
  }

  Future<void> _loadPreviousMessages() async {
    final url = Uri.parse(
        'http://54.79.35.255:8080/chatmessages/rental/${widget.chatRoomId}');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final studentNum = prefs.getString('studentNum') ?? '';
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));

      final messages =
          data.map((json) => ChatMessage.fromJson(json, studentNum)).toList();

      // ✅ 마지막 메시지 시간 저장
      if (messages.isNotEmpty) {
        _lastMessageTime = messages.last.sentAt;
      }

      setState(() {
        _messages = messages;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      });
    } else {
      print("❌ 메시지 불러오기 실패: ${res.statusCode}");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _confirmDeleteChatRoom() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xffF4F1F1),
        title: Text(
          '채팅방 나가기',
          style:
              TextStyle(fontFamily: 'Pretender', fontWeight: FontWeight.w600),
        ),
        content: Text('정말 이 채팅방을 나가시겠습니까?\n채팅 내역은 복구되지 않습니다.'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff97C663),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기
              await _deleteChatRoom(); // 삭제 요청
            },
            child: Text("확인"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('취소'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChatRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final myStudentNum = prefs.getString('studentNum') ?? '';

    final url = Uri.parse(
      'http://54.79.35.255:8080/chatrooms/rental/id/${widget.chatRoomId}?studentNum=$myStudentNum',
    );

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

  String buildRentalRequestMessage() {
    //대여요청 누를 시 만들어지는 글
    final now = DateTime.now();
    final dateText = "${now.year}년 ${now.month}월 ${now.day}일";
    final timeRange = widget.rentalTimeText; // 예: "15:00 - 18:00"
    final faceToFace = widget.isFaceToFace ? "대면" : "비대면";

    return "대여를 요청하였습니다.\n$dateText\n$timeRange\n대여방식 : $faceToFace";
  }

  String buildRequestAllowMessage(String approverName) {
    return "$approverName 님이 대여를 승인했어요. 반납시간을 잘 지켜주세요!";
  }

  String getFormattedTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
            ? 12
            : hour;
    return '$period $displayHour:$minute';
  }

  bool hasApprovalMessage() {
    return _messages.any((msg) => msg.content.contains('님이 대여를 승인했어요'));
  }

  bool hasReturnCompleteMessage() {
    final matched = _messages.any((msg) {
      print("🔍 검사 중 메시지: ${msg.content}");
      return msg.content.contains('반납이 완료되었습니다.');
    });
    print("✅ 반납 완료 메시지 발견됨? $matched");
    return matched;
  }

  RentalState _calculateRentalState() {
    bool requested = false;
    bool approved = false;
    bool returned = false;
    bool completed = false;

    for (var msg in _messages) {
      if (msg.content.startsWith('대여를 요청하였습니다.')) requested = true;
      if (msg.content.contains('대여를 승인했어요')) approved = true;
      if (msg.content.contains('반납을 요청하였습니다.')) returned = true;
      if (msg.content.contains('반납이 완료되었습니다.')) completed = true;
    }

    if (completed) return RentalState.completed;
    if (returned) return RentalState.returned;
    if (approved) return RentalState.approved;
    if (requested) return RentalState.requested;
    return RentalState.idle;
  }

  @override
  void dispose() {
    ChatService.disconnect(); // ✅ 연결 완전히 종료 + 콜백 끊기
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<ChatMessage>> groupedMessages = {};
    for (var msg in _messages) {
      if (msg.sentAt == null) continue;
      String dateKey =
          "${msg.sentAt!.year}-${msg.sentAt!.month.toString().padLeft(2, '0')}-${msg.sentAt!.day.toString().padLeft(2, '0')}";
      if (!groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey] = [];
      }
      groupedMessages[dateKey]!.add(msg);
    }

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
                          Navigator.pop(context, {
                            'lastMessageTime': _lastMessageTime,
                            'lastMessage': _messages.isNotEmpty
                                ? _messages.last.content
                                : '',
                          });
                        },
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                                'assets/Profile/${_profileAssetName(_receiverProfileIndex)}'),
                            backgroundColor: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Pretender',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                  GestureDetector(
                    onTap: () async {
                      final url = Uri.parse(
                          'http://54.79.35.255:8080/rental-item/${widget.rentalItemId}');
                      final res = await http.get(url);

                      if (res.statusCode == 200) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostRentalScreen(itemId: widget.rentalItemId),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('게시글 없음'),
                            content: Text('작성자가 삭제한 글입니다.'),
                            actions: [
                              TextButton(
                                child: Text('확인',
                                    style: TextStyle(color: Color(0xff97C663))),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.imageUrl.startsWith('http')
                          ? Image.network(
                              widget.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/box.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/box.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Pretender',
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '대여시간: ${widget.rentalTimeText} | ${widget.isFaceToFace ? '대면' : '비대면'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Spacer(),
                  Spacer(),
                  Builder(
                    builder: (context) {
                      final currentState = _calculateRentalState();

                      Widget bottomActionButton = SizedBox.shrink();

                      if (_myStudentNum == widget.requesterStudentNum) {
                        if (currentState == RentalState.idle) {
                          bottomActionButton = ElevatedButton(
                            onPressed: () {
                              final messageText = buildRentalRequestMessage();
                              ChatService.sendMessage(
                                widget.chatRoomId,
                                _myStudentNum!,
                                _receiverStudentNum!,
                                messageText,
                                type: 'rental',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff6DB129),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('대여 요청',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Pretender',
                                    fontWeight: FontWeight.w600)),
                          );
                        } else if (currentState == RentalState.approved) {
                          bottomActionButton = ElevatedButton(
                            onPressed: () {
                              ChatService.sendMessage(
                                widget.chatRoomId,
                                _myStudentNum!,
                                _receiverStudentNum!,
                                "반납을 요청하였습니다.\n 물품을 확인해주세요!",
                                type: 'rental',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('반납하기',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Pretender',
                                    fontWeight: FontWeight.w600)),
                          );
                        } else if (currentState == RentalState.returned ||
                            currentState == RentalState.completed) {
                          bottomActionButton = ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('반납하기',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Pretender',
                                    fontWeight: FontWeight.w600)),
                          );
                        } else {
                          bottomActionButton = ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('승인 대기',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Pretender',
                                    fontWeight: FontWeight.w600)),
                          );
                        }
                      } else if (_myStudentNum != widget.writerStudentNum) {
                        if (currentState == RentalState.requested) {
                          bottomActionButton = ElevatedButton(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final approverName =
                                  prefs.getString('nickname') ?? '작성자';
                              final messageText =
                                  buildRequestAllowMessage(approverName);

                              ChatService.sendMessage(
                                widget.chatRoomId,
                                _myStudentNum!,
                                _receiverStudentNum!,
                                messageText,
                                type: 'rental',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff97C663),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('승인',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Pretender',
                                    fontWeight: FontWeight.w600)),
                          );
                        } else if (currentState == RentalState.returned) {
                          bottomActionButton = ElevatedButton(
                            onPressed: () async {
                              ChatService.sendMessage(
                                widget.chatRoomId,
                                _myStudentNum!,
                                _receiverStudentNum!,
                                "반납이 완료되었습니다.",
                                type: 'rental',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('반납 완료',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Pretender',
                                    fontWeight: FontWeight.w600)),
                          );
                        } else {
                          bottomActionButton = SizedBox.shrink();
                        }
                      }
                      return bottomActionButton;
                    },
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey[300]),

            // 🔹 채팅 메시지 영역
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  reverse: false,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: groupedMessages.entries.map((entry) {
                    final date = entry.key;
                    final messages = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            date,
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Pretender',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        ...messages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final message = entry.value;
                          final timeText = message.sentAt != null
                              ? getFormattedTime(message.sentAt!)
                              : '';

                          final bool isPrevSystemMessage = index > 0 &&
                              (messages[index - 1]
                                      .content
                                      .contains("님이 대여를 승인했어요") ||
                                  messages[index - 1]
                                      .content
                                      .startsWith("반납이 완료되었습니다."));

                          final isSameAsPrevious = index > 0 &&
                              !isPrevSystemMessage &&
                              messages[index - 1].isMe == message.isMe;

                          final isSameAsNext = index < messages.length - 1 &&
                              messages[index + 1].isMe == message.isMe &&
                              messages[index + 1].sentAt != null &&
                              message.sentAt != null &&
                              messages[index + 1]
                                      .sentAt!
                                      .difference(message.sentAt!)
                                      .inMinutes <
                                  1;

                          final timeWidget = Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 6),
                            child: Text(
                              timeText,
                              style: TextStyle(
                                  color: Color(0xff625F5F), fontSize: 11),
                            ),
                          );

                          final bool isRentalRequest =
                              message.content.startsWith('대여를 요청하였습니다.');
                          final bool isReturnRequest =
                              message.content.startsWith('반납을 요청하였습니다.');
                          final bool isSystemMessage =
                              message.content.contains("님이 대여를 승인했어요") ||
                                  message.content.startsWith("반납이 완료되었습니다.");
                          if (isSystemMessage) {
                            final isApprovalMessage =
                                message.content.contains("님이 대여를 승인했어요");
                            final showPasswordButton = isApprovalMessage &&
                                !widget.isFaceToFace &&
                                _myStudentNum == widget.requesterStudentNum;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xffE7E9C7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        message.content,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff053C05),
                                        ),
                                      ),
                                    ),
                                    if (showPasswordButton)
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (context) => passwordPopup(
                                              rentalItemId: widget.rentalItemId,
                                              type: 'rental',
                                            ),
                                          );
                                        },
                                        child: Text(
                                          '비밀번호 확인',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 11,
                                            fontFamily: 'Pretender',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final messageBubble = Container(
                              margin: EdgeInsets.only(bottom: 5),
                              padding: (isRentalRequest || isReturnRequest)
                                  ? EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10)
                                  : EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: (isRentalRequest || isReturnRequest)
                                    ? Color(0xff606060)
                                    : (message.isMe
                                        ? Color(0xff6DB129)
                                        : Color(0xff8F8F8F)),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            (isRentalRequest || isReturnRequest)
                                                ? 17
                                                : 15,
                                        fontWeight:
                                            (isRentalRequest || isReturnRequest)
                                                ? FontWeight.w500
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    if ((isRentalRequest || isReturnRequest) &&
                                        _myStudentNum ==
                                            widget.writerStudentNum)
                                      Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 15),
                                            child: Builder(
                                              builder: (context) {
                                                final isApproved =
                                                    hasApprovalMessage();
                                                final isReturned =
                                                    hasReturnCompleteMessage();

                                                if (isRentalRequest) {
                                                  return isApproved
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          child: Text(
                                                            '승인 완료',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontFamily:
                                                                  'Pretender',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        )
                                                      : TextButton(
                                                          onPressed: () async {
                                                            if (!widget
                                                                .isFaceToFace) {
                                                              await showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (context) =>
                                                                        setPasswordPopup(
                                                                  postId: widget
                                                                      .rentalItemId,
                                                                  type:
                                                                      'rental',
                                                                ),
                                                              );
                                                            }
                                                            final prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            final nickname =
                                                                prefs.getString(
                                                                        'nickname') ??
                                                                    '작성자';
                                                            final messageText =
                                                                buildRequestAllowMessage(
                                                                    nickname);

                                                            final url = Uri.parse(
                                                                'http://54.79.35.255:8080/rental-item/${widget.rentalItemId}/rent/${widget.chatRoomId}');
                                                            final res =
                                                                await http
                                                                    .patch(url);

                                                            if (res.statusCode ==
                                                                200) {
                                                              print(
                                                                  '✅ 대여 처리 완료됨');
                                                            } else {
                                                              print(
                                                                  '❌ 대여 처리 실패: ${res.statusCode}');
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        '대여 처리 실패: ${res.statusCode}')),
                                                              );
                                                              return; // 실패하면 메시지 전송 안함
                                                            }

                                                            ChatService
                                                                .sendMessage(
                                                              widget.chatRoomId,
                                                              _myStudentNum!,
                                                              _receiverStudentNum!,
                                                              messageText,
                                                              type: 'rental',
                                                            );
                                                          },
                                                          child: Text(
                                                            '승인',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Pretender',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xffBCF69C),
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        );
                                                }
                                                if (isReturnRequest) {
                                                  return isReturned
                                                      ? Text(
                                                          '반납 완료',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontFamily:
                                                                'Pretender',
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 18,
                                                          ),
                                                        )
                                                      : TextButton(
                                                          onPressed: () async {
                                                            final url = Uri.parse(
                                                                'http://54.79.35.255:8080/rental-item/${widget.rentalItemId}/return/${widget.chatRoomId}');
                                                            final res =
                                                                await http
                                                                    .patch(url);

                                                            if (res.statusCode ==
                                                                200) {
                                                              print(
                                                                  '✅ 반납 처리 완료됨');
                                                            } else {
                                                              print(
                                                                  '❌ 반납 처리 실패: ${res.statusCode}');
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        '반납 처리 실패: ${res.statusCode}')),
                                                              );
                                                              return; // 실패하면 메시지 전송 안함
                                                            }

                                                            // ✅ 2. 메시지 전송
                                                            ChatService
                                                                .sendMessage(
                                                              widget.chatRoomId,
                                                              _myStudentNum!,
                                                              _receiverStudentNum!,
                                                              "반납이 완료되었습니다.",
                                                              type: 'rental',
                                                            );
                                                          },
                                                          child: Text(
                                                            '승인',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Pretender',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xffBCF69C),
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        );
                                                }
                                                return SizedBox.shrink();
                                              },
                                            ),
                                          )),
                                  ],
                                ),
                              ));

                          if (message.isMe) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isSystemMessage && !isSameAsNext)
                                      timeWidget,
                                    SizedBox(width: 5),
                                    messageBubble,
                                  ],
                                ),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isSameAsPrevious)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage: AssetImage(
                                            'assets/Profile/${_profileAssetName(_receiverProfileIndex)}'),
                                        backgroundColor: Colors.white,
                                      ),
                                    )
                                  else
                                    SizedBox(width: 60),
                                  Flexible(child: messageBubble),
                                  if (!isSameAsNext)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 7,
                                        top: 2,
                                      ),
                                      child: timeWidget,
                                    )
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            // 🔹 입력창
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: Color(0xffEBEBEB),
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xff97C663),
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: '메시지를 입력하세요...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 16),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xff97C663)),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final senderStudentNum =
                          prefs.getString('studentNum') ?? '';

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
                          _receiverStudentNum!,
                          text,
                          type: 'rental', // 🔥 꼭 전달!
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
