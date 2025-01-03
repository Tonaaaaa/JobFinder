import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobfinder/screens/DetailScreen/detail_job_screen.dart';
import 'package:confetti/confetti.dart';
import 'package:jobfinder/screens/ListFullJobScreen/full_job_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final String userId;

  EmployeeHomeScreen({required this.userId});

  @override
  _EmployeeHomeScreenState createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 1));
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = ""; // Từ khóa tìm kiếm

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          if (_searchKeyword.isEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    "Tìm kiếm theo việc làm",
                                    textStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    speed: Duration(milliseconds: 100),
                                  ),
                                  TypewriterAnimatedText(
                                    "Tìm kiếm theo địa điểm",
                                    textStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    speed: Duration(milliseconds: 100),
                                  ),
                                  TypewriterAnimatedText(
                                    "Tìm kiếm theo vị trí",
                                    textStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    speed: Duration(milliseconds: 100),
                                  ),
                                  TypewriterAnimatedText(
                                    "Tìm kiếm công ty",
                                    textStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    speed: Duration(milliseconds: 100),
                                  ),
                                ],
                                repeatForever: true,
                                pause: Duration(milliseconds: 500),
                              ),
                            ),
                          TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchKeyword = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "",
                            ),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // Chức năng map
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.map, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError ||
                !userSnapshot.hasData ||
                !userSnapshot.data!.exists) {
              return Center(child: Text('Lỗi tải thông tin người dùng!'));
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final jobSeekingStatus = userData['jobSeekingStatus'] ?? true;

            if (!jobSeekingStatus) {
              return Center(
                child: Text(
                  "Bạn đã có việc chưa, nếu chưa thì hãy bật trạng thái tìm việc trong hồ sơ.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 2));
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildIcon(
                            Icons.work,
                            "Việc làm",
                            Colors.blueAccent,
                            () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      FullJobListScreen(
                                    userId: widget.userId,
                                    searchKeyword: _searchKeyword,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    // Hiệu ứng trượt từ phải qua
                                    const begin =
                                        Offset(1.0, 0.0); // Bắt đầu từ bên phải
                                    const end = Offset
                                        .zero; // Kết thúc tại vị trí ban đầu
                                    const curve =
                                        Curves.easeInOut; // Đường cong mượt

                                    final tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    final offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          _buildIcon(
                              Icons.business, "Công ty", Colors.blueAccent, () {
                            // Bạn có thể thêm hành động khi bấm vào "Công ty"
                          }),
                          _buildIcon(Icons.mic, "Podcast", Colors.blueAccent,
                              () {
                            // Bạn có thể thêm hành động khi bấm vào "Podcast"
                          }),
                          _buildIcon(Icons.article, "Blog", Colors.blueAccent,
                              () {
                            // Bạn có thể thêm hành động khi bấm vào "Blog"
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 2),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('jobPosts')
                          .snapshots(),
                      builder: (context, jobSnapshot) {
                        if (jobSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (jobSnapshot.hasError ||
                            !jobSnapshot.hasData ||
                            jobSnapshot.data!.docs.isEmpty) {
                          return Center(
                              child:
                                  Text('Không có việc làm nào để hiển thị!'));
                        }

                        final now = DateTime.now();
                        final jobPosts = jobSnapshot.data!.docs.where((doc) {
                          final jobData = doc.data() as Map<String, dynamic>;

                          final deadline = jobData['applicationDeadline'];
                          DateTime? parsedDeadline;

                          if (deadline is Timestamp) {
                            parsedDeadline = deadline.toDate();
                          } else if (deadline is String) {
                            try {
                              parsedDeadline =
                                  DateFormat('dd/MM/yyyy').parse(deadline);
                            } catch (e) {
                              parsedDeadline = null;
                            }
                          }

                          if (parsedDeadline != null &&
                              parsedDeadline.isBefore(now)) {
                            return false; // Loại bỏ công việc hết hạn
                          }

                          final title = jobData['title']?.toLowerCase() ?? '';
                          final companyName =
                              jobData['companyName']?.toLowerCase() ?? '';
                          final workLocation =
                              jobData['workLocation']?.toLowerCase() ?? '';
                          return title.contains(_searchKeyword) ||
                              companyName.contains(_searchKeyword) ||
                              workLocation.contains(_searchKeyword);
                        }).toList();

                        if (jobPosts.isEmpty) {
                          return Center(
                              child: Text('Không tìm thấy việc làm phù hợp!'));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Đặt hai phần tử cách xa nhau
                                children: [
                                  Text(
                                    "Gợi ý việc làm mới",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (jobPosts.length >
                                      4) // Hiển thị nút "Xem tất cả" nếu có hơn 4 công việc
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FullJobListScreen(
                                              userId: widget.userId,
                                              searchKeyword: _searchKeyword,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Xem tất cả",
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: jobPosts.length > 4
                                  ? 4
                                  : jobPosts.length, // Giới hạn 4 công việc
                              itemBuilder: (context, index) {
                                final jobData = jobPosts[index].data()
                                    as Map<String, dynamic>;
                                final jobId = jobPosts[index].id;
                                final title =
                                    jobData['title'] ?? 'Không có tiêu đề';
                                final companyName = jobData['companyName'] ??
                                    'Không có công ty';
                                final workLocation =
                                    jobData['workLocation'] ?? 'Không xác định';
                                final employmentType =
                                    jobData['employmentType'] ??
                                        'Không xác định';
                                final salaryRange =
                                    jobData['salaryRange'] ?? 'Không xác định';

                                final deadline = jobData['applicationDeadline'];
                                DateTime? parsedDeadline;

                                if (deadline is Timestamp) {
                                  parsedDeadline = deadline.toDate();
                                } else if (deadline is String) {
                                  try {
                                    parsedDeadline = DateFormat('dd/MM/yyyy')
                                        .parse(deadline);
                                  } catch (e) {
                                    parsedDeadline = null;
                                  }
                                }

                                final formattedDeadline = parsedDeadline != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(parsedDeadline)
                                    : 'Không xác định';

                                final companyLogo = jobData['logoUrl'] ?? null;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            JobDetailsScreen(
                                          jobData: jobData,
                                        ),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;

                                          final tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                          final offsetAnimation =
                                              animation.drive(tween);

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: _buildEnhancedJobCard(
                                    jobId: jobId,
                                    title: title,
                                    companyName: companyName,
                                    workLocation: workLocation,
                                    employmentType: employmentType,
                                    salaryRange: salaryRange,
                                    applicationDeadline: formattedDeadline,
                                    companyLogo: companyLogo,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.blueAccent, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedJobCard({
    required String jobId,
    required String title,
    required String companyName,
    required String workLocation,
    required String employmentType,
    required String salaryRange,
    required String applicationDeadline,
    String? companyLogo,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(widget.userId)
          .collection('jobs')
          .doc(jobId)
          .get(),
      builder: (context, snapshot) {
        bool isBookmarked = snapshot.hasData && snapshot.data!.exists;

        return Stack(
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.2,
              numberOfParticles: 10,
            ),
            Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blueAccent),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        companyLogo != null && companyLogo.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  companyLogo,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor:
                                    Colors.blueAccent.withOpacity(0.2),
                                radius: 30,
                                child: Icon(Icons.business,
                                    size: 30, color: Colors.blueAccent),
                              ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Text(
                                companyName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (isBookmarked) {
                              await FirebaseFirestore.instance
                                  .collection('bookmarks')
                                  .doc(widget.userId)
                                  .collection('jobs')
                                  .doc(jobId)
                                  .delete();
                            } else {
                              _confettiController.play();
                              await FirebaseFirestore.instance
                                  .collection('bookmarks')
                                  .doc(widget.userId)
                                  .collection('jobs')
                                  .doc(jobId)
                                  .set({
                                'title': title,
                                'companyName': companyName,
                                'workLocation': workLocation,
                                'employmentType': employmentType,
                                'salaryRange': salaryRange,
                                'applicationDeadline': applicationDeadline,
                                'companyLogo': companyLogo,
                              });
                            }
                            setState(() {});
                          },
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? Colors.yellow
                                : Colors.blueAccent,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 20, color: Colors.blueAccent),
                        SizedBox(width: 4),
                        Text(
                          workLocation,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.access_time,
                            size: 20, color: Colors.blueAccent),
                        SizedBox(width: 4),
                        Text(
                          employmentType,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          salaryRange,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          applicationDeadline,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
