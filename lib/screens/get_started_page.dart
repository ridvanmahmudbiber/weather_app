import 'package:flutter/material.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan görseli tam ekran olacak şekilde
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'), // Arka plan görseli
                fit: BoxFit.cover, // Ekranı tamamen kaplar
              ),
            ),
          ),

          // Rainy.png ikonu ekranın üstünde olacak şekilde
          Positioned(
            top: 0, // Ekranın en üst kısmına yerleştirilir
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'images/rainy.png', // Başlangıç ikonu görseli
                height: MediaQuery.of(context).size.height * 0.5, // Yüksekliği ekranın yarısı
              ),
            ),
          ),

          // Diğer içerikler biraz daha aşağı kaydırıldı
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55, // Rainy ikonunun altına daha fazla boşluk bırakıldı
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Weather" Başlığı
                Text(
                  'Weather',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // "RIDVAN" Alt Başlığı
                Text(
                  'RIDVAN',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDDB130), // Sarı renk (accent color)
                  ),
                ),
              ],
            ),
          ),

          // "Get Start" Butonu en alta, 120 piksel boşluk bırakılarak yerleştirildi
          Positioned(
            bottom: 120, // Alttan 120 piksel boşluk
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/locationSelection');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDDB130), // Buton rengi sarı (accent color)
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'Get Start',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF362A84), // Buton üzerindeki yazı rengi
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
