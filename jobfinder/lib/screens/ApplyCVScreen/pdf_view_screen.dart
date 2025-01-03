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

      // Tải tệp từ Cloudinary
      await dio.download(widget.url, path);

      setState(() {
        localPath = path;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải PDF: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xem CV"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : localPath != null
              ? PDFView(
                  filePath: localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageFling: true,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi hiển thị PDF: $error")),
                    );
                  },
                  onRender: (pages) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("PDF tải thành công, $pages trang!")),
                    );
                  },
                )
              : Center(child: Text("Không thể tải PDF")),
    );
  }
}
