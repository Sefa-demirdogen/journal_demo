import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class MapClipper extends CustomClipper<Path> {
  final String svgPath;
  
  MapClipper({required this.svgPath});

  @override
  Path getClip(Size size) {
    final path = parseSvgPathData(svgPath);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
} 