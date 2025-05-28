import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  bool isFaceToFace = false;
  bool isNonFaceToFace = false;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Color(0xffF4F1F1), // 다이얼로그 배경
              hourMinuteTextColor: Colors.black,
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => const Color(0xffEBEBEB), // 시간 선택 배경
              ),
              dialHandColor: const Color(0xff97C663),
              dialBackgroundColor: const Color(0xffEBEBEB),
              dayPeriodColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Color(0xff97C663); // ✅ 선택된 AM/PM 배경색
                }
                return Color(0xffF0F0F0); // 비선택 상태 배경색
              }),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white; // ✅ 선택된 텍스트 색
                }
                return Colors.black; // 비선택 텍스트 색
              }),
              entryModeIconColor: const Color(0xff97C663),
            ),
            colorScheme: ColorScheme.light(
              primary: Color(0xff97C663), // Accent color (확인 버튼, 다이얼)
              onPrimary: Colors.white, // Accent text color
              onSurface: Colors.black, // 일반 텍스트 색
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Color(0xffF4F1F1), // 다이얼로그 배경
              hourMinuteTextColor: Colors.black,
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => const Color(0xffEBEBEB), // 시간 선택 배경
              ),
              dialHandColor: const Color(0xff97C663),
              dialBackgroundColor: const Color(0xffEBEBEB),
              dayPeriodColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Color(0xff97C663); // ✅ 선택된 AM/PM 배경색
                }
                return Color(0xffF0F0F0); // 비선택 상태 배경색
              }),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white; // ✅ 선택된 텍스트 색
                }
                return Colors.black; // 비선택 텍스트 색
              }),
              entryModeIconColor: const Color(0xff97C663),
            ),
            colorScheme: ColorScheme.light(
              primary: Color(0xff97C663), // Accent color (확인 버튼, 다이얼)
              onPrimary: Colors.white, // Accent text color
              onSurface: Colors.black, // 일반 텍스트 색
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = formatTimeOfDay(picked);
      });
    }
  }

  Future<void> submitRequest() async {
    final title = _titleController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final description = _descriptionController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final studentNum = prefs.getString('studentNum'); // ✅ string으로 불러오기

    if (studentNum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 정보를 찾을 수 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    if (title.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요')),
      );
      return;
    }

    final rentalDate = DateTime.now().toIso8601String().split('T')[0];
    final rentalStartTime = '${rentalDate}T$startTime';
    final rentalEndTime = '${rentalDate}T$endTime';

    final url = Uri.parse('http://54.79.35.255:8080/ItemRequest');

    final response = await http.post(
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('글이 등록되었습니다!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      print('서버 오류: ${response.statusCode} - ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('글 등록 실패')),
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
                            SizedBox(height: 70),
                            Text('물건 대여 요청하기',
                                style: TextStyle(
                                  fontSize: 33,
                                  fontFamily: 'Pretender',
                                  fontWeight: FontWeight.w700,
                                )),
                            SizedBox(height: 50),
                            TextField(
                              controller: _titleController,
                              keyboardType: TextInputType.text,
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
                            Row(
                              children: [
                                Text("대여 시간은",
                                    style: TextStyle(
                                        fontFamily: 'Pretender',
                                        fontWeight: FontWeight.w600)),
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
                                Text("부터",
                                    style: TextStyle(
                                        fontFamily: 'Pretender',
                                        fontWeight: FontWeight.w600)),
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
                                Text("까지",
                                    style: TextStyle(
                                        fontFamily: 'Pretender',
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 275,
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: null,
                                expands: true,
                                keyboardType: TextInputType.text,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '대면',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Pretender',
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff606060),
                                          ),
                                        ),
                                        SizedBox(width: 4), // 텍스트와 체크박스 사이 간격
                                        Checkbox(
                                          value: isFaceToFace,
                                          activeColor: Color(0xff97C663),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity(
                                              horizontal: -4.0, vertical: -4.0),
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
                                    SizedBox(width: 10), // 대면과 비대면 그룹 사이 간격
                                    Row(
                                      children: [
                                        Text(
                                          '비대면',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Pretender',
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff606060),
                                          ),
                                        ),
                                        SizedBox(width: 4), // 텍스트와 체크박스 사이 간격
                                        Checkbox(
                                          value: isNonFaceToFace,
                                          activeColor: Color(0xff97C663),
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          visualDensity: VisualDensity(
                                              horizontal: -4.0, vertical: -4.0),
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
                                )
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
                          'RenTree에 글 올리기',
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
