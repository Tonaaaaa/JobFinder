import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic> appliedFilters; // Bộ lọc đã áp dụng

  FilterBottomSheet({
    required this.onApplyFilters,
    required this.appliedFilters,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedLocation;
  String? selectedJobType;
  String? selectedSalaryRange;
  String? selectedIndustry;
  String? selectedJobLevel;

  @override
  void initState() {
    super.initState();
    // Gán giá trị từ appliedFilters cho các biến selected*
    selectedLocation = widget.appliedFilters['location'];
    selectedJobType = widget.appliedFilters['jobType'];
    selectedSalaryRange = widget.appliedFilters['salaryRange'];
    selectedIndustry = widget.appliedFilters['industry'];
    selectedJobLevel = widget.appliedFilters['jobLevel'];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo
              Center(
                child: Container(
                  height: 6,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Tiêu đề
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lọc công việc',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Lọc theo địa điểm
              _buildFilterSection(
                title: 'Địa điểm làm việc',
                icon: Icons.location_on,
                child: DropdownButton<String>(
                  value: selectedLocation,
                  hint: Text('Chọn địa điểm'),
                  isExpanded: true,
                  underline: SizedBox(),
                  items: ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Khác']
                      .map((location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // Lọc theo loại hình công việc
              _buildFilterSection(
                title: 'Loại hình công việc',
                icon: Icons.work_outline,
                child: DropdownButton<String>(
                  value: selectedJobType,
                  hint: Text('Chọn loại hình công việc'),
                  isExpanded: true,
                  underline: SizedBox(),
                  items: ['Toàn thời gian', 'Bán thời gian']
                      .map((jobType) => DropdownMenuItem(
                            value: jobType,
                            child: Text(jobType),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedJobType = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // Lọc theo mức lương
              _buildFilterSection(
                title: 'Mức lương',
                icon: Icons.monetization_on_outlined,
                child: DropdownButton<String>(
                  value: selectedSalaryRange,
                  hint: Text('Chọn mức lương'),
                  isExpanded: true,
                  underline: SizedBox(),
                  items: [
                    '5 - 10 triệu',
                    '10 - 15 triệu',
                    '15 - 20 triệu',
                    '20 - 30 triệu',
                    '30+ triệu'
                  ]
                      .map((range) => DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSalaryRange = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // Lọc theo ngành nghề
              _buildFilterSection(
                title: 'Ngành nghề',
                icon: Icons.business,
                child: DropdownButton<String>(
                  value: selectedIndustry,
                  hint: Text('Chọn ngành nghề'),
                  isExpanded: true,
                  underline: SizedBox(),
                  items: [
                    'Công nghệ thông tin',
                    'Marketing',
                    'Kế toán',
                    'Xây dựng',
                    'Bán lẻ',
                    'Dịch vụ ăn uống',
                    'Sự kiện',
                    'Thương mại điện tử',
                    'Viễn thông',
                    'Giáo dục',
                    'Tài chính - Kế toán',
                    'Giao nhận vận tải'
                  ]
                      .map((industry) => DropdownMenuItem(
                            value: industry,
                            child: Text(industry),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedIndustry = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // Lọc theo cấp bậc công việc
              _buildFilterSection(
                title: 'Cấp bậc công việc',
                icon: Icons.bar_chart,
                child: DropdownButton<String>(
                  value: selectedJobLevel,
                  hint: Text('Chọn cấp bậc công việc'),
                  isExpanded: true,
                  underline: SizedBox(),
                  items:
                      ['Thực tập', 'Nhân viên', 'Chuyên viên', 'Trưởng phòng']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedJobLevel = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 24),

              // Nút hành động
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Xóa toàn bộ bộ lọc
                        setState(() {
                          selectedLocation = null;
                          selectedJobType = null;
                          selectedSalaryRange = null;
                          selectedIndustry = null;
                          selectedJobLevel = null;
                        });

                        // Truyền bộ lọc rỗng lên trên
                        widget.onApplyFilters({});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Bỏ lọc', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters({
                          'location': selectedLocation,
                          'jobType': selectedJobType,
                          'salaryRange': selectedSalaryRange,
                          'industry': selectedIndustry,
                          'jobLevel': selectedJobLevel,
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Áp dụng', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: child,
        ),
      ],
    );
  }
}
