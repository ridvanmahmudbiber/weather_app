import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF4D31A9),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on_outlined),
          label: 'Eski Konumlar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.my_location_outlined),
          label: 'Anlık Hava Durumu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Haftalık Hava Durumu',
        ),
      ],
      onTap: onTap,
    );
  }
}
