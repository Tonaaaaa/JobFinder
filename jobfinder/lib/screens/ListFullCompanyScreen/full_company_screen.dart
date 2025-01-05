import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top Công ty tuyển dụng"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobPosts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Không có công ty nào để hiển thị.'));
          }

          final jobPosts = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'companyName': data['companyName'] ?? 'Không có công ty',
              'companyLogo': data['logoUrl'] ?? '',
              'industry': data['industry'] ?? 'Không rõ ngành nghề',
            };
          }).toSet();

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: jobPosts.length,
            itemBuilder: (context, index) {
              final company = jobPosts.elementAt(index);
              final companyName = company['companyName'];
              final companyLogo = company['companyLogo'];
              final industry = company['industry'];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Bo góc lớn hơn
                ),
                elevation: 5, // Đổ bóng rõ hơn
                margin:
                    EdgeInsets.only(bottom: 24), // Khoảng cách giữa các card
                child: Padding(
                  padding:
                      const EdgeInsets.all(20), // Tăng khoảng trắng trong card
                  child: Row(
                    children: [
                      // Logo công ty
                      companyLogo.isNotEmpty
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(12), // Bo góc logo
                              child: Image.network(
                                companyLogo,
                                width: 80, // Tăng kích thước logo
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              radius: 40, // Tăng kích thước biểu tượng mặc định
                              backgroundColor:
                                  Colors.blueAccent.withOpacity(0.2),
                              child: Icon(Icons.business,
                                  size: 40, color: Colors.blueAccent),
                            ),
                      SizedBox(width: 20), // Khoảng cách giữa logo và thông tin
                      // Thông tin công ty
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: TextStyle(
                                fontSize: 20, // Tăng kích thước tên công ty
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              industry,
                              style: TextStyle(
                                fontSize: 16, // Tăng kích thước ngành nghề
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
