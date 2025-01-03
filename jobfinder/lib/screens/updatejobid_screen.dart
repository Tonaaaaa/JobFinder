import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateJobIdScreen extends StatefulWidget {
  @override
  _UpdateJobIdScreenState createState() => _UpdateJobIdScreenState();
}

class _UpdateJobIdScreenState extends State<UpdateJobIdScreen> {
  @override
  void initState() {
    super.initState();
    _updateJobIds();
  }

  Future<void> _updateJobIds() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('jobPosts').get();
      for (var doc in snapshot.docs) {
        if (!doc.data().containsKey('jobId')) {
          await FirebaseFirestore.instance
              .collection('jobPosts')
              .doc(doc.id)
              .update({'jobId': doc.id});
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('jobId đã được cập nhật thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật jobId: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cập nhật jobId')),
      body: Center(child: Text('Đang xử lý...')),
    );
  }
}
