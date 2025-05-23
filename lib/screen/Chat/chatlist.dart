// 채팅 목록 화면
import 'package:flutter/material.dart';
import 'package:rentree/screen/Point/point_first.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Home/home.dart';
import '../Like/likelist.dart';
import '../MyPage/mypage.dart';
import '../Notification/notification.dart';
import '../Point/point_second.dart';
import 'chat_rental.dart';
import 'chat_request.dart';
import '../login.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatListScreen> {
  int _selectedIndex = 3;
  List<dynamic> _chatRooms = [];
  bool isLoading = true;
  String? _myStudentNum;
  int selectedFilter = 0; // 0: 전체, 1: 대여글, 2: 요청글

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
    checkPenaltyAndForceLogout(context);
  }

  Future<void> checkPenaltyAndForceLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    if (studentNum == null) return;

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/penalties/$studentNum'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final isBanned = data['banned'];
      final penaltyScore = data['penaltyScore'];

      if (isBanned == true || penaltyScore >= 3) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Row(
              children: [
                Text("계정 정지 안내", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Image.asset(
                  'assets/redCard.png', // ← 경로 확인 필수
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            content: Text("페널티 누적으로 계정이 정지되었습니다.\n자동으로 로그아웃 됩니다."),
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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  Navigator.of(context).pop(); // 팝업 먼저 닫고

                  // pop 이후 반드시 context mounted 체크
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                    );
                  }
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }



  Future<void> _fetchChatRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    _myStudentNum = prefs.getString('studentNum');
    if (_myStudentNum == null) return;
    if (studentNum == null) return;
    final Map<String, Map<String, dynamic>> uniqueRooms = {};

    final url = Uri.parse('http://10.0.2.2:8080/chatrooms/student/$studentNum');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(utf8.decode(res.bodyBytes)); // ✅ 여기에 data 선언!

      for (var room in data) {
        print('📦 채팅방 ID: ${room['roomId']}');
        print('🧍 내 학번: $_myStudentNum');
        print('🧍 requesterStudentNum: ${room['requesterStudentNum']}');
        print('🧍 responderStudentNum: ${room['responderStudentNum']}');
        print('🚪 requesterExited: ${room['requesterExited']}');
        print('🚪 responderExited: ${room['responderExited']}');
        // ❗️숨기기 필터링 추가
        final requesterExited = room['requesterExited'] ?? false;
        final responderExited = room['responderExited'] ?? false;

        final isRequester = room['requesterStudentNum'] == _myStudentNum;
        final isResponder = room['responderStudentNum'] == _myStudentNum;

        print('📌 isRequester: $isRequester, isResponder: $isResponder');

        if ((isRequester && requesterExited) || (isResponder && responderExited)) {
          print('🚫 내가 나간 채팅방이므로 숨김: roomId=${room['roomId']}');
          continue; // 이 채팅방은 리스트에 추가하지 않음
        }

        final String uniqueKey = '${room['roomId']}_${room['type']}';
        if (uniqueRooms.containsKey(uniqueKey)) continue;
        uniqueRooms[uniqueKey] = room;
        print('📦 받은 채팅방 데이터: $room');
        print('📦 채팅방 room type: ${room['type']}');

        if (room['type'] == 'rental') {
          final itemId = room['relatedItemId'];

          // 이미지 가져오기
          final imageRes = await http
              .get(Uri.parse('http://10.0.2.2:8080/images/api/item/$itemId'));
          if (imageRes.statusCode == 200) {
            final images = jsonDecode(utf8.decode(imageRes.bodyBytes));
            if (images.isNotEmpty) {
              final rawUrl = images[0]['imageUrl'];
              room['imageUrl'] = rawUrl.toString().startsWith('http')
                  ? rawUrl
                  : 'http://10.0.2.2:8080$rawUrl';
            }
          }

          // 상세 정보 가져오기
          final itemRes = await http
              .get(Uri.parse('http://10.0.2.2:8080/rental-item/$itemId'));
          if (itemRes.statusCode == 200) {
            final itemData = jsonDecode(utf8.decode(itemRes.bodyBytes));
            final start = itemData['rentalStartTime'];
            final end = itemData['rentalEndTime'];

            room['writerNickname'] = itemData['student']?['nickname'] ?? '작성자';
            room['writerStudentNum'] = itemData['student']?['studentNum'] ?? '';
            room['isFaceToFace'] = itemData['isFaceToFace'];
            room['rentalItemTitle'] = itemData['title'] ?? '제목 없음';

            if (start != null && end != null) {
              final startDt = DateTime.parse(start);
              final endDt = DateTime.parse(end);
              final startStr =
                  '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';
              final endStr =
                  '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';
              room['rentalTimeText'] = '$startStr ~ $endStr';
            } else {
              room['rentalTimeText'] = '양도(무료 나눔)';
            }
          }
        } else {
          // 요청글일 경우 이미지 고정
          room['imageUrl'] = 'assets/requestIcon.png';
          // ✅ 요청글 제목 가져오기
          final itemId = room['relatedItemId'];

          final itemRes = await http
              .get(Uri.parse('http://10.0.2.2:8080/ItemRequest/$itemId'));
          if (itemRes.statusCode == 200) {
            final itemData = jsonDecode(utf8.decode(itemRes.bodyBytes));
            room['itemRequestTitle'] = itemData['title'] ?? '제목 없음';
            room['writerNickname'] = itemData['student']['nickname'] ?? '작성자';
            room['writerStudentNum'] = itemData['student']['studentNum'] ?? '';
            room['isFaceToFace'] = itemData['isFaceToFace'];

            // ✅ 여기 추가: 대여 시간 포맷팅
            final start = itemData['rentalStartTime'];
            final end = itemData['rentalEndTime'];
            if (start != null && end != null) {
              final startDt = DateTime.parse(start);
              final endDt = DateTime.parse(end);
              final startStr =
                  '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';
              final endStr =
                  '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';
              room['rentalTimeText'] = '$startStr ~ $endStr';
            } else {
              room['rentalTimeText'] = '시간 정보 없음';
            }
          }
        }

        final raw = await getLastMessageForRoom(room['roomId'], room['type']);
        if (raw != null) {
          final parsed = jsonDecode(raw);

          final rawSentAt = parsed['sentAt'];
          if (rawSentAt != null) {
            final trimmed = rawSentAt.split('.').first;
            final fixedSentAt = '$trimmed.000';
            room['lastMessageTime'] = fixedSentAt;
          } else {
            room['lastMessageTime'] = room['createdAt'];
          }

          room['lastMessage'] = parsed['message'];

          // 🔥 이 시점 이후에 로그 찍기
          print("🕒 마지막 메시지 시간(raw): $rawSentAt");
          print("📅 최종 lastMessageTime raw: ${room['lastMessageTime']}");
          final parsedDate =
              DateTime.tryParse(room['lastMessageTime'] ?? room['createdAt']);
          print("📅 파싱된 DateTime: $parsedDate");
          print("⏰ 현재 시각: ${DateTime.now()}");
          print("🕓 메시지 시각: $parsedDate");
        }
      }

      final deduplicatedList = uniqueRooms.values.toList();
      deduplicatedList.sort((a, b) {
        final aDate = DateTime.parse(a['lastMessageTime'] ?? a['createdAt']);
        final bDate = DateTime.parse(b['lastMessageTime'] ?? b['createdAt']);
        return bDate.compareTo(aDate);
      });
      setState(() {
        _chatRooms = deduplicatedList;
        isLoading = false;
      });
    } else {
      print('❌ 채팅방 목록 불러오기 실패: ${res.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> getLastMessageForRoom(int chatRoomId, String type) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/chatmessages/$type/$chatRoomId');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> messages = jsonDecode(utf8.decode(res.bodyBytes));
      print("📨 [$chatRoomId] 받은 메시지 목록: $messages");

      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        // 👉 추가
        final lastTime = lastMessage['sentAt'];
        return jsonEncode({
          'message': lastMessage['message'],
          'sentAt': lastTime,
        });
      }
    }
    return null;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // 홈 화면
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case 1:
        // 찜 목록
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LikeScreen()),
        );
        break;
      case 2:
        // 포인트
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PointedScreen()),
        );
        break;
      case 3:
        // 채팅
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatListScreen()),
        );
        break;
      case 4:
        // 마이페이지
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MypageScreen()),
        );
        break;
      default:
        setState(() {
          _selectedIndex = index;
        });
    }
  }

  String formatTimeDifference(DateTime messageTime) {
    final now = DateTime.now().add(Duration(hours: 9)); // KST로 보정

    print('🧪 formatTimeDifference - now: $now, messageTime: $messageTime');
    final diff = now.difference(messageTime);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 30) return '${diff.inDays}일 전';
    final months = diff.inDays ~/ 30;
    if (months < 12) return '${months}달 전';
    return '${messageTime.year}.${messageTime.month.toString().padLeft(2, '0')}.${messageTime.day.toString().padLeft(2, '0')}';
  }

  String formatDateTime(String dateTimeStr) {
    final dt = DateTime.parse(dateTimeStr);
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  List<dynamic> get _filteredChatRooms {
    switch (selectedFilter) {
      case 1: // 대여글
        return _chatRooms.where((room) => room['type'] == 'rental').toList();
      case 2: // 요청글
        return _chatRooms.where((room) => room['type'] == 'request').toList();
      default:
        return _chatRooms;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (알림, 검색 포함)
            Container(
              color: Color(0xffF4F1F1),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '채팅',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          color: Color(0xff97C663),
                          iconSize: 35,
                          padding: EdgeInsets.only(left: 10),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NotificationScreen()), // notification.dart에서 NotificationScreen 클래스로 변경
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(3, (index) {
                  final labels = ['전체', '대여글', '요청글'];
                  final isSelected = selectedFilter == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = index;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? Color(0xff97C663) : Colors.grey[300],
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(labels[index]),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _chatRooms.isEmpty
                      ? Center(child: Text('채팅 목록이 없습니다.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredChatRooms.length,
                          itemBuilder: (context, index) {
                            final room = _filteredChatRooms[index];
                            print(
                                '✅ writerNickname: ${room['writerNickname']}');
                            print(
                                '✅ requesterNickname: ${room['requesterNickname']}');
                            print(
                                '✅ writerStudentNum: ${room['writerStudentNum']}');
                            print('✅ 내 학번: $_myStudentNum');
                            print(
                                'requesterProfileImage: ${room['requesterProfileImage']}');
                            print(
                                'responderProfileImage: ${room['responderProfileImage']}');
                            final opponentNickname =
                                (_myStudentNum == room['writerStudentNum'])
                                    ? (room['requesterNickname'] ?? '(알수없음)')
                                    : (room['writerNickname'] ?? '(알수없음)');
                            final title = room['relatedItemTitle'];
                            return GestureDetector(
                              onTap: () {
                                if (room['type'] == 'rental') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRentalScreen(
                                        chatRoomId: room['roomId'] ?? -1,
                                        userName: (_myStudentNum == room['writerStudentNum'])
                                            ? (room['requesterNickname'] ?? '(알수없음)')
                                            : (room['writerNickname'] ?? '(알수없음)'),
                                        title: room['rentalItemTitle'] ?? '삭제된 글입니다.',
                                        rentalItemId: room['relatedItemId'] ?? -1,
                                        rentalTimeText: room['rentalTimeText'] ?? '시간 정보 없음',
                                        isFaceToFace: room['isFaceToFace'] ?? true,
                                        imageUrl: room['imageUrl'] ?? '',
                                        writerStudentNum: room['writerStudentNum'] ?? ' ',
                                        requesterStudentNum: room['requesterStudentNum'] ?? '',
                                        receiverStudentNum: (_myStudentNum == room['writerStudentNum'])
                                            ? (room['requesterStudentNum'] ?? '')
                                            : (room['writerStudentNum'] ?? ''),
                                        receiverProfileIndex: (_myStudentNum == room['writerStudentNum'])
                                            ? (room['requesterProfileImage'] ?? 1)
                                            : (room['responderProfileImage'] ?? 1),
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result is Map && result.containsKey('lastMessageTime')) {
                                      setState(() {
                                        room['lastMessageTime'] =
                                            (result['lastMessageTime'] as DateTime).toIso8601String();
                                        room['lastMessage'] = result['lastMessage'] ?? '';
                                      });
                                    } else if (result == true) {
                                      _fetchChatRooms(); // 삭제 등으로 인해 새로고침 필요
                                    }
                                  });

                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRequestScreen(
                                        chatRoomId: room['roomId'] ?? -1,
                                        userName: (_myStudentNum == (room['writerStudentNum'] ?? ''))
                                            ? (room['requesterNickname'] ?? '(알수없음)')
                                            : (room['writerNickname'] ?? '(알수없음)'),
                                        title: room['itemRequestTitle'] ?? '삭제된 글입니다.',
                                        requestId: room['relatedItemId'] ?? -1,
                                        writerStudentNum: room['writerStudentNum'] ?? '',
                                        requesterStudentNum: room['requesterStudentNum'] ?? '',
                                        receiverStudentNum: (_myStudentNum == (room['writerStudentNum'] ?? ''))
                                            ? (room['requesterStudentNum'] ?? '')
                                            : (room['writerStudentNum'] ?? ''),
                                        rentalTimeText: room['rentalTimeText'] ?? '시간 정보 없음',
                                        isFaceToFace: room['isFaceToFace'] ?? true,
                                        receiverProfileIndex: (_myStudentNum == (room['writerStudentNum'] ?? ''))
                                            ? (room['requesterProfileImage'] ?? 1)
                                            : (room['responderProfileImage'] ?? 1),
                                      ),
                                    ),
                                  ).then((result) {
                                    if (result != null && result is Map && result.containsKey('lastMessageTime')) {
                                      setState(() {
                                        room['lastMessageTime'] = (result['lastMessageTime'] as DateTime).toIso8601String();
                                        room['lastMessage'] = result['lastMessage'] ?? '';
                                      });
                                    } else if (result == true) {
                                      _fetchChatRooms();
                                    }
                                  });
                                }
                              },
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16), // 🔼 더 여유 있게
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // 물품 이미지
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: (room['type'] == 'rental' && room['imageUrl'] != null)
                                              ? Image.network(
                                            room['imageUrl'],
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/box.png',
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                              : Image.asset(
                                            room['type'] == 'rental'
                                                ? 'assets/box.png'
                                                : 'assets/requestIcon.png',
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        SizedBox(width: 16), // 🔼 이미지-텍스트 간격 넓힘
                                        // 텍스트 정보
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    opponentNickname ?? '(알수없음)',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    title ?? '삭제된 글입니다.',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xff7c7c7c),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(' | ',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff7c7c7c),
                                                          fontSize: 13)),
                                                  Text(
                                                    formatTimeDifference(
                                                      DateTime.tryParse(room[
                                                                  'lastMessageTime'] ??
                                                              room[
                                                                  'createdAt']) ??
                                                          DateTime.now(),
                                                    ),
                                                    style: TextStyle(
                                                      color: Color(0xff7c7c7c),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                room['lastMessage'] ?? '메시지 없음',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 날짜
                                      ],
                                    ),
                                  ),
                                  Divider(height: 1, color: Colors.grey[300]),
                                ],
                              ),
                            );
                          }),
            ),
          ],
        ),
      ),

      // 🔥 하단 네비게이션 바
      bottomNavigationBar: Container(
        color: Color(0xffEBEBEB), // 배경색 유지
        padding: const EdgeInsets.only(bottom: 5),
        child: BottomNavigationBar(
          backgroundColor: Color(0xffEBEBEB),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: Color(0xff97C663),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 27), label: '홈'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite, size: 27), label: '찜'),
            BottomNavigationBarItem(
                icon: Icon(Icons.control_point_duplicate_rounded, size: 27),
                label: '포인트'),
            BottomNavigationBarItem(
                icon: Icon(Icons.messenger_outline_rounded, size: 27),
                label: '채팅'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 27), label: '마이페이지'),
          ],
        ),
      ),
    );
  }
}
