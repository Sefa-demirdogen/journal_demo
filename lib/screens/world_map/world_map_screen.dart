import 'package:flutter/material.dart';
import '../../models/map_item.dart';
import '../../models/country.dart';
import '../../services/map_service.dart';
import '../../widgets/map/map_item_widget.dart';
import '../../widgets/common/color_picker_dialog.dart';
import '../../constants/colors.dart';
import '../../constants/country_configs.dart';
import '../country_details_screen.dart';
import '../splash_screen.dart';
import '../notebook_page.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  List<Country> countries = [];
  final TransformationController _transformationController = TransformationController();
  String? selectedCountry;
  final Set<String> selectedCountries = {};
  Color selectedColor = AppColors.defaultSelectedColor;
  final Map<String, Color> countryColors = {};

  @override
  void initState() {
    super.initState();
    _loadMap();
    _initializeTransformation();
  }

  void _loadMap() async {
    final loadedCountries = await MapService.loadWorldMap();
    setState(() => countries = loadedCountries);
  }

  void _initializeTransformation() {
    _transformationController.value = Matrix4.identity()
      ..scale(1.2)
      ..translate(-30.0, -50.0);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        currentColor: selectedColor,
        onColorChanged: (color) => setState(() => selectedColor = color),
      ),
    );
  }

  void _handleCountryTap(MapItem country) {
    final isSelected = selectedCountries.contains(country.title);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildMap(),
          if (selectedCountry != null) _buildSelectedCountryInfo(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      title: const Text('Dünya Haritası'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.color_lens, color: selectedColor),
          onPressed: _showColorPicker,
        ),
        IconButton(
          icon: const Icon(Icons.book),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotebookPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return InteractiveViewer(
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
              children: countries.map((country) => MapItemWidget(
                item: country,
                isSelected: selectedCountries.contains(country.title),
                selectedColor: countryColors[country.title],
                onTap: _handleCountryTap,
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCountryInfo() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => countryConfigs[selectedCountry]!["screen"](context),
                      ),
                    ),
                    child: Text(countryConfigs[selectedCountry]!["buttonText"]),
                  ),
                ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CountryDetailsScreen(countryName: selectedCountry!),
                  ),
                ),
                child: const Text('Ülke Detayları'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 