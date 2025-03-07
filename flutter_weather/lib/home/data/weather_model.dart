import 'package:flutter/foundation.dart';

class WeatherModel {
  final String city;
  final String temperature;
  final String weatherCode;

  static const String nominatimUrl =
      'https://nominatim.openstreetmap.org/reverse?format=json';
  static const String openMeteoUrl =
      'https://api.open-meteo.com/v1/forecast?current_weather=true';

  WeatherModel({
    required this.city,
    required this.temperature,
    required this.weatherCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
    city: json['address']['city'] ?? 'Unknown',
    temperature: json['current_weather']['temperature'].toString(),
    weatherCode: json['current_weather']['weathercode'].toString(),
  );

  static String mapWeatherCodeToString(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'sun';
      case 1:
      case 2:
      case 3:
        return 'cloud';
      case 95:
        return 'thunder';
      case 96:
      case 99:
        return 'halfsun';
      default:
        return 'sun';
    }
  }
}
