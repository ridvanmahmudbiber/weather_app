class Weather {
  final String cityName;
  final double temperature;
  final String weatherDescription;
  final String icon;
  final String dateTime;
  final double maxTemperature;
  final double minTemperature;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherDescription,
    required this.icon,
    required this.dateTime,
    required this.maxTemperature,
    required this.minTemperature,
  });

  // Tarihi gün/ay/yıl formatında dönen getter
  String get formattedDay {
    DateTime date = DateTime.parse(dateTime);
    return "${date.day}/${date.month}/${date.year}";
  }

  // Sadece saati dönen getter
  String get formattedTime {
    DateTime date = DateTime.parse(dateTime);
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}"; // Örnek: 14:05
  }

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      weatherDescription: json['weather'][0]['description'] ?? 'No description',
      icon: json['weather'][0]['icon'] ?? '01d',
      dateTime: json['dt_txt'] ?? DateTime.now().toIso8601String(),
      maxTemperature: (json['main']['temp_max'] ?? 0.0).toDouble(),
      minTemperature: (json['main']['temp_min'] ?? 0.0).toDouble(),
    );
  }
}
