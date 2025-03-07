import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherState();
}

class _WeatherState extends State<WeatherView> {
  String _city = '';
  String _weather = 'sun';
  String _temperature = '';

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
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _city = data['address']['city'] ?? 'Unknown';
      });
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<void> _getWeatherFromLatLng(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _temperature = data['current_weather']['temperature'].toString();

        int weatherCode = data['current_weather']['weathercode'];
        if (weatherCode == 0) {
          _weather = 'sun';
        } else if (weatherCode >= 1 && weatherCode <= 3) {
          _weather = 'cloud';
        } else if (weatherCode == 95) {
          _weather = 'thunder'; 
        } else {
          _weather = 'cloud';
        }
      });
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Widget _getWeatherAnimation(String weather) {
    switch (weather.toLowerCase()) {
      case 'cloud':
        return Lottie.asset('assets/img/cloud.json', width: 200, height: 200);
      case 'half sun':
        return Lottie.asset(
          'assets/img/half_sun.json',
          width: 200,
          height: 200,
        );
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
              'Weather in $_city',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _getWeatherAnimation(_weather),
            const SizedBox(height: 20),
            Text(
              'Temperature: $_temperature°C',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
