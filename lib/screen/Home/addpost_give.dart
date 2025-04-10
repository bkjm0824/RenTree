import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostGiveScreen extends StatefulWidget {
  @override
  _PostGiveScreenState createState() => _PostGiveScreenState();
}

class _PostGiveScreenState extends State<PostGiveScreen> {
  bool isFaceToFace = false;
  bool isNonFaceToFace = false;
  String? selectedCategory = '전자제품';
  bool isTransfer = false;
  List<XFile> _imageFiles = [];

  final ImagePicker _picker = ImagePicker();


  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(pickedFile);
      });
    }
  }

  Future<String?> uploadImage(XFile imageFile) async {
    final uri = Uri.parse('http://10.0.2.2:8080/upload-image'); // 백엔드 업로드용 엔드포인트
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);
      return data['url']; // 서버가 이미지 URL 반환하는 경우
    } else {
      print('이미지 업로드 실패: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _startTimeController.text = formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = formatTimeOfDay(picked);
      });
    }
  }

  Future<void> submitGivePost() async {
    final url = Uri.parse('http://10.0.2.2:8080/rental-item');

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final category = selectedCategory ?? '전자제품';

    final categoryMap = {
      '전자제품': 1,
      '교재': 2,
      '생활용품': 3,
      '필기도구': 4,
      '양도': 5,
    };

    final categoryId = categoryMap[category] ?? 1;

    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum'); // 🔑 저장된 학번 불러오기

    if (studentNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    final rentalStartTime = '${today}T$startTime';
    final rentalEndTime = '${today}T$endTime';

    // 이미지 업로드 후 URL 수집
    List<String> photoUrls = [];
    for (var imageFile in _imageFiles) {
      final url = await uploadImage(imageFile);
      if (url != null) {
        photoUrls.add(url);
      }
    }

    final body = {
      "studentNum": studentNum,
      "title": title,
      "description": description,
      "isFaceToFace": isFaceToFace,
      "categoryId": categoryId,
      "rentalStartTime": rentalStartTime,
      "rentalEndTime": rentalEndTime,
      "photoUrls": photoUrls,
    };

    print("보낼 데이터: $body");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 성공!')),
      );
      Navigator.pop(context);
    } else {
      print('등록 실패: ${response.statusCode} - ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패! 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffF4F1F1),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 70),
                            Text('대여 물품 등록하기', style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold)),
                            SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xffEBEBEB),
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('이미지를 첨부하면', style: TextStyle(fontSize: 20)),
                                        Text('대여가 원활해집니다', style: TextStyle(fontSize: 20)),
                                        SizedBox(height: 3),
                                        Text('최대 5장 첨부 가능', style: TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.camera_alt, size: 40),
                                          onPressed: _pickImage,
                                        ),
                                        Text('${_imageFiles.length}/5', style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEBEBEB),
                                hintText: '글 제목',
                                isDense: true,
                                hintStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(width: 1, color: Color(0xFF888686)),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text('카테고리를 선택해주세요 : ', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedCategory,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                      filled: true,
                                      fillColor: Color(0xffEBEBEB),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCategory = newValue;
                                        isTransfer = newValue == '양도';
                                      });
                                    },
                                    items: <String>['전자제품', '교재', '생활용품', '필기도구', '양도']
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            if (!isTransfer) ...[
                              Row(
                                children: [
                                  Text("대여 시간은"),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _selectStartTime,
                                      child: IgnorePointer(
                                        child: TextField(
                                          controller: _startTimeController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Color(0xffEBEBEB),
                                            hintText: '시작 시간',
                                            hintStyle: TextStyle(fontSize: 14),
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(width: 1, color: Color(0xFF888686)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("부터"),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _selectEndTime,
                                      child: IgnorePointer(
                                        child: TextField(
                                          controller: _endTimeController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Color(0xffEBEBEB),
                                            isDense: true,
                                            hintText: '종료 시간',
                                            hintStyle: TextStyle(fontSize: 14),
                                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(width: 1, color: Color(0xFF888686)),
                                            ),
                                          ),
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
                            Container(
                              height: 235,
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEBEBEB),
                                  hintText: '상품에 대한 설명을 자세하게 적어주세요.',
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  alignLabelWithHint: true,
                                  isDense: true,
                                  hintStyle: TextStyle(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(width: 1, color: Color(0xFF888686)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text('대면', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff606060))),
                                    Checkbox(
                                      value: isFaceToFace,
                                      activeColor: Color(0xff97C663),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            isFaceToFace = true;
                                            isNonFaceToFace = false;
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
                                    Text('비대면', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff606060))),
                                    Checkbox(
                                      value: isNonFaceToFace,
                                      activeColor: Color(0xff97C663),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            isNonFaceToFace = true;
                                            isFaceToFace = false;
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
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitGivePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff97C663),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'RenTree에 글 올리기',
                          style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
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
