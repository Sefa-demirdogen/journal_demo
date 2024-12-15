import 'package:flutter/material.dart';
import '../../models/map_item.dart';
import 'map_clipper.dart';

class MapItemWidget extends StatelessWidget {
  final MapItem item;
  final bool isSelected;
  final Color? selectedColor;
  final Function(MapItem) onTap;

  const MapItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MapClipper(svgPath: item.path),
      child: GestureDetector(
        onTapDown: (_) => onTap(item),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: isSelected 
              ? selectedColor ?? const Color(0xFF6B8A7A)
              : const Color(0xFF6B8A7A),
        ),
      ),
    );
  }
} 