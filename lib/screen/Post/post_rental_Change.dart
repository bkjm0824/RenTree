import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class rentalChangeScreen extends StatefulWidget {
  final int id;

  rentalChangeScreen({required this.id});

  @override
  _rentalChangeState createState() => _rentalChangeState();
}

class _rentalChangeState extends State<rentalChangeScreen> {
  bool isFaceToFace = false;
  bool isNonFaceToFace = false;
  String? selectedCategory = '전자기기';
  bool isTransfer = false;
  List<XFile> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  List<Map<String, dynamic>> _imageData = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    fetchRentalItemDetail(widget.id);
    fetchImages(widget.id);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(pickedFile);
      });
    }
  }

  Future<void> uploadImagesToServer(int rentalItemId) async {
    for (var imageFile in _imageFiles) {
      final uri = Uri.parse('http://54.79.35.255:8080/images/api');
      final request = http.MultipartRequest('POST', uri);

      request.fields['rentalItemId'] = rentalItemId.toString();
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        print("이미지 업로드 성공");
      } else {
        print("이미지 업로드 실패: ${response.statusCode}");
      }
    }
  }

  Future<void> fetchRentalItemDetail(int id) async {
    final url = Uri.parse('http://54.79.35.255:8080/rental-item/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final categoryName = data['category']?['name'] ?? '전자제품';
      setState(() {
        final startRaw = data['rentalStartTime'];
        final endRaw = data['rentalEndTime'];

        if (startRaw != null && endRaw != null) {
          final start = DateTime.parse(startRaw);
          final end = DateTime.parse(endRaw);
          _startTime = TimeOfDay.fromDateTime(start);
          _endTime = TimeOfDay.fromDateTime(end);
          _startTimeController.text = formatTimeOfDay(_startTime!);
          _endTimeController.text = formatTimeOfDay(_endTime!);
        } else {
          _startTime = null;
          _endTime = null;
          _startTimeController.clear();
          _endTimeController.clear();
        }
        isTransfer = categoryName == '양도(무료 나눔)';
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        selectedCategory = categoryName;
        isFaceToFace = data['isFaceToFace'] ?? false;
        isNonFaceToFace = !isFaceToFace;

        final start = DateTime.parse(data['rentalStartTime']);
        final end = DateTime.parse(data['rentalEndTime']);
        _startTime = TimeOfDay.fromDateTime(start);
        _endTime = TimeOfDay.fromDateTime(end);
        _startTimeController.text = formatTimeOfDay(_startTime!);
        _endTimeController.text = formatTimeOfDay(_endTime!);
      });
    } else {
      print("❌ 대여글 불러오기 실패: ${response.statusCode}");
    }
  }

  Future<void> fetchImages(int itemId) async {
    final url = Uri.parse('http://54.79.35.255:8080/images/api/item/$itemId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _imageData = data
            .where(
                (e) => e['imageUrl'] != null && e['imageUrl'].startsWith('/'))
            .map((e) => {
                  "id": e['id'],
                  "url": 'http://54.79.35.255:8080${e['imageUrl']}'
                })
            .toList();
      });
    } else {
      print("❌ 이미지 불러오기 실패: ${response.statusCode}");
    }
  }

  Future<void> deleteImageFromServer(int imageId) async {
    final url = Uri.parse('http://54.79.35.255:8080/images/api/$imageId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print("이미지 삭제 성공");
    } else {
      print("❌ 이미지 삭제 실패: ${response.statusCode}");
    }
  }

  String _getCategoryNameById(int id) {
    final reverseMap = {
      1: '전자기기',
      2: '학용품',
      3: '서적',
      4: '생활용품',
      5: '양도(무료 나눔)',
    };
    return reverseMap[id]!;
  }

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
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

  Widget buildImagePreview(Map<String, dynamic> image, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            image["url"],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () async {
              await deleteImageFromServer(image["id"]);
              setState(() {
                _imageData.removeAt(index);
              });
            },
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Future<void> submitUpdatePost() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final category = selectedCategory ?? 'categoryId';

    final categoryMap = {
      '전자기기': 1,
      '학용품': 2,
      '서적': 3,
      '생활용품': 4,
      '양도(무료 나눔)': 5,
    };
    final categoryId = categoryMap[category] ?? 1;

    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');

    if (studentNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    final Map<String, dynamic> body = {
      "studentNum": studentNum,
      "title": title,
      "description": description,
      "isFaceToFace": isFaceToFace,
      "categoryId": categoryId,
    };
    if (isTransfer) {
      body["rentalStartTime"] = null;
      body["rentalEndTime"] = null;
    } else {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final rentalStartTime = '${today}T$startTime';
      final rentalEndTime = '${today}T$endTime';
      body["rentalStartTime"] = rentalStartTime;
      body["rentalEndTime"] = rentalEndTime;
    }

    final url = Uri.parse('http://54.79.35.255:8080/rental-item/${widget.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      await uploadImagesToServer(widget.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정이 완료되었습니다!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      print('수정 실패: ${response.statusCode} - ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 실패! 다시 시도해주세요.')),
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
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text('대여 글 수정하기',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Pretender',
                                      fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xffEBEBEB),
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 73,
                                      decoration: BoxDecoration(
                                        color: Color(0xffEBEBEB),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.camera_alt,
                                                size: 36),
                                            onPressed: _pickImage,
                                          ),
                                          Text(
                                              '${_imageData.length + _imageFiles.length}/5',
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    ...List.generate(
                                      _imageData.length,
                                      (index) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: buildImagePreview(
                                            _imageData[index], index),
                                      ),
                                    ),
                                    ...List.generate(
                                      _imageFiles.length,
                                      (index) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                File(_imageFiles[index].path),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: -6,
                                              right: -6,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _imageFiles.removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.close,
                                                      size: 14,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '제목',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 3),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEBEBEB),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      width: 1, color: Color(0xFF888686)),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text('카테고리를 선택해주세요 : ',
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(width: 10),
                                Expanded(
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
                                        isTransfer = newValue == '양도(무료 나눔)';

                                        if (isTransfer) {
                                          // 시간 필드 초기화
                                          _startTime = null;
                                          _endTime = null;
                                          _startTimeController.clear();
                                          _endTimeController.clear();
                                        }
                                      });
                                    },
                                    items: <String>[
                                      '전자기기',
                                      '학용품',
                                      '서적',
                                      '생활용품',
                                      '양도(무료 나눔)',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 15),
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
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 15),
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
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("까지"),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                            Text(
                              '자세한 설명',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 3),
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
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  alignLabelWithHint: true,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1, color: Color(0xFF888686)),
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
                                    Text('대면',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Pretender',
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff606060))),
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
                                    Text('비대면',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Pretender',
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff606060))),
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
                        onPressed: submitUpdatePost,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff97C663),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          '수정 완료',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontFamily: 'Pretender',
                              fontWeight: FontWeight.w700),
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
