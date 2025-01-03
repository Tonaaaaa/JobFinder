import 'package:intl/intl.dart';

class JobPostModel {
  final String jobId;
  final String userId;
  final String title;
  final String companyName;
  final String jobDescription;
  final String requiredExperience;
  final String employmentType;
  final String salaryRange;
  final String workLocation;
  final String genderRequirement;
  final String jobLevel;
  final int vacancies;
  final DateTime applicationDeadline;
  final List<String> candidateRequirements; // Yêu cầu ứng viên
  final List<String> benefits;
  final String detailedAddress; // Địa chỉ chi tiết
  final String? companyLogo;

  JobPostModel({
    required this.jobId,
    required this.userId,
    required this.title,
    required this.companyName,
    required this.jobDescription,
    required this.requiredExperience,
    required this.employmentType,
    required this.salaryRange,
    required this.workLocation,
    required this.genderRequirement,
    required this.jobLevel,
    required this.vacancies,
    required this.applicationDeadline,
    required this.candidateRequirements,
    required this.benefits,
    required this.detailedAddress,
    this.companyLogo,
  });

  // Chuyển đổi từ JSON sang JobPostModel
  factory JobPostModel.fromJson(Map<String, dynamic> json) {
    String rawDate = json['applicationDeadline'] as String? ?? '';
    DateTime parsedDate;

    try {
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(rawDate)) {
        parsedDate = DateFormat('dd/MM/yyyy').parse(rawDate);
      } else {
        parsedDate = DateTime.parse(rawDate);
      }
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return JobPostModel(
      jobId: json['jobId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? 'Không có tiêu đề',
      companyName: json['companyName'] as String? ?? 'Không có công ty',
      jobDescription: json['jobDescription'] as String? ?? 'Không có mô tả',
      requiredExperience:
          json['requiredExperience'] as String? ?? 'Không yêu cầu',
      employmentType: json['employmentType'] as String? ?? 'Không yêu cầu',
      salaryRange: json['salaryRange'] as String? ?? 'Không xác định',
      workLocation: json['workLocation'] as String? ?? 'Không xác định',
      genderRequirement:
          json['genderRequirement'] as String? ?? 'Không yêu cầu',
      jobLevel: json['jobLevel'] as String? ?? 'Không yêu cầu',
      vacancies: json['vacancies'] as int? ?? 0,
      applicationDeadline: parsedDate,
      candidateRequirements: (json['candidateRequirements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      detailedAddress: json['detailedAddress'] as String? ?? 'Không xác định',
      companyLogo: json['companyLogo'] as String?,
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'userId': userId,
      'title': title,
      'companyName': companyName,
      'jobDescription': jobDescription,
      'requiredExperience': requiredExperience,
      'employmentType': employmentType,
      'salaryRange': salaryRange,
      'workLocation': workLocation,
      'genderRequirement': genderRequirement,
      'jobLevel': jobLevel,
      'vacancies': vacancies,
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'candidateRequirements': candidateRequirements,
      'benefits': benefits,
      'detailedAddress': detailedAddress,
      'companyLogo': companyLogo,
    };
  }
}
