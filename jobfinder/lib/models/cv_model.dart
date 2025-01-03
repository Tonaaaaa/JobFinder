class CVModel {
  final String cvId; // ID CV
  final String jobId; // ID bài viết
  final String userId; // ID ứng viên
  final String name; // Tên ứng viên
  final String email; // Email ứng viên
  final String phone; // Số điện thoại
  final String coverLetter; // Thư giới thiệu
  final String cvUrl; // Đường dẫn CV
  final String status; // Trạng thái ứng tuyển
  final DateTime createdAt; // Ngày nộp CV

  CVModel({
    required this.cvId,
    required this.jobId,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.coverLetter,
    required this.cvUrl,
    required this.status, // Trạng thái
    required this.createdAt,
  });

  // Chuyển đổi từ JSON
  factory CVModel.fromJson(Map<String, dynamic> json) {
    return CVModel(
      cvId: json['cvId'] as String,
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      coverLetter: json['coverLetter'] as String,
      cvUrl: json['cvUrl'] as String,
      status: json['status'] as String, // Thêm status
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'cvId': cvId,
      'jobId': jobId,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'coverLetter': coverLetter,
      'cvUrl': cvUrl,
      'status': status, // Thêm status
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
