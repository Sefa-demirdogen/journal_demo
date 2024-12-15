import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key});

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlüğüm'),
        backgroundColor: const Color(0xFFFDF8B8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFDF8B8), // Sayfa arka plan rengi
      body: Stack(
        children: [
          // Çizgiler için CustomPaint
          CustomPaint(
            painter: NotebookLinePainter(),
            child: Container(),
          ),
          // Sol kenar kırmızı çizgi
          Container(
            margin: const EdgeInsets.only(left: 30),
            width: 1,
            height: double.infinity,
            color: const Color.fromARGB(255, 6, 7, 14),
          ),
          // Metin alanı
          Container(
            padding: const EdgeInsets.only(left: 40, top: 0, right: 10),
            child: TextField(
              controller: _textController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Notlarınızı buraya yazın...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 2.0, // Satır yüksekliği
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Not defteri çizgilerini çizen CustomPainter
class NotebookLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round; // Noktaları yuvarlak yapmak için

    double lineHeight = 32.0; // Satırlar arası mesafe
    double dotSpacing = 7.0; // Noktalar arası mesafe
    
    // Yatay noktalı çizgileri çiz
    for (double y = lineHeight; y < size.height; y += lineHeight) {
      for (double x = 0; x < size.width; x += dotSpacing) {
        canvas.drawPoints(
          ui.PointMode.points,
          [Offset(x, y)],
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 