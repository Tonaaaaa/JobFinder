import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:jobfinder/screens/LoginScreen/login_screen.dart'; // Import LoginScreen

class EmployeeProfileScreen extends StatefulWidget {
  final String userId; // ID người dùng

  EmployeeProfileScreen({required this.userId});

  @override
  _EmployeeProfileScreenState createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  String _selectedExperience = "Chưa có";
  final List<String> _experienceOptions = [
    "Chưa có",
    "<1 năm",
    "2 năm",
    "3 năm",
    "4 năm",
    "5 năm",
    ">5 năm"
  ];

  File? _avatarFile;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Hồ sơ cá nhân"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Gọi hàm đăng xuất
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users') // Collection trên Firestore
            .doc(widget.userId) // Lấy tài liệu theo userId
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi khi tải dữ liệu"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Không tìm thấy thông tin người dùng"));
          }

          // Dữ liệu người dùng từ Firestore
          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _avatarFile != null
                              ? FileImage(_avatarFile!)
                              : userData['avatarUrl'] != null
                                  ? NetworkImage(userData['avatarUrl'])
                                  : AssetImage('assets/avatar_placeholder.png')
                                      as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'] ?? "Chưa có tên",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                text: 'Mã ứng viên: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: userData['userCode'] ?? 'Chưa có',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Kinh nghiệm làm việc
                _buildSectionHeader(
                  title: "Kinh nghiệm làm việc",
                  onEdit: () {
                    _showExperiencePicker(userData['experience']);
                  },
                ),
                Text(
                  _selectedExperience,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Divider(height: 30, color: Colors.grey[300]),

                // Công việc mong muốn
                _buildSectionHeader(
                  title: "Công việc mong muốn",
                  onEdit: () {
                    _showEditDialog(
                      context,
                      "Công việc mong muốn",
                      userData['desiredJob'] ?? "Chưa cập nhật",
                      "desiredJob",
                    );
                  },
                ),
                Text(
                  userData['desiredJob'] ?? "Chưa cập nhật",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Divider(height: 30, color: Colors.grey[300]),

                // Địa điểm làm việc mong muốn
                _buildSectionHeader(
                  title: "Địa điểm làm việc mong muốn",
                  onEdit: () {
                    _showEditDialog(
                      context,
                      "Địa điểm làm việc mong muốn",
                      userData['desiredLocation'] ?? "Chưa cập nhật",
                      "desiredLocation",
                    );
                  },
                ),
                Text(
                  userData['desiredLocation'] ?? "Chưa cập nhật",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Divider(height: 30, color: Colors.grey[300]),

                // Trạng thái tìm việc
                Row(
                  children: [
                    Icon(Icons.settings, color: Colors.blueAccent, size: 24),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Trạng thái tìm việc",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value:
                          userData['jobSeekingStatus'] ?? true, // Mặc định mở
                      onChanged: (value) {
                        _updateField('jobSeekingStatus', value);
                        setState(() {}); // Cập nhật giao diện sau khi thay đổi
                      },
                      activeColor: Colors.blueAccent,
                    ),
                  ],
                ),
                Divider(height: 30, color: Colors.grey[300]),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
      await _saveAvatar();
    }
  }

  Future<void> _saveAvatar() async {
    if (_avatarFile == null) return;

    try {
      String? avatarUrl = await uploadImageToImgur(_avatarFile!);
      if (avatarUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải lên ảnh đại diện.")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'avatarUrl': avatarUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật ảnh đại diện thành công!")),
      );

      setState(() {
        _avatarFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật ảnh đại diện: $e")),
      );
    }
  }

  Future<String?> uploadImageToImgur(File imageFile) async {
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

  void _showEditDialog(
      BuildContext context, String title, String currentValue, String field) {
    TextEditingController _controller =
        TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Nhập thông tin...",
            ),
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
                setState(() {}); // Cập nhật giao diện
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _showExperiencePicker(String? currentExperience) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem:
                  _experienceOptions.indexOf(currentExperience ?? "Chưa có"),
            ),
            onSelectedItemChanged: (index) {
              setState(() {
                _selectedExperience = _experienceOptions[index];
                if (_selectedExperience == "Chưa có") {
                  _updateField('experience', "Sắp đi làm");
                } else {
                  _updateField('experience', _selectedExperience);
                }
              });
            },
            children: _experienceOptions.map((option) {
              return Center(child: Text(option));
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _updateField(String field, dynamic value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      field: value,
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}
