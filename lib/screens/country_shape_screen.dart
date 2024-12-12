import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class CountryShapeScreen extends StatelessWidget {
  final String countryPath;
  final String countryName;

  const CountryShapeScreen({
    super.key,
    required this.countryPath,
    required this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037),
        title: Text('$countryName Haritası'),
      ),
      body: Center(
        child: FittedBox(
          child: CustomPaint(
            size: const Size(500, 500),
            painter: CountryShapePainter(
              svgPath: countryPath,
            ),
          ),
        ),
      ),
    );
  }
}

class CountryShapePainter extends CustomPainter {
  final String svgPath;

  CountryShapePainter({required this.svgPath});

  @override
  void paint(Canvas canvas, Size size) {
    final path = parseSvgPathData(svgPath);
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 33, 47, 243)
      ..style = PaintingStyle.fill;

    // SVG yolunu ölçeklendirme
    final bounds = path.getBounds();
    final scale = size.width / bounds.width;
    final matrix = Matrix4.identity()
      ..scale(scale)
      ..translate(-bounds.left, -bounds.top);

    final scaledPath = path.transform(matrix.storage);
    canvas.drawPath(scaledPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
