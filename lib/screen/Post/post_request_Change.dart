import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestChangeScreen extends StatefulWidget {
  final int id; // 요청글 ID

  RequestChangeScreen({required this.id});

  @override
  _RequestChangeScreenState createState() => _RequestChangeScreenState();
}

class _RequestChangeScreenState extends State<RequestChangeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  bool isFaceToFace = false;
  bool isNonFaceToFace = false;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    fetchItemRequest();
  }

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
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
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = formatTimeOfDay(picked);
      });
    }
  }

  Future<void> fetchItemRequest() async {
    final url = Uri.parse('http://10.0.2.2:8080/ItemRequest/${widget.id}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded);

        final rentalStart = DateTime.parse(data['rentalStartTime']);
        final rentalEnd = DateTime.parse(data['rentalEndTime']);

        setState(() {
          _titleController.text = data['title'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _startTime = TimeOfDay.fromDateTime(rentalStart);
          _endTime = TimeOfDay.fromDateTime(rentalEnd);
          _startTimeController.text = formatTimeOfDay(_startTime!);
          _endTimeController.text = formatTimeOfDay(_endTime!);
          isFaceToFace = data['isFaceToFace'] ?? false;
          isNonFaceToFace = !isFaceToFace;
        });
      } else {
        print('불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 오류 발생: $e');
    }
  }

  Future<void> submitRequest() async {
    final title = _titleController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final description = _descriptionController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum');

    if (studentNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    if (title.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요.')),
      );
      return;
    }

    final rentalDate = DateTime.now().toIso8601String().split('T')[0];
    final rentalStartTime = '${rentalDate}T$startTime';
    final rentalEndTime = '${rentalDate}T$endTime';

    final url = Uri.parse('http://10.0.2.2:8080/ItemRequest/${widget.id}');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentNum': studentNum,
        'title': title,
        'description': description,
        'rentalStartTime': rentalStartTime,
        'rentalEndTime': rentalEndTime,
        'isFaceToFace': isFaceToFace,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정이 완료되었습니다!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      print('서버 오류: ${response.statusCode} - ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 실패')),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('요청 글 수정하기',
                                    style: TextStyle(fontSize: 24)),
                              ],
                            ),
                            SizedBox(height: 40),
                            Text(' 제목', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 5),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEBEBEB),
                                hintText: '제목 입력',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
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
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                          hintText: '종료 시간',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                            Text('자세한 설명', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 5),
                            Container(
                              height: 320,
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEBEBEB),
                                  hintText: '상품에 대한 설명을 자세하게 적어주세요.',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text('대면',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
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
                                Row(
                                  children: [
                                    Text('비대면',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff97C663),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          '수정 완료',
                          style: TextStyle(fontSize: 24, color: Colors.white),
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
