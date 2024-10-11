import 'package:flutter/material.dart';
import 'package:weather_app/screens/get_started_page.dart';
import 'package:weather_app/screens/location_selection_screen.dart';
import 'package:weather_app/screens/saved_locations.dart';
import 'package:weather_app/screens/weekly_weather_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => GetStartedPage(),
        '/locationSelection': (context) => LocationSelectionScreen(),
        '/weeklyWeather': (context) => WeeklyWeatherScreen(),
        '/savedLocations': (context) => SavedLocationsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
