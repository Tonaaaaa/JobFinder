import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobfinder/screens/DetailScreen/detail_job_screen.dart';
import 'package:jobfinder/screens/FilterJobPopup/filter_popup.dart';
import 'package:jobfinder/screens/ListFullCompanyScreen/full_company_screen.dart';
import 'package:jobfinder/screens/ListFullJobScreen/full_job_screen.dart';
import 'package:jobfinder/widgets/animation_search_text.dart';

class EmployeeHomeScreen extends StatefulWidget {
  final String userId;

  EmployeeHomeScreen({required this.userId});

  @override
  _EmployeeHomeScreenState createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "";
  Map<String, dynamic> _filters = {}; // Lưu trữ bộ lọc

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFeatureComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Thông báo",
            style: TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
          content: Text(
              "Chức năng $featureName đang được cập nhật. Vui lòng quay lại sau!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Đóng", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  List<int>? _parseSalaryRange(String range) {
    try {
      if (range.contains('+')) {
        final minSalary = int.parse(range.replaceAll(RegExp(r'[^0-9]'), ''));
        return [minSalary, double.maxFinite.toInt()]; // Giá trị lớn nhất
      } else if (range.contains('-')) {
        final parts = range.split('-');
        final minSalary =
            int.parse(parts[0].trim().replaceAll(RegExp(r'[^0-9]'), ''));
        final maxSalary =
            int.parse(parts[1].trim().replaceAll(RegExp(r'[^0-9]'), ''));
        return [minSalary, maxSalary];
      }
    } catch (e) {
      print("Error parsing salary range: $e");
    }
    return null;
  }

  bool _isSalaryInRange(List<int> jobRange, List<int> selectedRange) {
    // Kiểm tra sự giao nhau giữa khoảng lương công việc và khoảng lương lọc
    return !(jobRange[1] < selectedRange[0] || jobRange[0] > selectedRange[1]);
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
                              child: TypewriterEffect(
                                texts: [
                                  "Tìm kiếm theo việc làm",
                                  "Tìm kiếm theo địa điểm",
                                  "Tìm kiếm theo vị trí",
                                  "Tìm kiếm công ty",
                                ],
                                typingSpeed: Duration(
                                    milliseconds: 100), // Tốc độ nhập ký tự
                                deletingSpeed: Duration(
                                    milliseconds: 50), // Tốc độ xóa ký tự
                                pauseDuration: Duration(
                                    seconds:
                                        1), // Thời gian dừng giữa các văn bản
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
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                          heightFactor: 0.7,
                          child: FilterBottomSheet(
                            onApplyFilters: (filters) {
                              setState(() {
                                _filters = filters; // Lưu lại bộ lọc đã chọn
                              });
                            },
                            appliedFilters:
                                _filters, // Truyền bộ lọc đã áp dụng
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icon/edit.png',
                        height: 30,
                        width: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
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
                          _buildCustomIcon(
                            "Việc làm",
                            Colors.blueAccent,
                            "assets/icon/suitcase.png",
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
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

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
                          _buildCustomIcon(
                            "Công ty",
                            Colors.blueAccent,
                            "assets/icon/office-building.png",
                            () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      CompanyListScreen(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

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
                          _buildCustomIcon(
                            "Podcast",
                            Colors.blueAccent,
                            "assets/icon/microphone.png",
                            () {
                              _showFeatureComingSoon(context, "Podcast");
                            },
                          ),
                          _buildCustomIcon(
                            "Blog",
                            Colors.blueAccent,
                            "assets/icon/blog.png",
                            () {
                              _showFeatureComingSoon(context, "Blog");
                            },
                          )
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

                          // Lọc theo hạn nộp hồ sơ
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
                              parsedDeadline.isBefore(DateTime.now())) {
                            return false;
                          }

                          // Lọc theo từ khóa
                          if (_searchKeyword.isNotEmpty) {
                            final title = jobData['title']?.toLowerCase() ?? '';
                            final companyName =
                                jobData['companyName']?.toLowerCase() ?? '';
                            final workLocation =
                                jobData['workLocation']?.toLowerCase() ?? '';
                            if (!(title.contains(_searchKeyword) ||
                                companyName.contains(_searchKeyword) ||
                                workLocation.contains(_searchKeyword))) {
                              return false;
                            }
                          }

                          // Lọc theo địa điểm
                          if (_filters['location'] != null &&
                              jobData['workLocation'] != _filters['location']) {
                            return false;
                          }

                          // Lọc theo loại hình công việc
                          if (_filters['jobType'] != null &&
                              jobData['employmentType'] !=
                                  _filters['jobType']) {
                            return false;
                          }
                          // Lọc theo mức lương
// Lọc theo mức lương
                          if (_filters['salaryRange'] != null) {
                            final selectedRange =
                                _filters['salaryRange'] as String;
                            final jobSalaryRange =
                                jobData['salaryRange'] as String? ?? '';

                            // Tách khoảng lương từ chuỗi
                            final selectedMinMax =
                                _parseSalaryRange(selectedRange);
                            final jobMinMax = _parseSalaryRange(jobSalaryRange);

                            if (jobMinMax != null && selectedMinMax != null) {
                              // Kiểm tra sự giao nhau giữa khoảng lương công việc và khoảng lương lọc
                              if (!_isSalaryInRange(
                                  jobMinMax, selectedMinMax)) {
                                return false;
                              }
                            }
                          }

                          // Lọc theo ngành nghề
                          if (_filters['industry'] != null &&
                              jobData['industry'] != _filters['industry']) {
                            return false;
                          }

                          // Lọc theo cấp bậc công việc
                          if (_filters['jobLevel'] != null &&
                              jobData['jobLevel'] != _filters['jobLevel']) {
                            return false;
                          }

                          return true;
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Gợi ý việc làm mới",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              FullJobListScreen(
                                            userId: widget.userId,
                                            searchKeyword: _searchKeyword,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;

                                            final tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));
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
                              itemCount:
                                  jobPosts.length > 4 ? 4 : jobPosts.length,
                              itemBuilder: (context, index) {
                                final jobData = jobPosts[index].data()
                                    as Map<String, dynamic>;
                                final jobId = jobPosts[index]
                                    .id; // Lấy jobId từ Firestore
                                jobData['jobId'] =
                                    jobId; // Thêm jobId vào jobData

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            JobDetailsScreen(jobData: jobData),
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
                                  child: EnhancedJobCard(
                                    jobId: jobId, // Truyền jobId vào
                                    title:
                                        jobData['title'] ?? 'Không có tiêu đề',
                                    companyName: jobData['companyName'] ??
                                        'Không có công ty',
                                    workLocation: jobData['workLocation'] ??
                                        'Không xác định',
                                    employmentType: jobData['employmentType'] ??
                                        'Không xác định',
                                    salaryRange: jobData['salaryRange'] ??
                                        'Không xác định',
                                    applicationDeadline:
                                        jobData['applicationDeadline'] ??
                                            'Không xác định',
                                    companyLogo: jobData['logoUrl'],
                                    userId: widget.userId,
                                  ),
                                );
                              },
                            )
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

  Widget _buildCustomIcon(
      String title, Color color, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.2),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                ),
              ),
            ),
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
}

class EnhancedJobCard extends StatefulWidget {
  final String jobId;
  final String title;
  final String companyName;
  final String workLocation;
  final String employmentType;
  final String salaryRange;
  final String applicationDeadline;
  final String? companyLogo;
  final String userId;

  EnhancedJobCard({
    required this.jobId,
    required this.title,
    required this.companyName,
    required this.workLocation,
    required this.employmentType,
    required this.salaryRange,
    required this.applicationDeadline,
    this.companyLogo,
    required this.userId,
  });

  @override
  _EnhancedJobCardState createState() => _EnhancedJobCardState();
}

class _EnhancedJobCardState extends State<EnhancedJobCard> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final bookmarkDoc = await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(widget.userId)
        .collection('jobs')
        .doc(widget.jobId)
        .get();

    if (mounted) {
      setState(() {
        _isBookmarked = bookmarkDoc.exists;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (!mounted) return; // Nếu widget không còn trong tree, thoát sớm

    setState(() {
      _isLoading = true;
    });

    if (_isBookmarked) {
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(widget.userId)
          .collection('jobs')
          .doc(widget.jobId)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(widget.userId)
          .collection('jobs')
          .doc(widget.jobId)
          .set({
        'title': widget.title,
        'companyName': widget.companyName,
        'workLocation': widget.workLocation,
        'employmentType': widget.employmentType,
        'salaryRange': widget.salaryRange,
        'applicationDeadline': widget.applicationDeadline,
        'logoUrl': widget.companyLogo,
      });
    }

    if (mounted) {
      setState(() {
        _isBookmarked = !_isBookmarked;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                widget.companyLogo != null && widget.companyLogo!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.companyLogo!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
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
                        widget.title,
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
                        widget.companyName,
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
                  onTap: _toggleBookmark,
                  child: _isLoading
                      ? SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blueAccent,
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            key: ValueKey(_isBookmarked),
                            color: _isBookmarked
                                ? Colors.yellow
                                : Colors.blueAccent,
                            size: 30,
                          ),
                        ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  widget.workLocation,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 20, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  widget.employmentType,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.salaryRange,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  widget.applicationDeadline,
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
    );
  }
}
