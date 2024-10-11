import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_services.dart';
import '../custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyWeatherScreen extends StatefulWidget {
  @override
  _WeeklyWeatherScreenState createState() => _WeeklyWeatherScreenState();
}

class _WeeklyWeatherScreenState extends State<WeeklyWeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  List<Weather> weeklyWeather = [];
  String? selectedCity;

  // Tüm Türkiye şehirleri
  List<String> cities = [
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

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
  }

  // Seçilen şehri SharedPreferences'ten yükleme
  Future<void> _loadSelectedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? city = prefs.getString('selectedCity') ?? 'İstanbul'; // Varsayılan şehir: İstanbul
    setState(() {
      selectedCity = city;
    });
    fetchWeeklyWeather(city);
  }

  // Haftalık hava durumu verisini getirme
  void fetchWeeklyWeather(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      List<Weather> weatherData = await _weatherService.getWeeklyWeather(city);
      setState(() {
        weeklyWeather = weatherData;
      });
    } catch (e) {
      print(e);
      setState(() {
        errorMessage = 'Haftalık hava durumu alınamadı. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Şehir seçildiğinde haftalık hava durumu ve eski konumlar güncelleniyor
  void _onCityChanged(String? city) {
    if (city != null) {
      setState(() {
        selectedCity = city;
      });
      fetchWeeklyWeather(city);
      _saveSelectedCity(city); // Seçilen şehri kaydet
      _saveWeatherData(city); // Hava durumu verilerini kaydet
    }
  }

  // Seçilen şehri kaydetme
  Future<void> _saveSelectedCity(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city);
  }

  // Seçilen şehri ve hava durumunu kaydetme ve eski konumlar listesinde güncelleme
  Future<void> _saveWeatherData(String city) async {
    try {
      Weather weather = await _weatherService.getCurrentWeather(city); // Güncel hava durumunu alın
      String weatherData = '$city - ${weather.temperature.toInt()}°C - ${weather.weatherDescription} - ${weather.icon}';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedLocations = prefs.getStringList('locations') ?? [];

      // Eğer şehir zaten varsa listeden kaldır, en üste ekle
      savedLocations.removeWhere((location) => location.startsWith(city));
      savedLocations.insert(0, weatherData);

      await prefs.setStringList('locations', savedLocations);
    } catch (e) {
      print('Hava durumu verileri kaydedilirken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını almak için MediaQuery kullanıyoruz
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Haftalık Hava Durumu'),
        backgroundColor: Color(0xFF4D31A9),
      ),
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'), // Arka plan görseli
                fit: BoxFit.cover,
              ),
            ),
          ),
          // İçerik kısmı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Şehir seçimi için Dropdown
                DropdownButtonFormField<String>(
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
                  onChanged: _onCityChanged,
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Yükleniyor veya hata mesajı
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (errorMessage != null)
                  Center(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                else
                // Haftalık hava durumu listesi
                  Expanded(
                    child: ListView.builder(
                      itemCount: weeklyWeather.length,
                      itemBuilder: (context, index) {
                        Weather dayWeather = weeklyWeather[index];
                        DateTime date = DateTime.parse(dayWeather.dateTime);
                        String dayOfWeek = _getDayOfWeek(date.weekday);
                        String formattedDate = "${date.day}/${date.month}";

                        return Card(
                          color: Colors.white.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            leading: Image.network(
                              'http://openweathermap.org/img/wn/${dayWeather.icon}@2x.png',
                              height: 50,
                              width: 50,
                            ),
                            title: Text(
                              '$dayOfWeek, $formattedDate',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${dayWeather.weatherDescription}',
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: Text(
                              '${dayWeather.temperature.toInt()}°C', // Tek bir sıcaklık değeri gösteriliyor
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2, // Haftalık hava durumu ekranı üçüncü sekme
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/savedLocations');
              break;
            case 1:
              Navigator.pushNamed(context, '/locationSelection');
              break;
            case 2:
            // Haftalık hava durumu zaten bu ekran, gerek yok
              break;
          }
        },
      ),
    );
  }

  // Günün ismini almak için yardımcı fonksiyon
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar';
      default:
        return '';
    }
  }
}
