// 알림 화면
import 'package:flutter/material.dart';
import 'notification_keyword.dart';
import '../post.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  // 알림 데이터 예시
  final List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "title": "상상북스딱스님과의 대여 후기를 남겨보세요!",
      "itemTitle": "충전기",
      "imageUrl": "assets/choongjeonki.png"
    },
    {
      "id": 2,
      "title": "교환 완료! 리뷰를 작성해보세요!",
      "itemTitle": "우산",
      "imageUrl": "assets/box.png"
    },
    {
      "id": 3,
      "title": "홍길동님의 물품이 반납되었습니다.",
      "itemTitle": "책가방",
      "imageUrl": "assets/box.png"
    },
    {
      "id": 4,
      "title": "이용 감사드립니다!",
      "itemTitle": "보조배터리",
      "imageUrl": "assets/box.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (뒤로가기, 설정, 삭제 버튼)
            Container(
              color: Color(0xffF4F1F1),
              child: Column(
                children: [
                  SizedBox(height: 15),
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            color: Color(0xff97C663),
                            iconSize: 30,
                            padding: EdgeInsets.only(left: 10),
                            onPressed: () {
                              Navigator.pop(context); // 🔥 뒤로 가기
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.settings), // 설정 아이콘
                                color: Color(0xff97C663),
                                iconSize: 30,
                                onPressed: () {
                                  // 설정 버튼 클릭 로직 추가
                                  _showSettingsMenu(context); // 🔥 설정 메뉴 호출
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Color(0xff97C663),
                                iconSize: 30,
                                padding: EdgeInsets.only(right: 10),
                                onPressed: () {
                                  // 알림 삭제하는 로직 추가
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '알림',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 1, color: Colors.grey[300]), // 구분선
                ],
              ),
            ),


            // 🔥 리스트뷰
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostScreen(itemId: item['id']),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    item['imageUrl'],
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image_not_supported,
                                            color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      SizedBox(height: 4),
                                      Text(item['itemTitle'],
                                          style: TextStyle(color: Colors.grey[700])),
                                      SizedBox(height: 8),
                                    ],
                                  ),
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
            )
          ],
        ),
      ),
    );
  }

  // 설정 메뉴 호출하는 함수
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용만큼 높이 조정
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 18), // 왼쪽 여백 추가
                    child: Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Color(0xff97C663)),
                title: Text('알림 설정'),
                onTap: () {
                  // 알림 설정 화면 이동 또는 로직 추가
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_suggest, color: Color(0xff97C663)),
                title: Text('키워드 설정'),
                onTap: () {
                  // 키워드 설정 화면으로 이동
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationKeywordScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
