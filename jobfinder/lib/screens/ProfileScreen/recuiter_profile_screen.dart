import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jobfinder/screens/LoginScreen/login_screen.dart';

class RecruiterProfileScreen extends StatefulWidget {
  final String userId;

  RecruiterProfileScreen({required this.userId});

  @override
  _RecruiterProfileScreenState createState() => _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState extends State<RecruiterProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  bool _isLoading = false;
  String? _avatarUrl;
  File? _avatarFile;
  final _picker = ImagePicker();

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi khi đăng xuất: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _avatarUrl = data['avatarUrl'];
        return data;
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu người dùng: $e');
    }
    return null;
  }

  Future<void> _updateUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String? avatarUrl = _avatarUrl;
      if (_avatarFile != null) {
        avatarUrl = await _uploadImageToImgur(_avatarFile!);
        if (avatarUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể tải lên ảnh đại diện.')),
          );
          return;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'avatarUrl': avatarUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thông tin thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToImgur(File imageFile) async {
    final clientId = 'f4b668ef0850d43';
    final url = Uri.parse('https://api.imgur.com/3/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Client-ID $clientId'
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = jsonDecode(responseData.body);
        return jsonResponse['data']['link'];
      } else {
        print('Failed to upload image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Widget _buildSectionHeader(
      {required String title, required VoidCallback onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: onEdit,
          child: Text(
            "Sửa",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ nhà tuyển dụng'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Không thể tải thông tin người dùng.'));
          }

          final userData = snapshot.data!;
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneNumberController.text = userData['phoneNumber'] ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : _avatarUrl != null
                              ? NetworkImage(_avatarUrl!) as ImageProvider
                              : null,
                      child: _avatarFile == null && _avatarUrl == null
                          ? Icon(Icons.person,
                              size: 60, color: Colors.blueAccent)
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Name Section
                _buildSectionHeader(
                  title: "Tên",
                  onEdit: () {
                    _showEditDialog("Tên", _nameController.text, 'name');
                  },
                ),
                Text(
                  _nameController.text,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Divider(height: 30, color: Colors.grey[300]),

                // Email Section
                _buildSectionHeader(
                  title: "Email",
                  onEdit: () {
                    _showEditDialog("Email", _emailController.text, 'email');
                  },
                ),
                Text(
                  _emailController.text,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Divider(height: 30, color: Colors.grey[300]),

                // Phone Number Section
                _buildSectionHeader(
                  title: "Số điện thoại",
                  onEdit: () {
                    _showEditDialog("Số điện thoại",
                        _phoneNumberController.text, 'phoneNumber');
                  },
                ),
                Text(
                  _phoneNumberController.text,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Divider(height: 30, color: Colors.grey[300]),

                // Save Button
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child: ElevatedButton(
                          onPressed: _updateUserData,
                          child: Text(
                            'Lưu thông tin',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 32),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(String title, String currentValue, String field) {
    TextEditingController _controller =
        TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Nhập $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                _updateField(field, _controller.text.trim());
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateField(String field, dynamic value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({field: value});
  }
}
