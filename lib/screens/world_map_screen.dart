// lib/screens/world_map_screen.dart
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'splash_screen.dart';
import 'notebook_page.dart';
import '../constants/country_configs.dart';
import 'country_details_screen.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  List<Country> countries = [];
  final TransformationController _transformationController =
      TransformationController();
  String? selectedCountry;
  final Set<String> selectedCountries = {};
  Color selectedColor = const Color.fromARGB(255, 33, 47, 243);
  final Map<String, Color> countryColors = {};

  @override
  void initState() {
    super.initState();
    loadCountries().then((data) {
      countries = data;
      setState(() {});
    });

    _transformationController.value = Matrix4.identity()
      ..scale(1.2)
      ..translate(-30.0, -50.0);
  }

  loadCountries() async {
    const path = 'assets/svgFiles/worldHigh.svg';
    String content = await rootBundle.loadString(path);
    final document = XmlDocument.parse(content);
    final paths = document.findAllElements('path');
    final countries = <Country>[];
    for (var path in paths) {
      final partId = path.getAttribute('id') ?? '';
      if (partId.isEmpty) {
        continue;
      }
      final partPath = path.getAttribute('d')?.toString() ?? '';
      final partTitle = path.getAttribute('title')?.toString() ?? '';
      countries.add(Country(id: partId, title: partTitle, path: partPath));
    }
    return countries;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ülke rengi seçin'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7B597),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB7B597),
        title: const Text('Dünya Haritası'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens, color: selectedColor),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotebookPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            maxScale: 50,
            minScale: 0.1,
            boundaryMargin: const EdgeInsets.all(100),
            panEnabled: true,
            scaleEnabled: true,
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 1009.6727,
                  height: 665.96301,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ...countries.map((country) {
                        return _getCountryImage(country);
                      })
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selectedCountry != null)
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
                        selectedCountry!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (countryConfigs.containsKey(selectedCountry))
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => countryConfigs[
                                      selectedCountry]!["screen"](context),
                                ),
                              );
                            },
                            child: Text(
                                countryConfigs[selectedCountry]!["buttonText"]),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CountryDetailsScreen(
                                  countryName: selectedCountry!),
                            ),
                          );
                        },
                        child: const Text('Ülke Detayları'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _getCountryImage(Country country) {
    final isSelected = selectedCountries.contains(country.title);

    return ClipPath(
      clipper: CountryClipper(svgPath: country.path),
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            selectedCountry = country.title;
            if (isSelected) {
              selectedCountries.remove(country.title);
              countryColors.remove(country.title);
            } else {
              selectedCountries.add(country.title);
              countryColors[country.title] = selectedColor;
            }
          });
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: isSelected 
              ? countryColors[country.title] ?? const Color(0xFF6B8A7A)
              : const Color(0xFF6B8A7A),
        ),
      ),
    );
  }
}

class Country {
  final String id;
  final String path;
  final String title;

  Country({required this.id, required this.title, required this.path});
}

class CountryClipper extends CustomClipper<Path> {
  final String svgPath;
  CountryClipper({super.reclip, required this.svgPath});

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
