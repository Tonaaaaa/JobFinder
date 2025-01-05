import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pdf_view_screen.dart'; // Màn hình hiển thị PDF

class CvApprovalScreen extends StatefulWidget {
  final String userId; // ID của recruiter (người đăng nhập)

  CvApprovalScreen({required this.userId});

  @override
  _CvApprovalScreenState createState() => _CvApprovalScreenState();
}

class _CvApprovalScreenState extends State<CvApprovalScreen> {
  String searchQuery = ''; // Từ khóa tìm kiếm
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Duyệt CV Ứng Viên',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, email hoặc số điện thoại...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobPosts')
                  .where('userId', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, jobSnapshot) {
                if (jobSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (jobSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Đã xảy ra lỗi khi tải dữ liệu!',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }

                if (!jobSnapshot.hasData || jobSnapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late,
                            size: 120, color: Colors.grey[400]),
                        SizedBox(height: 20),
                        Text(
                          'Không có công việc nào để duyệt CV!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final jobIds =
                    jobSnapshot.data!.docs.map((doc) => doc.id).toList();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('jobApplications')
                      .where('jobId', whereIn: jobIds)
                      .orderBy('submittedAt', descending: true)
                      .snapshots(),
                  builder: (context, cvSnapshot) {
                    if (cvSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (cvSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Đã xảy ra lỗi khi tải dữ liệu!',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }

                    if (!cvSnapshot.hasData || cvSnapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_late,
                                size: 120, color: Colors.grey[400]),
                            SizedBox(height: 20),
                            Text(
                              'Không có CV nào để duyệt!',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final applications = cvSnapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name']?.toLowerCase() ?? '';
                      final email = data['email']?.toLowerCase() ?? '';
                      final phone = data['phone']?.toLowerCase() ?? '';
                      return name.contains(searchQuery) ||
                          email.contains(searchQuery) ||
                          phone.contains(searchQuery);
                    }).toList();

                    if (applications.isEmpty) {
                      return Center(
                        child: Text(
                          'Không tìm thấy kết quả phù hợp!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: applications.length,
                      padding: EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final application =
                            applications[index].data() as Map<String, dynamic>;
                        final status = application['status'] ?? 'chưa duyệt';

                        return Card(
                          elevation: 8,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor:
                                          Colors.blueAccent.withOpacity(0.2),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blueAccent,
                                        size: 30,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            application['name'] ??
                                                'Tên không xác định',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Email: ${application['email'] ?? 'Không xác định'}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                          ),
                                          Text(
                                            'SĐT: ${application['phone'] ?? 'Không xác định'}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                          ),
                                          Text(
                                            'Trạng thái: $status',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: status == 'chưa duyệt'
                                                  ? Colors.orange
                                                  : status == 'đã duyệt'
                                                      ? Colors.green
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Cover Letter:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  application['coverLetter'] ??
                                      'Không có thư giới thiệu',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PdfViewScreen(
                                            url: application['cvUrl'],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.picture_as_pdf),
                                    label: Text('Xem CV'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                if (status == 'chưa duyệt' ||
                                    status == 'Chờ xác nhận')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('jobApplications')
                                              .doc(applications[index].id)
                                              .update({'status': 'đã duyệt'});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Ứng viên đã được duyệt!')),
                                          );
                                        },
                                        icon: Icon(Icons.check,
                                            color: Colors.white),
                                        label: Text('Duyệt',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('jobApplications')
                                              .doc(applications[index].id)
                                              .update({'status': 'từ chối'});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Ứng viên đã bị từ chối!')),
                                          );
                                        },
                                        icon: Icon(Icons.close,
                                            color: Colors.white),
                                        label: Text('Từ chối',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                // if (status == 'đã duyệt')
                                //   Center(
                                //     child: TextButton(
                                //       onPressed: () {
                                //         Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //             builder: (context) => ChatScreen(
                                //               recruiterId: widget.userId,
                                //               applicantId:
                                //                   application['userId'],
                                //             ),
                                //           ),
                                //         );
                                //       },
                                //       child: Text(
                                //         'Liên hệ',
                                //         style: TextStyle(
                                //           fontSize: 16,
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.blueAccent,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                              ],
                            ),
                          ),
                        );
                      },
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
