import 'package:flutter/material.dart';

import 'beranda_society.dart';
import 'history_society.dart';
import 'profil_society.dart';

class MainSociety extends StatefulWidget {
  const MainSociety({super.key});

  @override
  State<MainSociety> createState() => _MainSocietyState();
}

class _MainSocietyState extends State<MainSociety> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    BerandaSociety(),
    HistoriSocietyPage(),
    ProfilSociety(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}