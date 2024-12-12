import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import '../config/config.dart';

class CountryDetailsScreen extends StatefulWidget {
  final String countryName;

  const CountryDetailsScreen({
    super.key,
    required this.countryName,
  });

  @override
  State<CountryDetailsScreen> createState() => _CountryDetailsScreenState();
}

class _CountryDetailsScreenState extends State<CountryDetailsScreen> {
  Map<String, dynamic>? countryData;
  Map<String, dynamic>? weatherData;
  bool isLoading = true;
  final String openWeatherApiKey = Config.openWeatherApiKey;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      await fetchCountryData();
      if (countryData != null) {
        await fetchWeatherData();
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Veri çekme hatası: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCountryData() async {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v3.1/name/${widget.countryName}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        countryData = data[0];
      });
    }
  }

  Future<void> fetchWeatherData() async {
    try {
      if (countryData != null && countryData!['capital'] != null) {
        final response = await http.get(
          Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?q=${countryData!['capital'][0]}&appid=$openWeatherApiKey&units=metric&lang=tr'),
        );

        if (response.statusCode == 200) {
          setState(() {
            weatherData = json.decode(response.body);
          });
          print('Hava durumu verileri: $weatherData');
        } else {
          print('Hava durumu API hatası: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Hava durumu veri çekme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 37, 36),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderSection(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeatherSection(),
                        const SizedBox(height: 20),
                        _buildTravelInfoSection(),
                        const SizedBox(height: 20),
                        _buildBasicInfoSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(countryData!['flags']['png']),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF3E2723).withOpacity(0.8),
                const Color(0xFF3E2723),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            widget.countryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherSection() {
    print('Weather Data: $weatherData');

    if (weatherData == null) {
      print('Hava durumu verileri yok!');
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Başkentte Hava Durumu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    countryData!['capital'][0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${weatherData!['weather'][0]['description']}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                '${weatherData!['main']['temp'].round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherInfo(
                'Nem',
                '${weatherData!['main']['humidity']}%',
                Icons.water_drop,
              ),
              _buildWeatherInfo(
                'Rüzgar',
                '${weatherData!['wind']['speed']} m/s',
                Icons.air,
              ),
              _buildWeatherInfo(
                'Basınç',
                '${weatherData!['main']['pressure']} hPa',
                Icons.speed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTravelInfoSection() {
    return _buildSection(
      'Seyahat Bilgileri',
      Icons.flight,
      Column(
        children: [
          _buildTravelInfoItem(
            'En İyi Ziyaret Zamanı',
            _getBestTimeToVisit(countryData!['region']),
            Icons.calendar_today,
          ),
          _buildTravelInfoItem(
            'Vize Durumu',
            _getVisaInfo(),
            Icons.document_scanner,
          ),
          _buildTravelInfoItem(
            'Saat Dilimi',
            countryData!['timezones'][0],
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelInfoItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      'Temel Bilgiler',
      Icons.info_outline,
      Column(
        children: [
          _buildInfoGrid(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final List<Map<String, dynamic>> infoItems = [
      {
        'icon': Icons.location_city,
        'title': 'Başkent',
        'value': countryData!['capital']?[0] ?? 'Bilinmiyor',
      },
      {
        'icon': Icons.people,
        'title': 'Nüfus',
        'value': _formatNumber(countryData!['population']),
      },
      {
        'icon': Icons.public,
        'title': 'Bölge',
        'value': countryData!['region'] ?? 'Bilinmiyor',
      },
      {
        'icon': Icons.map,
        'title': 'Alt Bölge',
        'value': countryData!['subregion'] ?? 'Bilinmiyor',
      },
      {
        'icon': Icons.attach_money,
        'title': 'Para Birimi',
        'value': _getCurrencies(countryData!['currencies']),
      },
      {
        'icon': Icons.language,
        'title': 'Diller',
        'value': _getLanguages(countryData!['languages']),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: infoItems.length,
      itemBuilder: (context, index) {
        return _buildInfoCard(
          infoItems[index]['icon'],
          infoItems[index]['title'],
          infoItems[index]['value'],
        );
      },
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int? number) {
    if (number == null) return 'Bilinmiyor';
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _getCurrencies(Map<String, dynamic>? currencies) {
    if (currencies == null) return 'Bilinmiyor';
    return currencies.values
        .map((currency) => '${currency['name']} (${currency['symbol']})')
        .join(', ');
  }

  String _getLanguages(Map<String, dynamic>? languages) {
    if (languages == null) return 'Bilinmiyor';
    return languages.values.join(', ');
  }

  String _getBestTimeToVisit(String region) {
    switch (region) {
      case 'Europe':
        return 'Mayıs - Eylül arası';
      case 'Asia':
        return 'Mart - Mayıs, Eylül - Kasım arası';
      case 'Africa':
        return 'Haziran - Ağustos arası';
      case 'Americas':
        return 'Nisan - Ekim arası';
      default:
        return 'Yıl boyunca ziyaret edilebilir';
    }
  }

  String _getVisaInfo() {
    return 'Vize gerekli olabilir. Detaylı bilgi için Dışişleri Bakanlığı\'nın web sitesini ziyaret edin.';
  }
}
