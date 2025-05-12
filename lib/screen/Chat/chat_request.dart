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
  final String rentalTimeText;
  final bool isFaceToFace;
  final int receiverProfileIndex;

  ChatRequestScreen({
    required this.userName,
    required this.chatRoomId,
    required this.writerStudentNum,
    required this.requesterStudentNum,
    required this.receiverStudentNum,
    required this.requestId,
    required this.title,
    required this.rentalTimeText,
    required this.isFaceToFace,
    required this.receiverProfileIndex,
  });

  @override
  _ChatRequestScreenState createState() => _ChatRequestScreenState();
}

enum RentalState { idle, requested, approved, returned, completed }

class _ChatRequestScreenState extends State<ChatRequestScreen> {
  TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  String? _myStudentNum;
  String? _receiverStudentNum;
  int _receiverProfileIndex = 1;
  Set<String> _completedReturnMessageTimes = {};
  RentalState _currentState = RentalState.idle;

  @override
  void initState() {
    super.initState();
    _receiverProfileIndex = widget.receiverProfileIndex;
    _loadStudentNumAndConnect();
    _loadPreviousMessages();
  }

  void _updateRentalState() {
    setState(() {
      _currentState = _calculateRentalState();
    });
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
        // try-catch로 안전하게 감싸기
        try {
          if (mounted) {
            setState(() {
              _messages.add(message);
            });
            _updateRentalState();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        } catch (e) {
          print("⚠️ setState 에러 발생: $e");
        }
      },
    );
  }

  Future<void> _loadPreviousMessages() async {
    final url = Uri.parse(
        'http://10.0.2.2:8080/chatmessages/request/${widget.chatRoomId}');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final studentNum = prefs.getString('studentNum') ?? '';
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));

      setState(() {
        _messages =
            data.map((json) => ChatMessage.fromJson(json, studentNum)).toList();
      });
      _updateRentalState();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
      builder: (context) => AlertDialog(
        title: Text('채팅방 나가기'),
        content: Text('정말 이 채팅방을 나가시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('취소')),
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
    final url =
        Uri.parse('http://10.0.2.2:8080/chatrooms/${widget.chatRoomId}');
    final res = await http.delete(url);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('채팅방이 삭제되었습니다.')));
      Navigator.of(context).pop(true);
    }
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

  String buildRequestAllowMessage(String approverName) {
    return "$approverName 님이 대여를 승인했어요. 반납시간을 잘 지켜주세요!";
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

  String buildRentalRequestMessage() {
    final now = DateTime.now();
    final dateText = "${now.year}년 ${now.month}월 ${now.day}일";
    final timeRange = widget.rentalTimeText;
    final faceToFace = widget.isFaceToFace ? "대면" : "비대면";
    return "대여를 요청하였습니다.\n$dateText\n$timeRange\n대여방식 : $faceToFace";
  }

  bool isReturnRequestCompleted(ChatMessage requestMessage) {
    final requestTime = requestMessage.sentAt;
    if (requestTime == null) return false;

    // 반납 완료 메시지가 반납 요청 이후에 있는지 확인
    return _messages.any((msg) =>
        msg.content.contains('반납이 완료되었습니다.') &&
        msg.sentAt != null &&
        msg.sentAt!.isAfter(requestTime));
  }

  bool hasReturnCompleteMessage() {
    return _messages.any((msg) => msg.content.contains('반납이 완료되었습니다.'));
  }

  bool hasApprovalMessage() {
    return _messages.any((msg) => msg.content.contains('대여를 승인했어요'));
  }

  Widget buildBottomButton(RentalState state) {
    if (_myStudentNum != widget.writerStudentNum) return SizedBox.shrink();

    if (state == RentalState.idle) {
      return ElevatedButton(
        onPressed: () {
          final messageText = buildRentalRequestMessage();
          ChatService.sendMessage(
            widget.chatRoomId,
            _myStudentNum!,
            _receiverStudentNum!,
            messageText,
            type: 'request',
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff6DB129),
          foregroundColor: Colors.white,
        ),
        child: Text('대여 요청'),
      );
    } else if (state == RentalState.approved) {
      return ElevatedButton(
        onPressed: () {
          ChatService.sendMessage(
            widget.chatRoomId,
            _myStudentNum!,
            _receiverStudentNum!,
            "반납을 요청하였습니다.",
            type: 'request',
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: Text('반납하기'),
      );
    } else if (state == RentalState.returned ||
        state == RentalState.completed) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
        ),
        child: Text('반납하기'),
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
        ),
        child: Text('대여 요청'),
      );
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
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(left: 10),
                        onPressed: () {
                          Navigator.pop(
                              context, true); // ✅ 무조건 true로 반환해서 새로고침 유도
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
                              fontWeight: FontWeight.bold,
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
                  Divider(height: 1, color: Colors.grey[300]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // ✅ Row는 children 리스트 사용
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostRequestScreen(itemId: widget.requestId),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/requestIcon.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    // ✅ 글자가 넘치지 않게 Column을 Expanded로 감싸기
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          '대여시간: ${widget.rentalTimeText} | ${widget.isFaceToFace ? '대면' : '비대면'}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Builder(
                    builder: (context) {
                      Widget bottomActionButton = SizedBox.shrink();

                      if (_myStudentNum == widget.writerStudentNum) {
                        if (_currentState == RentalState.idle) {
                          bottomActionButton = ElevatedButton(
                            onPressed: () {
                              final messageText = buildRentalRequestMessage();
                              ChatService.sendMessage(
                                widget.chatRoomId,
                                _myStudentNum!,
                                _receiverStudentNum!,
                                messageText,
                                type: 'request',
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
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          );
                        } else if (_currentState == RentalState.approved) {
                          bottomActionButton = ElevatedButton(
                            onPressed: () {
                              ChatService.sendMessage(
                                widget.chatRoomId,
                                _myStudentNum!,
                                _receiverStudentNum!,
                                "반납을 요청하였습니다.",
                                type: 'request',
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
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          );
                        } else if (_currentState == RentalState.returned ||
                            _currentState == RentalState.completed) {
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
                                    fontSize: 14, fontWeight: FontWeight.bold)),
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
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                          );
                        }
                      }

                      return bottomActionButton;
                    },
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey[300]),

            // 채팅 메시지 목록
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
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...messages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final message = entry.value;
                          final timeText = message.sentAt != null
                              ? getFormattedTime(message.sentAt!)
                              : '';

                          final isSameAsPrevious = index > 0 &&
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
                                  message.content.contains("반납이 완료되었습니다.");
                          if (isSystemMessage) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xffE7E9C7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                child: Center(
                                  child: Text(
                                    message.content,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xff053C05),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          final messageBubble = Container(
                              margin: EdgeInsets.only(bottom: 5),
                              padding: (isRentalRequest || isReturnRequest)
                                  ? EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15)
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
                                            widget.requesterStudentNum)
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
                                                                vertical: 8.0),
                                                        child: Text(
                                                          '승인 완료',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey, // ✅ 바꿔줘
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      )
                                                    : TextButton(
                                                        onPressed: () async {
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

                                                          ChatService
                                                              .sendMessage(
                                                            widget.chatRoomId,
                                                            _myStudentNum!,
                                                            _receiverStudentNum!,
                                                            messageText,
                                                            type: 'request',
                                                          );
                                                        },
                                                        child: Text(
                                                          '승인',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xffBCF69C),
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      );
                                              }

                                              if (isReturnRequest) {
                                                return isReturnRequestCompleted(
                                                        message)
                                                    ? Text(
                                                        '반납 완료',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey, // ✅ 이 부분도 바꿔줘
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      )
                                                    : TextButton(
                                                        onPressed: () async {
                                                          print(
                                                              widget.requestId);
                                                          // ✅ 1. 서버에 반납 완료 요청
                                                          final url = Uri.parse(
                                                              'http://10.0.2.2:8080/itemrequest/${widget.requestId}/return');
                                                          final res = await http
                                                              .post(url);

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
                                                          ChatService
                                                              .sendMessage(
                                                            widget.chatRoomId,
                                                            _myStudentNum!,
                                                            _receiverStudentNum!,
                                                            "반납이 완료되었습니다.",
                                                            type: 'request',
                                                          );
                                                        },
                                                        child: Text(
                                                          '승인',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                        ),
                                      ),
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
                          type: 'request', // 🔥 꼭 전달!
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
