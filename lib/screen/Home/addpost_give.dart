import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostGiveScreen extends StatefulWidget {
  @override
  _PostGiveScreenState createState() => _PostGiveScreenState();
}

class _PostGiveScreenState extends State<PostGiveScreen> {
  bool isFaceToFace = false; // 대면 여부 체크박스 상태
  bool isNonFaceToFace = false; // 비대면 여부 체크박스 상태
  String? selectedCategory = '전자제품'; // 선택된 카테고리
  bool isTransfer = false; // '양도' 라디오 버튼 선택 여부
  List<XFile> _imageFiles = []; // 선택된 이미지 목록

  final ImagePicker _picker = ImagePicker(); // 이미지 선택기

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(pickedFile); // 선택된 이미지 추가
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라와도 레이아웃 변경 방지
      backgroundColor: Color(0xffF4F1F1),
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

                            Text(
                              '대여 물품 등록하기',
                              style: TextStyle(
                                fontSize: 33,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 30),
                            // 🔹 사진 등록 영역
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xffEBEBEB), // 배경색 설정
                                border: Border.all(
                                  color: Colors.black, // 테두리 색상
                                ),
                                borderRadius:
                                    BorderRadius.circular(10), // 테두리 모서리 둥글기
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 왼쪽 텍스트
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '이미지를 첨부하면',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          '대여가 원활해집니다',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          '최대 5장 첨부 가능',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    // 오른쪽 카메라 아이콘 및 사진 개수
                                    Column(
                                      children: [
                                        IconButton(
                                          icon:
                                              Icon(Icons.camera_alt, size: 40),
                                          onPressed: _pickImage,
                                        ),
                                        Text(
                                          '${_imageFiles.length}/5', // 현재 등록된 사진 개수
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // 🔹 제목 입력 필드
                            TextField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEBEBEB),
                                hintText: '글 제목',
                                isDense: true,
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      width: 1, color: Color(0xFF888686)),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            // 나머지 부분은 기존 코드 그대로
                            Row(
                              children: [
                                Text(
                                  '카테고리를 선택해주세요 : ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ButtonTheme(
                                    alignedDropdown: true,
                                    child: DropdownButtonFormField<String>(
                                        value: selectedCategory,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          isDense: true,
                                          filled: true,
                                          fillColor: Color(0xffEBEBEB),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedCategory = newValue;
                                            isTransfer = newValue == '양도';
                                          });
                                        },
                                        items: <String>[
                                          '전자제품',
                                          '교재',
                                          '생활용품',
                                          '필기도구',
                                          '양도',
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          );
                                        }).toList(),
                                        dropdownColor: Color(0xffEBEBEB),
                                        borderRadius: BorderRadius.circular(15),
                                        menuMaxHeight: 250,
                                        icon: Icon(Icons.arrow_drop_down,
                                            color: Colors.grey[700]),
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                        iconSize: 30,
                                        alignment:
                                            AlignmentDirectional.bottomStart,
                                        selectedItemBuilder:
                                            (BuildContext context) {
                                          return <String>[
                                            '전자제품',
                                            '교재',
                                            '생활용품',
                                            '필기도구',
                                            '양도',
                                          ].map<Widget>((String value) {
                                            return Text(
                                              selectedCategory ?? '전자제품',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            );
                                          }).toList();
                                        }),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            // 🔹 대여 시간 입력 필드 (양도 선택 시 숨기기)
                            if (!isTransfer) ...[
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
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 15),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Color(0xFF888686)),
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
                                        isDense: true,
                                        hintText: '종료 시간',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 15),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Color(0xFF888686)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("까지"),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],

                            // 🔹 본문 입력 필드
                            Container(
                              height: 235,
                              child: TextField(
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEBEBEB),
                                  hintText: '상품에 대한 설명을 자세하게 적어주세요.',
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  alignLabelWithHint: true,
                                  isDense: true,
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1, color: Color(0xFF888686)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),

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
                                SizedBox(width: 5),
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

                    // 🔹 RenTree에 글 올리기 버튼
                    Container(
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
              // 🔹 상단 X 아이콘
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
