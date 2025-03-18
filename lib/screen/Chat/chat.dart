// 채팅 화면
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  final String userName;

  ChatDetailScreen({required this.userName});
  TextEditingController _messageController = TextEditingController(); // 🔹 입력 필드 컨트롤러
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (뒤로가기 포함)
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
                          Navigator.pop(context); // 🔥 뒤로 가기
                        },
                      ),
                      Text(
                        userName, // 🔹 선택한 유저의 이름 표시
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
                  Container(height: 1, color: Colors.grey[300]), // 구분선
                ],
              ),
            ),

            // 🔹 상품 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // 상품 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/box.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16), // 🔹 이미지와 텍스트 사이 간격

                  // 🔹 상품 정보 (상품명 + 대여 정보)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '상품1', // 🔥 상품명 (예제)
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5), // 🔹 간격 추가
                      Text(
                        '대여 가능 시간: 3시간 | 대면', // 🔥 대여 정보
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600], // 🔹 회색 텍스트
                        ),
                      ),
                    ],
                  ),

                  Spacer(), // 🔹 버튼을 오른쪽으로 밀어줌

                  // 🔥 대여 요청 버튼
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 대여 요청 기능 추가
                      print('대여 요청 버튼 클릭됨');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff97C663), // 초록색 버튼
                      foregroundColor: Colors.white, // 흰색 텍스트
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 🔹 버튼 모서리 둥글게
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

            Divider(height: 1, color: Colors.grey[300]), // 🔹 구분선 추가

            // 채팅 내용
            Expanded(
              child: Center(
                child: Text(
                  '$userName 님과의 채팅 화면',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            // 🔥 채팅 입력창 (하단에 고정)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1), // 상단 구분선
                ),
              ),
              child: Row(
                children: [
                  // 🔹 + 버튼 (왼쪽)
                  IconButton(
                    icon: Icon(Icons.add, color: Color(0xff97C663)),
                    onPressed: () {
                      print("추가 버튼 클릭됨");
                    },
                  ),

                  // 🔹 텍스트 입력 필드
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),

                  // 🔹 전송 버튼 (아이콘, 오른쪽)
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xff97C663)), // 초록색 아이콘
                    onPressed: () {
                      print("메시지 전송: ${_messageController.text}");
                      _messageController.clear(); // 입력 필드 초기화
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
