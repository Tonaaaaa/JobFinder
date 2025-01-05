import 'package:flutter/material.dart';

class TypewriterEffect extends StatefulWidget {
  final List<String> texts; // Danh sách các văn bản
  final Duration typingSpeed; // Tốc độ nhập
  final Duration deletingSpeed; // Tốc độ xóa
  final Duration pauseDuration; // Thời gian dừng giữa các văn bản

  const TypewriterEffect({
    required this.texts,
    this.typingSpeed = const Duration(milliseconds: 100),
    this.deletingSpeed = const Duration(milliseconds: 50),
    this.pauseDuration = const Duration(seconds: 1),
  });

  @override
  _TypewriterEffectState createState() => _TypewriterEffectState();
}

class _TypewriterEffectState extends State<TypewriterEffect> {
  int _currentIndex = 0; // Chỉ số của văn bản hiện tại
  String _displayText = ""; // Văn bản hiển thị
  bool _isDeleting = false; // Trạng thái đang xóa

  @override
  void initState() {
    super.initState();
    _startTypingEffect();
  }

  // Bắt đầu hiệu ứng nhập và xóa từng ký tự
  void _startTypingEffect() async {
    while (mounted) {
      final text = widget.texts[_currentIndex];
      if (_isDeleting) {
        // Xóa từng ký tự
        for (int i = text.length; i >= 0; i--) {
          await Future.delayed(widget.deletingSpeed);
          setState(() {
            _displayText = text.substring(0, i);
          });
        }
        _isDeleting = false;
        await Future.delayed(widget.pauseDuration);
        setState(() {
          _currentIndex =
              (_currentIndex + 1) % widget.texts.length; // Đổi văn bản
        });
      } else {
        // Nhập từng ký tự
        for (int i = 0; i <= text.length; i++) {
          await Future.delayed(widget.typingSpeed);
          setState(() {
            _displayText = text.substring(0, i);
          });
        }
        _isDeleting = true;
        await Future.delayed(widget.pauseDuration);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
