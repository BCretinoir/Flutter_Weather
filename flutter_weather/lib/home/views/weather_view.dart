import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_weather/home/data/weather_model.dart';
import 'package:flutter_weather/home/service/weather_service.dart';

class WeatherView extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherView({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherView> createState() => _WeatherState();
}

class _WeatherState extends State<WeatherView> {
  WeatherModel? _weatherModel;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _initializeWeather();
  }

  Future<void> _initializeWeather() async {
    await _weatherService.initialize(widget.latitude, widget.longitude);
    _weatherModel = await _weatherService.getWeatherModel();
    setState(() {});
  }

  Widget _getWeatherAnimation(String weather) {
    switch (weather.toLowerCase()) {
      case 'cloud':
        return Lottie.asset('assets/img/cloud.json', width: 200, height: 200);
      case 'halfsun':
        return Lottie.asset('assets/img/halfsun.json', width: 200, height: 200);
      case 'thunder':
        return Lottie.asset('assets/img/thunder.json', width: 200, height: 200);
      case 'sun':
        return Lottie.asset('assets/img/sun.json', width: 200, height: 200);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Weather in ${_weatherModel?.city ?? 'Unknown'}',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _getWeatherAnimation(_weatherModel?.weatherCode ?? 'sun'),
            const SizedBox(height: 20),
            Text(
              'Temperature: ${_weatherModel?.temperature ?? ''}°C',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
