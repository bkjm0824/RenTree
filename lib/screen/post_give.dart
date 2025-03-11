import 'package:flutter/material.dart';

class PostGiveScreen extends StatefulWidget {
  @override
  _PostGiveScreenState createState() => _PostGiveScreenState();
}

class _PostGiveScreenState extends State<PostGiveScreen> {
  bool isFaceToFace = false; // 대면 여부 체크박스 상태
  bool isNonFaceToFace = false; // 비대면 여부 체크박스 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 설정
      body: GestureDetector(
        onTap: () {
          // 화면을 터치할 때 키보드를 내린다
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag, // 스크롤 시 키보드 내리기
                  padding: const EdgeInsets.all(20.0), // 전체 여백 추가
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 상단 X 아이콘 (뒤로가기)
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.close,
                              size: 40, color: Color(0xff918B8B)), // X 아이콘
                          onPressed: () {
                            Navigator.pop(context); // 뒤로가기 기능
                          },
                        ),
                      ),
                      SizedBox(height: 30),

                      // 🔹 큰 제목
                      Text(
                        '물건 대여 요청하기',
                        style: TextStyle(
                          fontSize: 33, // 글씨 크기 키움
                          fontWeight: FontWeight.bold, // 볼드 적용
                        ),
                      ),
                      SizedBox(height: 60),

                      // 🔹 제목 입력 필드
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xffEBEBEB),
                          hintText: '제목 입력',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(width: 1, color: Color(0xFF888686)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // 🔹 대여 시간 입력 필드 (두 개로 나누기)
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

                      // 🔹 본문 입력 필드 (항상 위쪽 정렬)
                      Container(
                        height: 275, // 적절한 높이 설정
                        child: TextField(
                          maxLines: null,
                          expands: true,
                          textAlignVertical:
                              TextAlignVertical.top, // 텍스트 항상 위쪽 정렬
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

                      // 🔹 대면 / 비대면 체크박스 (오른쪽 정렬)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                        children: [
                          Row(
                            children: [
                              Text('대면'),
                              Checkbox(
                                value: isFaceToFace,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isFaceToFace = value ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(width: 8),
                          Row(
                            children: [
                              Text('비대면'),
                              Checkbox(
                                value: isNonFaceToFace,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isNonFaceToFace = value ?? false;
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

              // 🔹 RenTree에 글 올리기 버튼 (화면 아래 고정)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      ),
    );
  }
}
