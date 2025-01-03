import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FullJobListScreen extends StatelessWidget {
  final String userId;
  final String searchKeyword;

  FullJobListScreen({required this.userId, required this.searchKeyword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách công việc"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobPosts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Không có công việc nào."));
          }

          final jobPosts = snapshot.data!.docs.where((doc) {
            final jobData = doc.data() as Map<String, dynamic>;
            final title = jobData['title']?.toLowerCase() ?? '';
            final companyName = jobData['companyName']?.toLowerCase() ?? '';
            final workLocation = jobData['workLocation']?.toLowerCase() ?? '';
            return title.contains(searchKeyword) ||
                companyName.contains(searchKeyword) ||
                workLocation.contains(searchKeyword);
          }).toList();

          return ListView.builder(
            itemCount: jobPosts.length,
            itemBuilder: (context, index) {
              final jobData = jobPosts[index].data() as Map<String, dynamic>;
              return _buildEnhancedJobCard(
                jobId: jobPosts[index].id,
                title: jobData['title'] ?? 'Không có tiêu đề',
                companyName: jobData['companyName'] ?? 'Không có công ty',
                workLocation: jobData['workLocation'] ?? 'Không xác định',
                employmentType: jobData['employmentType'] ?? 'Không xác định',
                salaryRange: jobData['salaryRange'] ?? 'Không xác định',
                applicationDeadline: jobData['applicationDeadline'] ?? '',
                companyLogo: jobData['logoUrl'] ?? null,
              );
            },
          );
        },
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
                companyLogo != null && companyLogo.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          companyLogo,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
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
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  workLocation,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 20, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  employmentType,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
    );
  }
}
