import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:jobfinder/screens/CreateJobScreen/create_job_post_screen.dart';

class RecruiterHomeScreen extends StatefulWidget {
  @override
  _RecruiterHomeScreenState createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _removeItem(int index, String jobId, String title) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có muốn xóa bài viết "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('jobPosts')
          .doc(jobId)
          .delete();

      setState(() {
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => SizedBox.shrink(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bài đăng "$title" đã được xóa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trang chủ nhà tuyển dụng'),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'Vui lòng đăng nhập để xem các bài đăng.',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trang chủ nhà tuyển dụng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm bài đăng',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('jobPosts')
                  .where('userId', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Lỗi Firestore: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline, size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có bài đăng tuyển dụng.',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateJobPostScreen(
                                  onSaveJobPost: (_) {},
                                ),
                              ),
                            );
                          },
                          child: Text('Tạo bài đăng mới'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            backgroundColor: Colors.blueAccent,
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final now = DateTime.now();
                final jobPosts = snapshot.data!.docs.where((doc) {
                  final jobData = doc.data() as Map<String, dynamic>;
                  final title = jobData['title']?.toLowerCase() ?? "";
                  return title.contains(_searchQuery);
                }).toList();

                if (jobPosts.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy bài đăng nào phù hợp.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return AnimatedList(
                  key: _listKey,
                  initialItemCount: jobPosts.length,
                  itemBuilder: (context, index, animation) {
                    final jobPost =
                        jobPosts[index].data() as Map<String, dynamic>;
                    final jobId = jobPosts[index].id;
                    final deadline = jobPost['applicationDeadline'];

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

                    final isExpired =
                        parsedDeadline != null && parsedDeadline.isBefore(now);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateJobPostScreen(
                              onSaveJobPost: (_) {},
                              jobData: {...jobPost, 'id': jobId},
                            ),
                          ),
                        );
                      },
                      child: SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: Offset(1, 0),
                            end: Offset(0, 0),
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        jobPost['logoUrl'] != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  jobPost['logoUrl'],
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Icon(Icons.error,
                                                          color: Colors.red),
                                                ),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Icon(Icons.business,
                                                    color: Colors.grey),
                                              ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                jobPost['title'] ??
                                                    'Không có tiêu đề',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isExpired
                                                      ? Colors.red
                                                      : Colors.blueAccent,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _removeItem(index,
                                              jobId, jobPost['title'] ?? ""),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.business,
                                            size: 20, color: Colors.blueAccent),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            jobPost['companyName'] ??
                                                'Không có thông tin công ty',
                                            style: TextStyle(fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline,
                                            size: 20, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text(
                                          'Kinh nghiệm: ${jobPost['requiredExperience'] ?? 'Không yêu cầu'}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.assignment_ind_outlined,
                                            size: 20, color: Colors.purple),
                                        SizedBox(width: 8),
                                        Text(
                                          'Cấp bậc: ${jobPost['jobLevel'] ?? 'Không yêu cầu'}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.list_alt,
                                            size: 20, color: Colors.green),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Hình thức: ${jobPost['employmentType'] ?? 'Không yêu cầu'}',
                                            style: TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Quyền lợi:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ...((jobPost['benefits'] as List<dynamic>?)
                                            ?.map((benefit) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 2),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          size: 16,
                                                          color: Colors.green),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          benefit,
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                            .toList() ??
                                        [
                                          Text(
                                              'Không có quyền lợi được cung cấp.')
                                        ]),
                                  ],
                                ),
                              ),
                              if (parsedDeadline != null)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Text(
                                    isExpired
                                        ? 'Đã hết hạn'
                                        : 'Hạn nộp: ${DateFormat('dd/MM/yyyy').format(parsedDeadline)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isExpired
                                          ? Colors.red
                                          : Colors.blueAccent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
