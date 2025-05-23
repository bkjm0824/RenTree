// 고객 지원
import 'package:flutter/material.dart';

import '../Home/home.dart';

class MyPageCustomerSupport extends StatelessWidget {

  final List<Map<String, String>> faqList = [
    {
      "question": "Q. 학번이 아니어도 가입할 수 있나요?",
      "answer": "현재는 학교 학생 인증을 위해 학번 기반으로만 가입 가능합니다."
    },
    {
      "question": "Q. 글은 어떻게 작성하나요?",
      "answer": "홈 화면에서 '+' 버튼을 눌러 원하는 글을 작성할 수 있습니다."
    },
    {
      "question": "Q. 대여 요청은 어떻게 하나요?",
      "answer": "대여하고 싶은 물품의 상세 페이지에서 '채팅하기'를 통해 작성자에게 대여 요청할 수 있습니다."
    },
    {
      "question": "Q. 반납은 어떻게 하나요?",
      "answer": "채팅방에서 '반납하기' 버튼을 눌러 반납 요청을 보내세요. 상대방이 반납을 승인해줘야 반납이 완료됩니다."
    },
    {
      "question": "Q. 대여 기간은 어떻게 정해지나요?",
      "answer": "글 작성자가 설정한 시간에 따라 자동으로 계산되며, 채팅을 통해 협의 가능합니다."
    },
    {
      "question": "Q. 상추는 어떻게 적립되나요?",
      "answer": "반납이 완료된 시점에 자동으로 대여해준 사용자에게 상추 10장이 지급됩니다."
    },
    {
      "question": "Q. 상추는 어디에 사용하나요?",
      "answer": "포인트 화면 하단에 포인트 교환소에서 다양한 상품과 교환 가능합니다."
    },
    {
      "question": "Q. 상대방이 시간을 어겼어요.",
      "answer": "반납 시간이 지났음에도 반납하지 않으면 페널티가 1점이 부과됩니다."
    },
    {
      "question": "Q. 계정이 정지되었어요.",
      "answer": "페널티가 3점이 되면 계정이 일시적으로 정지됩니다."
    },
    {
      "question": "Q. 누적된 페널티는 어디서 볼 수 있나요?",
      "answer": "페널티가 누적된 만큼 본인의 이름 옆에 옐로카드가 표시됩니다."
    },
    {
      "question": "Q. 문제 생긴 경우 어디에 문의드리나요?",
      "answer": "Rentree@gmail.com으로 문의 부탁드립니다."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1), // 전체 배경색 설정
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바 (뒤로가기, 홈 버튼)
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
                        '고객 지원',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.home),
                        color: Color(0xff97C663),
                        iconSize: 30,
                        padding: EdgeInsets.only(right: 10),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          ); // 🔥 홈으로 이동
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Container(height: 1, color: Colors.grey[300]), // 구분선
                ],
              ),
            ),

            SizedBox(height: 20), // 상단바와 정보 사이 간격

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '자주 묻는 질문',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: faqList.length,
                itemBuilder: (context, index) {
                  final faq = faqList[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ExpansionTile(
                      iconColor: Color(0xff97C663),              // 펼쳐졌을 때 아이콘 색
                      collapsedIconColor: Color(0xff97C663),         // 닫혀있을 때 아이콘 색
                      title: Text(
                        faq['question']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                          child: Align(
                            alignment: Alignment.centerLeft, // 🔹 텍스트 왼쪽 정렬
                            child: Text(
                              faq['answer']!,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}