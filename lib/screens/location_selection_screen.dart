import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather.dart';
import '../services/weather_services.dart';
import '../custom_bottom_navigation_bar.dart';

class LocationSelectionScreen extends StatefulWidget {
  @override
  _LocationSelectionScreenState createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? selectedCity;
  Weather? currentWeather;
  List<Weather> hourlyWeather = [];
  int _currentIndex = 1; // Alt navigasyon çubuğu için güncel indeks

  // Türkiye'nin şehirleri
  final List<String> cities = [
    "Adana", "Adıyaman", "Afyonkarahisar", "Ağrı", "Aksaray", "Amasya",
    "Ankara", "Antalya", "Ardahan", "Artvin", "Aydın", "Balıkesir",
    "Bartın", "Batman", "Bayburt", "Bilecik", "Bingöl", "Bitlis",
    "Bolu", "Burdur", "Bursa", "Çanakkale", "Çankırı", "Çorum",
    "Denizli", "Diyarbakır", "Düzce", "Edirne", "Elazığ", "Erzincan",
    "Erzurum", "Eskişehir", "Gaziantep", "Giresun", "Gümüşhane", "Hakkari",
    "Hatay", "Iğdır", "Isparta", "İstanbul", "İzmir", "Kahramanmaraş",
    "Karabük", "Karaman", "Kars", "Kastamonu", "Kayseri", "Kırıkkale",
    "Kırklareli", "Kırşehir", "Kilis", "Kocaeli", "Konya", "Kütahya",
    "Malatya", "Manisa", "Mardin", "Mersin", "Muğla", "Muş",
    "Nevşehir", "Niğde", "Ordu", "Osmaniye", "Rize", "Sakarya",
    "Samsun", "Siirt", "Sinop", "Sivas", "Şanlıurfa", "Şırnak",
    "Tekirdağ", "Tokat", "Trabzon", "Tunceli", "Uşak", "Van",
    "Yalova", "Yozgat", "Zonguldak"
  ];

  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  // Seçilen şehri yükleme
  Future<void> _loadSelectedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? city = prefs.getString('selectedCity') ?? 'İstanbul'; // Varsayılan şehir: İstanbul
    setState(() {
      selectedCity = city;
    });
    fetchCurrentWeather(city);
  }

  // Mevcut hava durumunu alma
  void fetchCurrentWeather(String city) async {
    try {
      Weather weather = await _weatherService.getCurrentWeather(city);
      setState(() {
        currentWeather = weather;
        selectedCity = city;
      });
      fetchHourlyWeather(city);
      // Şehir ve hava durumu bilgilerini kaydet
      _saveSelectedCity(city); // Seçilen şehri kaydet
      _saveWeatherData(weather); // Hava durumu verilerini kaydet
    } catch (e) {
      print(e);
      _showSnackBar('Hava durumu alınamadı. Lütfen tekrar deneyin.');
    }
  }

  // Saatlik hava durumunu alma
  void fetchHourlyWeather(String city) async {
    try {
      List<Weather> weatherData = await _weatherService.getHourlyWeather(city);
      setState(() {
        hourlyWeather = weatherData;
      });
    } catch (e) {
      print(e);
      _showSnackBar('Saatlik hava durumu alınamadı.');
    }
  }

  // Seçilen şehri kaydetme
  Future<void> _saveSelectedCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
  }

  // Hava durumu verilerini kaydetme
  Future<void> _saveWeatherData(Weather weather) async {
    try {
      String weatherData = '${weather.cityName} - ${weather.temperature.toInt()}°C - ${weather.weatherDescription} - ${weather.icon}';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedLocations = prefs.getStringList('locations') ?? [];

      // Şehrin zaten kaydedilip kaydedilmediğini kontrol et
      if (!savedLocations.contains(weatherData)) {
        // Eğer yoksa yeni konumu ekle
        savedLocations.insert(0, weatherData);
        await prefs.setStringList('locations', savedLocations);
      }
    } catch (e) {
      print('Hava durumu verileri kaydedilirken bir hata oluştu: $e');
    }
  }

  // SnackBar gösterme
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Alt navigasyon tıklama olayı
  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index; // Geçerli indeksi güncelle
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/savedLocations');
        break;
      case 1:
        Navigator.pushNamed(context, '/locationSelection');
        break;
      case 2:
        Navigator.pushNamed(context, '/weeklyWeather');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hava Durumu'),
        backgroundColor: Color(0xFF4D31A9),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          _buildBody(screenHeight),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBody(double screenHeight) {
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.02),
        _buildCityDropdown(),
        SizedBox(height: screenHeight * 0.02),
        if (currentWeather != null) _buildCurrentWeatherCard(),
        SizedBox(height: screenHeight * 0.02),
        if (hourlyWeather.isNotEmpty) _buildHourlyWeatherCard(),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        ),
        hint: Text('Bir şehir seçin'),
        value: selectedCity,
        onChanged: (value) {
          if (value != null) {
            fetchCurrentWeather(value);
          }
        },
        items: cities.map((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Card(
      color: Colors.white70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${currentWeather!.cityName}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildWeatherInfo(),
            SizedBox(height: 10),
            Text(
              '${currentWeather!.weatherDescription}',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 10),
            Text(
              'Max: ${currentWeather!.maxTemperature.toInt()}°C   Min: ${currentWeather!.minTemperature.toInt()}°C',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          'http://openweathermap.org/img/wn/${currentWeather!.icon}@2x.png',
          width: 50,
          height: 50,
        ),
        SizedBox(width: 10),
        Text(
          '${currentWeather!.temperature.toInt()}°C',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHourlyWeatherCard() {
    return Expanded(
      child: ListView.builder(
        itemCount: hourlyWeather.length,
        itemBuilder: (context, index) {
          final weather = hourlyWeather[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: ListTile(
              leading: Image.network(
                'http://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 50,
                height: 50,
              ),
              title: Text('${weather.hour} - ${weather.temperature.toInt()}°C'),
              subtitle: Text('${weather.weatherDescription}'),
            ),
          );
        },
      ),
    );
  }
}
