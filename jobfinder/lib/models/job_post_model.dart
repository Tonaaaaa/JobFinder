import 'package:cloud_firestore/cloud_firestore.dart';

class JobPostModel {
  String? id; // ID của bài đăng
  String? title; // Tiêu đề công việc
  String? companyName; // Tên công ty
  String? logoUrl; // URL của logo công ty
  String? industry; // Ngành nghề của công ty
  String? description; // Mô tả công việc
  String? requiredExperience; // Kinh nghiệm yêu cầu
  String? employmentType; // Hình thức làm việc (Full-time, Part-time, Freelance)
  String? genderRequirement; // Yêu cầu giới tính (nếu có)
  String? jobLevel; // Cấp bậc công việc (Intern, Junior, Senior, Manager)
  String? salaryRange; // Mức lương
  String? workLocation; // Địa điểm làm việc
  String? detailedAddress; // Địa chỉ chi tiết
  int? vacancies; // Số lượng tuyển dụng
  List<String>? benefits; // Các quyền lợi
  List<String>? candidateRequirements; // Yêu cầu ứng viên
  DateTime? applicationDeadline; // Hạn nộp hồ sơ
  DateTime? createdAt; // Ngày tạo bài đăng
  String? userId; // ID người dùng đăng bài (recruiter)

  // Constructor
  JobPostModel({
    this.id,
    this.title,
    this.companyName,
    this.logoUrl,
    this.industry,
    this.description,
    this.requiredExperience,
    this.employmentType,
    this.genderRequirement,
    this.jobLevel,
    this.salaryRange,
    this.workLocation,
    this.detailedAddress,
    this.vacancies,
    this.benefits,
    this.candidateRequirements,
    this.applicationDeadline,
    this.createdAt,
    this.userId,
  });

  // Factory method để chuyển đổi từ Firestore
  factory JobPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobPostModel(
      id: doc.id,
      title: data['title'] ?? '',
      companyName: data['companyName'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      industry: data['industry'] ?? 'Không rõ ngành nghề',
      description: data['description'] ?? '',
      requiredExperience: data['requiredExperience'] ?? '',
      employmentType: data['employmentType'] ?? '',
      genderRequirement: data['genderRequirement'] ?? '',
      jobLevel: data['jobLevel'] ?? '',
      salaryRange: data['salaryRange'] ?? '',
      workLocation: data['workLocation'] ?? '',
      detailedAddress: data['detailedAddress'] ?? '',
      vacancies: data['vacancies'] ?? 0,
      benefits: List<String>.from(data['benefits'] ?? []),
      candidateRequirements:
          List<String>.from(data['candidateRequirements'] ?? []),
      applicationDeadline: data['applicationDeadline'] != null
          ? (data['applicationDeadline'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      userId: data['userId'] ?? '',
    );
  }

  // Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'companyName': companyName,
      'logoUrl': logoUrl,
      'industry': industry ?? 'Không rõ ngành nghề',
      'description': description,
      'requiredExperience': requiredExperience,
      'employmentType': employmentType,
      'genderRequirement': genderRequirement,
      'jobLevel': jobLevel,
      'salaryRange': salaryRange,
      'workLocation': workLocation,
      'detailedAddress': detailedAddress,
      'vacancies': vacancies ?? 0,
      'benefits': benefits ?? [],
      'candidateRequirements': candidateRequirements ?? [],
      'applicationDeadline': applicationDeadline,
      'createdAt': createdAt ?? DateTime.now(),
      'userId': userId,
    };
  }
}
