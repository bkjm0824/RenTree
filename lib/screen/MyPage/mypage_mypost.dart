import 'package:flutter/material.dart';
import '../Post/post_rental.dart';
import '../Home/addpost_give.dart';
import '../Home/addpost_request.dart';

class MyPageMypost extends StatefulWidget {
  @override
  _MyPageMypostState createState() => _MyPageMypostState();
}

class _MyPageMypostState extends State<MyPageMypost>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> generateFakeList(String type) {
    return List.generate(4, (index) => {
      'id': index + 1, // ← 실제 서버에서 받아올 id 대체용
      'title': '$type 게시글 ${index + 1}',
      'description': '$type 설명 ${index + 1}',
      'imageUrl': 'assets/box.png',
    });
  }



  Widget _buildList(String type) {
    List<Map<String, dynamic>> fakeList = generateFakeList(type);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: fakeList.length,
      itemBuilder: (context, index) {
        final item = fakeList[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PostRentalScreen(itemId: item['id']),
                ),
              );
            },
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item['imageUrl'],
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
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
                          Text(item['description'],
                              style: TextStyle(color: Colors.grey[700])),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.favorite_border,
                                      size: 20, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text('좋아요'),
                                ],
                              ),
                              Text('2시간 전',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(height: 20, color: Colors.grey[300]),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWriteModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  foregroundColor: Colors.white,
                  minimumSize: Size(230, 60),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToScreen(RequestScreen());
                },
                child: Text(
                  "대여 요청하기",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff97C663),
                  foregroundColor: Colors.white,
                  minimumSize: Size(230, 60),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToScreen(PostGiveScreen());
                },
                child: Text(
                  "물품 등록하기",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToScreen(Widget screen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: screen,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F1F1),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 상단바
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                      color: Colors.grey[700],
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Text(
                      '나의 게시글',
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showWriteModal,
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xff97C663),
                        padding:
                            EdgeInsets.symmetric(horizontal: 1, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        '글쓰기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // 🔹 탭바
            Container(
              color: Color(0xffF4F1F1),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Color(0xff97C663),
                indicatorWeight: 1.0,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Color(0xff97C663),
                unselectedLabelColor: Color(0xff918B8B),
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: '대여 요청'),
                  Tab(text: '물품 대여'),
                ],
              ),
            ),
            Container(height: 1, color: Colors.grey[300]),

            // 🔹 탭 콘텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList('대여 요청'),
                  _buildList('물품 대여'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
