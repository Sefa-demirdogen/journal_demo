import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get openWeatherApiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? '';
}


