import 'package:flutter/material.dart';
import 'package:rentree/screen/Post/post_rental_Change.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Chat/chat_rental.dart';
import '../Chat/chatlist.dart';

class PostRentalScreen extends StatefulWidget {
  final int itemId;
  PostRentalScreen({required this.itemId});

  @override
  _PostRentalScreenState createState() => _PostRentalScreenState();
}

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerScreen(
      {Key? key, required this.imageUrls, required this.initialIndex})
      : super(key: key);

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;
    controller.addListener(() {
      if (controller.page != null) {
        setState(() {
          currentIndex = controller.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 37),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostRentalScreenState extends State<PostRentalScreen> {
  String title = '';
  String description = '';
  String nickname = '';
  List<String> imageUrls = [];
  bool isFaceToFace = true;
  DateTime? rentalStartTime;
  DateTime? rentalEndTime;
  String rentalTimeRangeText = '';
  DateTime? createdAt;
  String timeAgoText = '';
  bool isLoading = true;
  String? writerProfileImagePath;
  bool isLiked = false;
  int likeCount = 0;
  String? studentNum;
  bool likeChanged = false;
  String category = '';
  int currentImageIndex = 0;
  String writerStudentNum = '';
  int chatRoomCount = 0;
  int receiverProfileIndex = 1;
  int viewCount = 0;

  @override
  void initState() {
    super.initState();
    fetchItemDetail();
    fetchLikeStatus();
    fetchLikeCount();
  }

  void showChatRoomPopup(List<Map<String, dynamic>> chatRooms) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xffF4F1F1),
          title: Text("대화 중인 채팅",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
            content: SizedBox(
              width: double.maxFinite,
              child: chatRooms.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("대화 중인 채팅방이 없습니다."),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final room = chatRooms[index];
                        final nickname = room['requesterNickname'] ?? '알 수 없음';
                        final message = room['lastMessage'] ?? '';
                        final date = room['lastMessageDate'] ?? '';
                        final profileIndex = room['requesterProfileImage'] ?? 1;
                        final profilePath = 'assets/Profile/${_mapIndexToProfileFile(profileIndex)}';
                        final isWriterRequester = writerStudentNum == room['requesterStudentNum'];
                        final receiverProfileIndex = isWriterRequester
                            ? room['responderProfileImage']
                            : room['requesterProfileImage'];
                        return Card(
                          color: Color(0xffE7E9C8),
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/Profile/${_mapIndexToProfileFile(room['requesterProfileImage'] ?? 1)}',
                              ),
                              radius: 24,
                            ),
                            title: Text(
                              room['requesterNickname'] ?? '알 수 없음',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  room['lastMessage'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  room['lastMessageDate'] != null
                                      ? formatTimeDifference(DateTime.tryParse(room['lastMessageDate']) ?? DateTime.now())
                                      : '',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () {
                              final isWriterRequester = writerStudentNum == room['requesterStudentNum'];
                              final receiverProfileIndex = isWriterRequester
                                  ? room['responderProfileImage']
                                  : room['requesterProfileImage'];

                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRentalScreen(
                                    chatRoomId: room['roomId'],
                                    userName: isWriterRequester
                                        ? room['responderNickname']
                                        : room['requesterNickname'],
                                    imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : '',
                                    title: title,
                                    rentalItemId: widget.itemId,
                                    rentalTimeText: rentalTimeRangeText,
                                    isFaceToFace: isFaceToFace,
                                    writerStudentNum: writerStudentNum,
                                    requesterStudentNum: room['requesterStudentNum'],
                                    receiverStudentNum: isWriterRequester
                                        ? room['responderStudentNum']
                                        : room['requesterStudentNum'],
                                    receiverProfileIndex: receiverProfileIndex,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text("닫기", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
      },
    );
  }

  String formatTimeDifference(DateTime messageTime) {
    final now = DateTime.now().add(Duration(hours: 9)); // KST 보정
    final diff = now.difference(messageTime);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 30) return '${diff.inDays}일 전';
    final months = diff.inDays ~/ 30;
    if (months < 12) return '${months}달 전';
    return '${messageTime.year}.${messageTime.month.toString().padLeft(2, '0')}.${messageTime.day.toString().padLeft(2, '0')}';
  }

  String formatTo24Hour(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
        print('❌ 채팅방 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

  Future<void> fetchItemDetail() async {
    final baseUrl = 'http://10.0.2.2:8080/rental-item/${widget.itemId}';

    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        final imageRes = await http.get(
            Uri.parse('http://10.0.2.2:8080/images/api/item/${widget.itemId}'));
        if (imageRes.statusCode == 200) {
          final imageData = jsonDecode(utf8.decode(imageRes.bodyBytes));
          if (imageData.isNotEmpty) {
            imageUrls =
                imageData.map<String>((e) => e['imageUrl'].toString()).toList();
          }
        }

        setState(() {
          title = data['title'] ?? '제목 없음';
          description = data['description'] ?? '내용 없음';
          nickname = data['student']['nickname'] ?? '익명';
          isFaceToFace = data['isFaceToFace'] ?? true;
          createdAt = DateTime.parse(data['createdAt']);
          category = data['category']['name'] ?? '기타';
          final profileIndex = data['student']['profileImage'] ?? 1;
          writerProfileImagePath =
              'assets/Profile/${_mapIndexToProfileFile(profileIndex)}';
          receiverProfileIndex = profileIndex;
          writerStudentNum = data['student']['studentNum'] ?? '';
          viewCount = data['viewCount'] ?? 0;
          print('🧑‍🎓 writerStudentNum: $writerStudentNum');
          if (category == '양도(무료 나눔)' ||
              data['rentalStartTime'] == null ||
              data['rentalEndTime'] == null) {
            rentalTimeRangeText = '양도(무료 나눔)';
            rentalStartTime = null;
            rentalEndTime = null;
          } else {
            rentalStartTime = DateTime.parse(data['rentalStartTime']);
            rentalEndTime = DateTime.parse(data['rentalEndTime']);
            rentalTimeRangeText =
                '${formatTo24Hour(rentalStartTime!)} ~ ${formatTo24Hour(rentalEndTime!)}';
          }

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
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
    }
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
        likeChanged = true;
      });
    } else {
      print('❌ 좋아요 토글 실패');
    }
  }

  Future<Map<String, dynamic>?> getOrCreateChatRoom(
      int rentalItemId, String studentNum) async {
    final existingUrl =
        Uri.parse('http://10.0.2.2:8080/chatrooms/student/$studentNum');
    final existingRes = await http.get(existingUrl);

    if (existingRes.statusCode == 200) {
      final List<dynamic> existingRooms =
          jsonDecode(utf8.decode(existingRes.bodyBytes));
      for (var room in existingRooms) {
        if (room['type'] == 'rental' && room['relatedItemId'] == rentalItemId) {
          return {
            'chatRoomId': room['roomId'],
            'responderStudentNum': room['responderStudentNum'],
            'requesterStudentNum': room['requesterStudentNum'],
          };
        }
      }
    }

    final createUrl = Uri.parse(
      'http://10.0.2.2:8080/chatrooms/rental/$rentalItemId?requesterStudentNum=$studentNum',
    );
    final createRes = await http.post(createUrl);

    if (createRes.statusCode == 200) {
      final data = jsonDecode(utf8.decode(createRes.bodyBytes));
      return {
        'chatRoomId': data['roomId'],
        'responderStudentNum': data['responderStudentNum'], // ✅
      };
    }

    print('❌ 채팅방 생성 실패: ${createRes.statusCode}');
    print('❌ 응답 내용: ${createRes.body}');
    return null;
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
    final url = Uri.parse('http://10.0.2.2:8080/rental-item/${widget.itemId}');
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

  Widget buildImageSlider() {
    return Stack(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(viewportFraction: 1),
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(
                      imageUrls: imageUrls,
                      initialIndex: index,
                    ),
                  ),
                ),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
          ),
        ),
        if (imageUrls.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    imageUrls.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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
                  // 🔼 상단 이미지 + 뒤로가기 버튼
                  Stack(
                    children: [
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
                        child: imageUrls.isNotEmpty
                            ? buildImageSlider()
                            : Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new,
                              color: Colors.grey, size: 30),
                          onPressed: () => Navigator.pop(context, likeChanged),
                        ),
                      ),
                    ],
                  ),

                  // 🔽 스크롤 가능한 본문 영역
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
                        decoration: BoxDecoration(
                          color: Color(0xffE7E9C8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 작성자 + 타이틀
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // 변경된 코드
                                          if (writerStudentNum == studentNum)
                                            PopupMenuButton<String>(
                                              icon:
                                                  Icon(Icons.more_vert_rounded),
                                              onSelected: (String value) {
                                                if (value == 'change') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          rentalChangeScreen(
                                                              id: widget
                                                                  .itemId),
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
                                          else
                                            SizedBox.shrink(),
                                        ],
                                      ),
                                      SizedBox(height: 5),
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

                            // 설명
                            Container(
                              height: 200,
                              width: 400,
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
                            SizedBox(height: 10),

                            // 하단 정보 (관심, 카테고리, 시간)
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        '관심 $likeCount',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff747474)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(' | ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xff747474),
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        '조회 $viewCount',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff747474)),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '$category ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff747474),
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                      Text('| ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xff747474),
                                              fontWeight: FontWeight.bold)),
                                      Text(timeAgoText,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff747474))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔽 고정된 하단 좋아요/채팅 버튼
                  // 기존 버튼 부분 수정
                  Container(
                    margin: EdgeInsets.only(top: 3, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: toggleLike,
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 60,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                        (studentNum == writerStudentNum)
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff97C663),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(270, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                          onPressed: () async {
                            final url = Uri.parse('http://10.0.2.2:8080/chatrooms/student/$writerStudentNum');
                            final response = await http.get(url);
                            if (response.statusCode == 200) {
                              final List<dynamic> rooms = jsonDecode(utf8.decode(response.bodyBytes));
                              final filtered = rooms
                                  .where((room) => room['type'] == 'rental' && room['relatedItemId'] == widget.itemId)
                                  .toList()
                                  .cast<Map<String, dynamic>>();

                              // ✅ 마지막 메시지 추가 fetch
                              for (var room in filtered) {
                                final type = room['type'];
                                final roomId = room['roomId'];
                                final res = await http.get(Uri.parse('http://10.0.2.2:8080/chatmessages/$type/$roomId'));
                                if (res.statusCode == 200) {
                                  final List<dynamic> messages = jsonDecode(utf8.decode(res.bodyBytes));
                                  if (messages.isNotEmpty) {
                                    final lastMessage = messages.last;
                                    final rawSentAt = lastMessage['sentAt'];
                                    final trimmed = rawSentAt?.split('.')?.first ?? '';
                                    room['lastMessage'] = lastMessage['message'];
                                    room['lastMessageDate'] = trimmed;
                                  }
                                }
                              }

                              showChatRoomPopup(filtered);
                            } else {
                              print('❌ 채팅방 목록 조회 실패: ${response.statusCode}');
                            }
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
                                  minimumSize: Size(270, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
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
                                        builder: (context) => ChatRentalScreen(
                                          chatRoomId: chatRoomId,
                                          userName: nickname,
                                          imageUrl: imageUrls.isNotEmpty
                                              ? imageUrls[0]
                                              : '',
                                          title: title,
                                          rentalItemId: widget.itemId,
                                          rentalTimeText: rentalTimeRangeText,
                                          isFaceToFace: isFaceToFace,
                                          writerStudentNum: writerStudentNum,
                                          requesterStudentNum: studentNum,
                                          receiverStudentNum: studentNum ==
                                                  writerStudentNum
                                              ? result['requesterStudentNum']
                                              : writerStudentNum,
                                          receiverProfileIndex:
                                              receiverProfileIndex,
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
