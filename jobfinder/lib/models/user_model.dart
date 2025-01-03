class UserModel {
  final String userId; // Unique ID của người dùng
  final String name; // Họ và tên
  final String email; // Email của người dùng
  final String phoneNumber; // Số điện thoại
  final String role; // Vai trò: 'Employee' hoặc 'Job'
  final String? avatarUrl; // URL ảnh đại diện (có thể null)
  final DateTime createdAt; // Thời gian tạo tài khoản
  final String education; // Trình độ học vấn
  final String experience; // Kinh nghiệm làm việc
  final List<String>? desiredJobs; // Danh sách công việc mong muốn
  final List<String>? desiredLocations; // Danh sách địa điểm làm việc mong muốn

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
    required this.education,
    required this.experience,
    this.desiredJobs, // Có thể null nếu chưa cập nhật
    this.desiredLocations, // Có thể null nếu chưa cập nhật
  });

  // Chuyển đổi từ JSON sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      education: json['education'] as String,
      experience: json['experience'] as String,
      desiredJobs: (json['desiredJobs'] as List<dynamic>?)
          ?.map((job) => job as String)
          .toList(),
      desiredLocations: (json['desiredLocations'] as List<dynamic>?)
          ?.map((location) => location as String)
          .toList(),
    );
  }

  // Chuyển đổi từ UserModel sang JSON để lưu trữ Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'education': education,
      'experience': experience,
      'desiredJobs': desiredJobs, // Lưu danh sách công việc mong muốn
      'desiredLocations': desiredLocations, // Lưu danh sách địa điểm mong muốn
    };
  }
}
