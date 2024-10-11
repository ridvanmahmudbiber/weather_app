import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  final String apiKey = '5af478c0e56027af8be5b2539eca52a5';


  // Anlık hava durumu verisini alır
  Future<Weather> getCurrentWeather(String city) async {
    final Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=tr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Hava durumu verisi alınamadı');
    }
  }

  // Saatlik hava durumu verisini alır
  Future<List<Weather>> getHourlyWeather(String city) async {
    final Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=tr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['list'];
      return data.map((item) => Weather.fromJson(item)).toList();
    } else {
      throw Exception('Saatlik hava durumu verisi alınamadı');
    }
  }

  // Haftalık hava durumu verisini alır
  Future<List<Weather>> getWeeklyWeather(String city) async {
    final Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=tr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['list'];
      Map<String, Weather> dailyWeather = {};

      // Her gün için verileri birleştir
      for (var item in data) {
        Weather weather = Weather.fromJson(item);
        String dateKey = weather.dateTime.split(' ')[0]; // Sadece tarihi al

        // Eğer bu tarihe ait bir veri yoksa, ekle
        if (!dailyWeather.containsKey(dateKey)) {
          dailyWeather[dateKey] = weather;
        }
      }

      // Günlük hava durumu verilerini listeye dönüştür
      return dailyWeather.values.toList().take(7).toList(); // İlk 7 günü döndür
    } else {
      throw Exception('Haftalık hava durumu verisi alınamadı');
    }
  }
}
