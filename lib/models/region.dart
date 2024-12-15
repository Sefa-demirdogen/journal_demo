import 'map_item.dart';

class Region extends MapItem {
  Region({
    required String id,
    required String title,
    required String path,
  }) : super(id: id, title: title, path: path);

  factory Region.fromSvgElement(dynamic element) {
    return Region(
      id: element.getAttribute('id') ?? '',
      title: element.getAttribute('title') ?? '',
      path: element.getAttribute('d')?.toString() ?? '',
    );
  }
} 