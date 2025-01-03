import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadCVScreen extends StatefulWidget {
  final String jobId;
  final String userId;

  UploadCVScreen({required this.jobId, required this.userId});

  @override
  _UploadCVScreenState createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen> {
  File? _selectedFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _coverLetterController = TextEditingController();

  bool _isUploading = false;
  String _fileErrorMessage = '';

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileErrorMessage = ''; // Xóa thông báo lỗi nếu có
      });
    } else {
      setState(() {
        _fileErrorMessage = 'Chỉ chấp nhận file định dạng PDF.';
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_selectedFile == null) {
      setState(() {
        _fileErrorMessage = 'Vui lòng tải CV lên.';
      });
      return;
    }

    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final applicationData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'coverLetter': _coverLetterController.text,
        'cvUrl': "uploaded_url_here", // Placeholder for actual upload URL
        'jobId': widget.jobId,
        'userId': widget.userId,
        'status': 'chưa duyệt',
        'submittedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('jobApplications')
          .add(applicationData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ứng tuyển thành công!')),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ứng tuyển',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin ứng tuyển',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.withOpacity(0.05),
                  ),
                  child: _selectedFile == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 40,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Nhấn để tải lên (PDF)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              if (_fileErrorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _fileErrorMessage,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 40,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _selectedFile!.path.split('/').last,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedFile = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              SizedBox(height: 8),
              if (_selectedFile != null) ...[
                SizedBox(height: 16),
                _buildTextField(
                  _nameController,
                  'Họ và Tên',
                  TextInputType.name,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  _phoneController,
                  'Số điện thoại',
                  TextInputType.phone,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  'Email',
                  TextInputType.emailAddress,
                ),
              ],
              SizedBox(height: 16),
              Text(
                'Thư giới thiệu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _coverLetterController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Giới thiệu ngắn gọn về bạn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JobSphere khuyên:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Chuẩn bị CV của bạn thật chuyên nghiệp, tập trung vào thành tựu và kỹ năng quan trọng.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '2. Viết thư giới thiệu súc tích, nhấn mạnh cách bạn có thể đóng góp cho doanh nghiệp.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _isUploading ? null : _submitApplication,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isUploading
              ? CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Ứng tuyển',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    TextInputType keyboardType,
  ) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
