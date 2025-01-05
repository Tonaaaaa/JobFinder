import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewScreen extends StatefulWidget {
  final String url; // URL của tệp PDF

  PdfViewScreen({required this.url});

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  String? localPath; // Đường dẫn tệp cục bộ
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = "${tempDir.path}/downloaded_cv.pdf";

      Dio dio = Dio();
      dio.options.headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        "Accept": "application/pdf",
      };

      // Tải tệp từ URL
      await dio.download(widget.url, path);

      setState(() {
        localPath = path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        localPath = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị thông báo lỗi nếu `localPath` là null
    if (localPath == null && !isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi tải PDF")),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Xem CV",
          style: TextStyle(color: Colors.white), // Thay đổi màu chữ thành trắng
        ),
        backgroundColor: Colors.black,
        iconTheme:
            IconThemeData(color: Colors.white), // Màu biểu tượng nút back
      ),
      backgroundColor: Colors.black, // Nền của màn hình
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : localPath != null
              ? PDFView(
                  filePath: localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageFling: true,
                  backgroundColor: Colors.black, // Nền của PDF
                  onError: (error) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lỗi hiển thị PDF: $error")),
                      );
                    });
                  },
                  onRender: (pages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("PDF tải thành công, $pages trang!")),
                      );
                    });
                  },
                )
              : Center(
                  child: Text(
                    "Không thể tải PDF",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
    );
  }
}
