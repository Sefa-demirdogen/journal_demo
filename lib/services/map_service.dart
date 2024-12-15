import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import '../models/country.dart';
import '../models/region.dart';

class MapService {
  static Future<List<Country>> loadWorldMap() async {
    const path = 'assets/svgFiles/worldHigh.svg';
    return _loadMapItems(path, (element) => Country.fromSvgElement(element));
  }

  static Future<List<Region>> loadCountryMap(String svgPath) async {
    return _loadMapItems(svgPath, (element) => Region.fromSvgElement(element));
  }

  static Future<List<T>> _loadMapItems<T>(
    String path, 
    T Function(dynamic) fromElement
  ) async {
    try {
      String content = await rootBundle.loadString(path);
      final document = XmlDocument.parse(content);
      final paths = document.findAllElements('path');
      final items = <T>[];

      for (var path in paths) {
        final id = path.getAttribute('id');
        if (id?.isEmpty ?? true) continue;
        
        items.add(fromElement(path));
      }

      return items;
    } catch (e) {
      print('Error loading map: $e');
      return [];
    }
  }
} 