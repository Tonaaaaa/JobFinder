import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jobfinder/screens/MainScreen/recruiter_main_screen.dart';

class CreateJobPostScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaveJobPost;
  final Map<String, dynamic>? jobData;

  CreateJobPostScreen({
    required this.onSaveJobPost,
    this.jobData,
  });

  @override
  _CreateJobPostScreenState createState() => _CreateJobPostScreenState();
}

class _CreateJobPostScreenState extends State<CreateJobPostScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _industryController =
      TextEditingController(); // Ngành nghề
  final TextEditingController _jobDescriptionController =
      TextEditingController();
  final TextEditingController _requiredExperienceController =
      TextEditingController();
  final TextEditingController _employmentTypeController =
      TextEditingController();
  final TextEditingController _salaryRangeController = TextEditingController();
  final TextEditingController _workLocationController = TextEditingController();
  final TextEditingController _genderRequirementController =
      TextEditingController();
  final TextEditingController _jobLevelController = TextEditingController();
  final TextEditingController _vacanciesController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _detailedAddressController =
      TextEditingController();
  final TextEditingController _candidateRequirementsController =
      TextEditingController();

  DateTime? _applicationDeadline;
  File? _companyLogoFile;
  String? _companyLogoUrl;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) {
      _titleController.text = widget.jobData!['title'] ?? '';
      _companyNameController.text = widget.jobData!['companyName'] ?? '';
      _industryController.text =
          widget.jobData!['industry'] ?? ''; // Set ngành nghề nếu có
      _jobDescriptionController.text = widget.jobData!['jobDescription'] ?? '';
      _requiredExperienceController.text =
          widget.jobData!['requiredExperience'] ?? '';
      _employmentTypeController.text = widget.jobData!['employmentType'] ?? '';
      _genderRequirementController.text =
          widget.jobData!['genderRequirement'] ?? '';
      _jobLevelController.text = widget.jobData!['jobLevel'] ?? '';
      _salaryRangeController.text = widget.jobData!['salaryRange'] ?? '';
      _workLocationController.text = widget.jobData!['workLocation'] ?? '';
      _vacanciesController.text = widget.jobData!['vacancies'].toString();
      _benefitsController.text =
          (widget.jobData!['benefits'] as List<dynamic>?)?.join(',') ?? '';
      _detailedAddressController.text =
          widget.jobData!['detailedAddress'] ?? '';
      _candidateRequirementsController.text =
          (widget.jobData!['candidateRequirements'] as List<dynamic>?)
                  ?.join(',') ??
              '';
      _companyLogoUrl = widget.jobData!['logoUrl'];
      if (widget.jobData!['applicationDeadline'] != null) {
        _applicationDeadline = DateFormat('dd/MM/yyyy')
            .parse(widget.jobData!['applicationDeadline']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.jobData == null
              ? 'Tạo tin tuyển dụng'
              : 'Chỉnh sửa tin tuyển dụng',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 20),
              _buildIndustrySection(), // Phần nhập ngành nghề
              SizedBox(height: 20),
              _buildJobDescriptionSection(),
              SizedBox(height: 20),
              _buildJobRequirementsSection(),
              SizedBox(height: 20),
              _buildAdditionalInformationSection(),
              SizedBox(height: 20),
              _buildFooterSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _companyLogoFile == null && _companyLogoUrl == null
                  ? CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    )
                  : ClipOval(
                      child: _companyLogoFile != null
                          ? Image.file(
                              _companyLogoFile!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              _companyLogoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.error, color: Colors.red),
                            ),
                    ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề công việc',
                hintText: 'Nhập tiêu đề công việc',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _companyNameController,
              decoration: InputDecoration(
                labelText: 'Tên công ty',
                hintText: 'Nhập tên công ty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập tên công ty' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustrySection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ngành nghề',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _industryController,
              decoration: InputDecoration(
                labelText: 'Ngành nghề',
                hintText: 'Ví dụ: Công nghệ thông tin, Bán lẻ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập ngành nghề' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDescriptionSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mô tả công việc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _jobDescriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mô tả công việc',
                hintText: 'Nhập mô tả công việc',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Vui lòng nhập mô tả công việc' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobRequirementsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yêu cầu công việc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildTextField(
                _requiredExperienceController, 'Kinh nghiệm yêu cầu'),
            SizedBox(height: 10),
            _buildTextField(_employmentTypeController, 'Hình thức làm việc'),
            SizedBox(height: 10),
            _buildTextField(_genderRequirementController, 'Giới tính yêu cầu'),
            SizedBox(height: 10),
            _buildTextField(_jobLevelController, 'Cấp bậc công việc'),
            SizedBox(height: 10),
            TextFormField(
              controller: _candidateRequirementsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Yêu cầu ứng viên',
                hintText: 'Nhập yêu cầu ứng viên (ngăn cách bằng dấu phẩy)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInformationSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin bổ sung',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildTextField(_salaryRangeController, 'Mức lương'),
            SizedBox(height: 10),
            _buildTextField(_workLocationController, 'Địa điểm làm việc'),
            SizedBox(height: 10),
            _buildTextField(
                _detailedAddressController, 'Địa chỉ chi tiết'), // New
            SizedBox(height: 10),
            _buildTextField(_vacanciesController, 'Số lượng tuyển dụng'),
            SizedBox(height: 10),
            TextFormField(
              controller: _benefitsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Quyền lợi',
                hintText: 'Nhập quyền lợi công việc (ngăn cách bằng dấu phẩy)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _applicationDeadline = selectedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Hạn nộp hồ sơ',
                  hintText: 'Chọn ngày',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _applicationDeadline != null
                      ? DateFormat('dd/MM/yyyy').format(_applicationDeadline!)
                      : 'Chọn ngày',
                  style: TextStyle(
                    fontSize: 16,
                    color: _applicationDeadline != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Center(
      child: ElevatedButton(
        onPressed: _saveJobPost,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.jobData == null ? 'Lưu bài đăng' : 'Cập nhật bài đăng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Nhập $label',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Vui lòng nhập $label' : null,
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _companyLogoFile = File(pickedFile.path);
      });
    }
  }

  void _saveJobPost() async {
    if (_formKey.currentState!.validate()) {
      if (_applicationDeadline == null ||
          _applicationDeadline!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hạn nộp hồ sơ không hợp lệ.')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        String? logoUrl;
        if (_companyLogoFile != null) {
          logoUrl = await uploadImageToImgur(_companyLogoFile!);
          if (logoUrl == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Không thể tải lên logo. Vui lòng thử lại.')),
            );
            Navigator.of(context).pop(); // Đóng dialog chờ
            return;
          }
        }

        final userId = FirebaseAuth.instance.currentUser?.uid;

        final jobPost = {
          'title': _titleController.text,
          'companyName': _companyNameController.text,
          'industry': _industryController.text,
          'jobDescription': _jobDescriptionController.text,
          'requiredExperience': _requiredExperienceController.text,
          'employmentType': _employmentTypeController.text,
          'genderRequirement': _genderRequirementController.text,
          'jobLevel': _jobLevelController.text,
          'salaryRange': _salaryRangeController.text,
          'workLocation': _workLocationController.text,
          'detailedAddress': _detailedAddressController.text,
          'vacancies': int.tryParse(_vacanciesController.text) ?? 0,
          'benefits': _benefitsController.text.split(','),
          'candidateRequirements':
              _candidateRequirementsController.text.split(','),
          'applicationDeadline':
              DateFormat('dd/MM/yyyy').format(_applicationDeadline!),
          'logoUrl': logoUrl ?? _companyLogoUrl,
          'createdAt': Timestamp.now(),
          'userId': userId,
        };

        if (widget.jobData != null) {
          await FirebaseFirestore.instance
              .collection('jobPosts')
              .doc(widget.jobData!['id'])
              .update(jobPost);
        } else {
          await FirebaseFirestore.instance.collection('jobPosts').add(jobPost);
        }

        Navigator.of(context).pop(); // Đóng dialog chờ

        _formKey.currentState!.reset();
        setState(() {
          _companyLogoFile = null;
          _applicationDeadline = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bài đăng đã được lưu thành công!')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RecruiterMainScreen(
              userId: FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
          (route) => false, // Xóa tất cả stack trước đó
        );
      } catch (e) {
        Navigator.of(context).pop(); // Đóng dialog chờ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng kiểm tra các trường nhập liệu.')),
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
}
