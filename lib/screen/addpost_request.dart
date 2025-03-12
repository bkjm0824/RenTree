// 물품 대여 요청글 작성 화면
import 'package:flutter/material.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool isFaceToFace = false; // 대면 여부 체크박스 상태
  bool isNonFaceToFace = false; // 비대면 여부 체크박스 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 레이아웃 변경 방지
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 화면 터치 시 키보드 내리기
        },
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 70),

                            // 🔹 큰 제목
                            Text(
                              '대여 물품 등록하기',
                              style: TextStyle(
                                fontSize: 33,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 50),

                            // 🔹 제목 입력 필드
                            TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEBEBEB),
                                hintText: '제목 입력',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      width: 1, color: Color(0xFF888686)),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // 🔹 대여 시간 입력 필드
                            Row(
                              children: [
                                Text("대여 시간은"),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xffEBEBEB),
                                      hintText: '시작 시간',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            width: 1, color: Color(0xFF888686)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text("부터"),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xffEBEBEB),
                                      hintText: '종료 시간',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            width: 1, color: Color(0xFF888686)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text("까지"),
                              ],
                            ),
                            SizedBox(height: 20),

                            // 🔹 본문 입력 필드
                            Container(
                              height: 275,
                              child: TextField(
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEBEBEB),
                                  hintText: '상품에 대한 설명을 자세하게 적어주세요.',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1, color: Color(0xFF888686)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // 🔹 대면 / 비대면 체크박스
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '대면',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff606060)),
                                    ),
                                    Checkbox(
                                      value: isFaceToFace,
                                      activeColor:
                                          Color(0xff97C663), // 체크 색상 초록색
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            isFaceToFace = true;
                                            isNonFaceToFace =
                                                false; // 다른 체크박스 해제
                                          } else {
                                            isFaceToFace = false;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                Row(
                                  children: [
                                    Text(
                                      '비대면',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff606060)),
                                    ),
                                    Checkbox(
                                      value: isNonFaceToFace,
                                      activeColor:
                                          Color(0xff97C663), // 체크 색상 초록색
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            isNonFaceToFace = true;
                                            isFaceToFace = false; // 다른 체크박스 해제
                                          } else {
                                            isNonFaceToFace = false;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // 🔹 RenTree에 글 올리기 버튼 (키보드 영향 안 받게)
                    Container(
                      // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // 글 올리기 버튼 클릭 시 동작
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff97C663),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'RenTree에 글 올리기',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔹 상단 X 아이콘 (왼쪽 끝으로 정렬)
              Positioned(
                top: 10,
                left: 0, // 왼쪽 끝 정렬
                child: IconButton(
                  icon: Icon(Icons.close, size: 40, color: Color(0xff918B8B)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
