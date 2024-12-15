// generic_map_screen.dart
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

class GenericMapScreen extends StatefulWidget {
  final String countryName;
  final String svgAssetPath;
  final Color backgroundColor;

  const GenericMapScreen({
    super.key,
    required this.countryName,
    required this.svgAssetPath,
    this.backgroundColor = const Color(0xFFB7B597),
  });

  @override
  State<GenericMapScreen> createState() => _GenericMapScreenState();
}

class _GenericMapScreenState extends State<GenericMapScreen> {
  List<Region> regions = [];
  final TransformationController _transformationController =
      TransformationController();
  String? selectedRegion;
  final Set<String> selectedRegions = {};

  @override
  void initState() {
    super.initState();
    loadRegions().then((data) {
      regions = data;
      setState(() {});
    });

    _transformationController.value = Matrix4.identity()
      ..scale(1.2)
      ..translate(-30.0, -50.0);
  }

  loadRegions() async {
    String content = await rootBundle.loadString(widget.svgAssetPath);
    final document = XmlDocument.parse(content);
    final paths = document.findAllElements('path');
    final regions = <Region>[];
    for (var path in paths) {
      final regionId = path.getAttribute('id') ?? '';
      if (regionId.isEmpty) {
        continue;
      }
      final regionPath = path.getAttribute('d')?.toString() ?? '';
      final regionTitle = path.getAttribute('title')?.toString() ?? '';
      regions.add(Region(id: regionId, title: regionTitle, path: regionPath));
    }
    return regions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7B597),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB7B597),
        title: Text('${widget.countryName} Haritası'),
      ),
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
                      ...regions.map((region) {
                        return _getRegionImage(region);
                      })
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selectedRegion != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedRegion!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _getRegionImage(Region region) {
    final isSelected = selectedRegions.contains(region.title);

    return ClipPath(
      clipper: RegionClipper(svgPath: region.path),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedRegions.remove(region.title);
            } else {
              selectedRegions.add(region.title);
            }
            selectedRegion = region.title;
          });
          print(region.title);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: isSelected
              ? const Color.fromARGB(255, 33, 47, 243)
              : const Color(0xFF6B8A7A),
        ),
      ),
    );
  }
}

class Region {
  final String id;
  final String path;
  final String title;

  Region({required this.id, required this.title, required this.path});
}

class RegionClipper extends CustomClipper<Path> {
  final String svgPath;
  RegionClipper({super.reclip, required this.svgPath});

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