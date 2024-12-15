import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

class TurkeyMapScreen extends StatefulWidget {
  const TurkeyMapScreen({super.key});

  @override
  State<TurkeyMapScreen> createState() => _TurkeyMapScreenState();
}

class _TurkeyMapScreenState extends State<TurkeyMapScreen> {
  List<City> cities = [];
  final TransformationController _transformationController =
      TransformationController();
  String? selectedCity;
  final Set<String> selectedCities = {};

  @override
  void initState() {
    super.initState();
    loadCities().then((data) {
      cities = data;
      setState(() {});
    });

    _transformationController.value = Matrix4.identity()
      ..scale(1.2)
      ..translate(20.0, 20.0);
  }

  loadCities() async {
    const path = 'assets/svgFiles/turkeyHigh.svg';
    String content = await rootBundle.loadString(path);
    final document = XmlDocument.parse(content);
    final paths = document.findAllElements('path');
    final cities = <City>[];
    for (var path in paths) {
      final partId = path.getAttribute('id') ?? '';
      if (partId.isEmpty) {
        continue;
      }
      final partPath = path.getAttribute('d')?.toString() ?? '';
      final partTitle = path.getAttribute('title')?.toString() ?? '';
      cities.add(City(id: partId, title: partTitle, path: partPath));
    }
    return cities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 122, 108, 62),
          title: const Text('Türkiye Haritası')),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            maxScale: 10,
            minScale: 0.1,
            boundaryMargin: const EdgeInsets.all(100),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 1009.6727,
                  height: 665.96301,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ...cities.map((city) {
                        return _getCityImage(city);
                      })
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selectedCity != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedCity!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getCityImage(City city) {
    final isSelected = selectedCities.contains(city.title);

    return ClipPath(
      clipper: CityClipper(svgPath: city.path),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedCities.remove(city.title);
            } else {
              selectedCities.add(city.title);
            }
            selectedCity = city.title;
          });
          print(city.title);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: isSelected
              ? const Color.fromARGB(255, 33, 47, 243)
              : const Color.fromARGB(255, 110, 110, 110),
        ),
      ),
    );
  }
}

class City {
  final String id;
  final String path;
  final String title;

  City({required this.id, required this.title, required this.path});
}

class CityClipper extends CustomClipper<Path> {
  final String svgPath;
  CityClipper({super.reclip, required this.svgPath});

  @override
  Path getClip(Size size) {
    final path = parseSvgPathData(svgPath);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}