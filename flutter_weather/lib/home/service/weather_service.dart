import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_weather/home/data/weather_model.dart';

class WeatherService {
  WeatherModel? _weatherModel;

  Future<WeatherModel> getWeatherModel() async {
    return _weatherModel!;
  }

  Future<void> initialize(double lat, double lon) async {
    final cityName = await getCityName(lat, lon);
    final weather = await getWeather(lat, lon);

    _weatherModel = WeatherModel(
      city: cityName,
      temperature: weather.temperature,
      weatherCode: weather.weatherCode,
    );
  }

  Future<String> getCityName(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '${WeatherModel.nominatimUrl}&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['address']['city'] ?? 'Unknown';
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<WeatherModel> getWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('${WeatherModel.openMeteoUrl}&latitude=$lat&longitude=$lon'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherModel(
        city: 'Unknown', 
        temperature: data['current_weather']['temperature'].toString(),
        weatherCode: WeatherModel.mapWeatherCodeToString(
          data['current_weather']['weathercode'],
        ),
      );
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
