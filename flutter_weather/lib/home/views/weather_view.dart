import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_weather/home/data/weather_model.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherState();
}

class _WeatherState extends State<WeatherView> {
  WeatherModel? _weatherModel;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _getAddressFromLatLng(position.latitude, position.longitude);
    _getWeatherFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        '${WeatherModel.nominatimUrl}&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _weatherModel = WeatherModel(
          city: data['address']['city'] ?? 'Unknown',
          temperature: _weatherModel?.temperature ?? '',
          weatherCode: _weatherModel?.weatherCode ?? 'sun',
        );
      });
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<void> _getWeatherFromLatLng(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('${WeatherModel.openMeteoUrl}&latitude=$lat&longitude=$lon'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _weatherModel = WeatherModel(
          city: _weatherModel?.city ?? 'Unknown',
          temperature: data['current_weather']['temperature'].toString(),
          weatherCode: WeatherModel.mapWeatherCodeToString(
            data['current_weather']['weathercode'],
          ),
        );
      });
    } else {
      throw Exception('Failed to load weather');
    }
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
