import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_bottom_navigation_bar.dart';

class SavedLocationsScreen extends StatefulWidget {
  @override
  _SavedLocationsScreenState createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  List<String> savedLocations = [];
  int _currentIndex = 0; // Alt gezinme çubuğu için güncel indeks

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  // Kaydedilen konumları yükleme
  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLocations = prefs.getStringList('locations') ?? [];
    });
  }

  // Konumları silme
  Future<void> _clearLocations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('locations');
    setState(() {
      savedLocations.clear();
    });
  }

  // Yeni bir konumu kaydederken aynı şehrin tekrar eklenmesini engelleme
  Future<void> _saveLocation(String city, String temperature, String weather, String weatherIcon) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentLocations = prefs.getStringList('locations') ?? [];

    String newLocation = '$city - $temperature - $weather - $weatherIcon';

    if (!currentLocations.contains(newLocation)) {
      currentLocations.insert(0, newLocation); // Aynı şehir eklenmez, son eklenen başta olur.
      await prefs.setStringList('locations', currentLocations);
      setState(() {
        savedLocations = currentLocations;
      });
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Kaydedilmiş Konumlar'),
        backgroundColor: Color(0xFF4D31A9),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _showClearConfirmationDialog(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Arka plan
          _buildBackground(),
          // İçerik
          _buildContent(),
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.jpg'), // Arka plan görseli
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20), // Üst boşluk
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Son Görüntülenen Konumlar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20), // Başlık ve kartlar arasında boşluk
        Expanded(
          child: savedLocations.isEmpty
              ? _buildNoLocationsMessage()
              : _buildLocationList(),
        ),
      ],
    );
  }

  Widget _buildNoLocationsMessage() {
    return Center(
      child: Text(
        'Henüz kaydedilmiş konumunuz yok.',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildLocationList() {
    return ListView.builder(
      itemCount: savedLocations.length,
      itemBuilder: (context, index) {
        return _buildLocationCard(savedLocations[index]);
      },
    );
  }

  Widget _buildLocationCard(String locationData) {
    List<String> parts = locationData.split(' - ');
    String location = parts[0];
    String temperature = parts[1];
    String weather = parts[2];
    String weatherIcon = parts.length > 3 ? parts[3] : ''; // Hava durumu simgesi

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: Colors.white.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: weatherIcon.isNotEmpty
              ? Image.network(
            'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
            height: 50,
            width: 50,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, color: Colors.red); // Hata durumunda bir ikon göster
            },
          )
              : Icon(Icons.location_on_outlined, color: Colors.blue),
          title: Text(
            location,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Sıcaklık: ${_formatTemperature(temperature)}°C'),
          trailing: _buildWeatherInfo(weatherIcon, weather),
          onTap: () {
            // Seçilen konuma gitmek için isteğe bağlı
          },
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String weatherIcon, String weather) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (weatherIcon.isNotEmpty)
          Image.network(
            'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
            height: 30,
            width: 30,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, color: Colors.red); // Hata durumunda bir ikon göster
            },
          ),
        const SizedBox(width: 8),
        Text(
          weather.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tüm Konumları Sil'),
        content: Text('Tüm kaydedilmiş konumları silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              _clearLocations();
              Navigator.pop(context);
            },
            child: Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _formatTemperature(String temperature) {
    // Sıcaklığı tam sayı olarak döndürme
    double tempValue = double.tryParse(temperature) ?? 0.0;
    return tempValue.toInt().toString(); // Tam sayıya çevir ve string olarak döndür
  }
}
