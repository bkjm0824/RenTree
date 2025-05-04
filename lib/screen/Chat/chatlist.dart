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
import '../Search/search.dart';
import 'chat.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatListScreen> {
  int _selectedIndex = 3;
  List<dynamic> _chatRooms = [];
  bool isLoading = true;
  String? _myStudentNum;

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');
    _myStudentNum = prefs.getString('studentNum');
    if (_myStudentNum == null) return;
    if (studentNum == null) return;

    final url = Uri.parse('http://10.0.2.2:8080/chatrooms/student/$studentNum');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes)); // ✅ 여기에 data 선언!

      for (var room in data) {
        print('📦 받은 채팅방 데이터: $room');
        if (room['rentalItemId'] != null) {
          final itemId = room['rentalItemId'];
          final imageRes = await http.get(Uri.parse('http://10.0.2.2:8080/images/api/item/$itemId'));
          final itemRes = await http.get(Uri.parse('http://10.0.2.2:8080/rental-item/$itemId'));

          if (imageRes.statusCode == 200) {
            final images = jsonDecode(utf8.decode(imageRes.bodyBytes));
            if (images.isNotEmpty) {
              room['imageUrl'] = 'http://10.0.2.2:8080${images[0]['imageUrl']}';
            }
          }

          if (itemRes.statusCode == 200) {
            final itemData = jsonDecode(utf8.decode(itemRes.bodyBytes));

            final start = itemData['rentalStartTime'];
            final end = itemData['rentalEndTime'];
            final isFaceToFace = itemData['isFaceToFace'] ?? true;
            final writerNickname = itemData['student']?['nickname'] ?? '작성자';

            room['writerNickname'] = writerNickname;
            room['writerStudentNum'] = itemData['student']?['studentNum'] ?? '';
            room['responderStudentNum'] = room['responderStudentNum'] ?? room['responderStudentNum'];
            if (start != null && end != null) {
              final startDt = DateTime.parse(start);
              final endDt = DateTime.parse(end);
              final startStr = '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';
              final endStr = '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';
              room['rentalTimeText'] = '$startStr ~ $endStr';
            } else {
              room['rentalTimeText'] = '양도(무료 나눔)';
            }

            room['isFaceToFace'] = isFaceToFace;
            room['rentalItemTitle'] = itemData['title'] ?? '제목 없음'; // 안전하게
          }
        }
        final lastMsg = await getLastMessageForRoom(room['roomId']);
        room['lastMessage'] = lastMsg ?? '메시지 없음';
      }

      data.sort((a, b) {
        final aDate = DateTime.parse(a['lastMessageTime'] ?? a['createdAt']);
        final bDate = DateTime.parse(b['lastMessageTime'] ?? b['createdAt']);
        return bDate.compareTo(aDate); // 최신 메시지 순
      });

      setState(() {
        _chatRooms = data;
        isLoading = false;
      });
    } else {
      print('❌ 채팅방 목록 불러오기 실패: ${res.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> getLastMessageForRoom(int chatRoomId) async {
    final url = Uri.parse('http://10.0.2.2:8080/chatmessages/room/$chatRoomId');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      final List<dynamic> messages = jsonDecode(utf8.decode(res.bodyBytes));
      if (messages.isNotEmpty) {
        final lastMessage = messages.last; // 시간순 정렬되어 있다고 가정
        return lastMessage['message'];
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
          MaterialPageRoute(builder: (context) => PointScreen()),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_rounded),
                        color: Color(0xff97C663),
                        iconSize: 30,
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
                      Text(
                        '채팅 목록',
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchScreen()), // SearchScreen으로 이동
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(height: 1, color: Colors.grey[300]), // 구분선
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _chatRooms.isEmpty
                  ? Center(child: Text('채팅 목록이 없습니다.'))
                  : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = _chatRooms[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              chatRoomId: room['roomId'],
                              userName: (_myStudentNum == room['writerStudentNum'])
                                  ? room['requesterNickname']
                                  : room['writerNickname'],
                              title: room['rentalItemTitle'] ?? '제목 없음',
                              rentalTimeText: room['rentalTimeText'] ?? '시간 정보 없음',
                              isFaceToFace: room['isFaceToFace'] ?? true,
                              imageUrl: room['imageUrl'] ?? '',
                              writerStudentNum: room['writerStudentNum'] ?? '',
                              requesterStudentNum: room['requesterStudentNum'] ?? '', // 👈 수정 필수
                              receiverStudentNum: (_myStudentNum == room['writerStudentNum'])
                                  ? room['requesterStudentNum']
                                  : room['writerStudentNum'], // 🔥🔥🔥 가장 중요한 수정!
                            ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            _fetchChatRooms(); // ✅ pop(true)로 돌아왔을 때 새로고침
                          }
                        });
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16), // 🔼 더 여유 있게
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 물품 이미지
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: room['imageUrl'] != null
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
                                    'assets/box.png',
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16), // 🔼 이미지-텍스트 간격 넓힘
                                // 텍스트 정보
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room['writerNickname'] ?? '익명',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17), // 🔼 폰트 크기
                                      ),
                                      SizedBox(height: 6), // 🔼 간격 조금 더 줌
                                      Text(
                                        room['rentalItemTitle'] ?? '제목 없음',
                                        style: TextStyle(fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        room['lastMessage'] ?? '메시지 없음',
                                        style: TextStyle(fontSize: 13, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                // 날짜
                                Text(
                                  room['createdAt'].toString().substring(5, 10),
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey[300]),
                        ],
                      ),
                    );
                  }
              ),
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

