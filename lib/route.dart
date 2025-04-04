import 'package:flutter/material.dart';
import 'package:ap4/pages/home_page.dart';
import 'package:ap4/pages/main_page.dart';
import 'package:ap4/pages/login_page.dart';
import 'package:ap4/pages/product_page.dart';
import 'app_layout.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomePage(),

  '/menu': (context) => const AppLayout(
    child: MenuPage()),

  '/produits': (context) => const ProductPage(),

  '/commandes': (context) => Scaffold(
    appBar: AppBar(
      title: const Text('Commandes', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF4F4CD2),
    ),
    body: const Center(
      child: Text('Page des commandes en construction', style: TextStyle(fontSize: 18)),
    ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
      selectedItemColor: const Color(0xFF4F4CD2),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Produits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Commandes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/produits');
            break;
          case 2:
            // Déjà sur la page commandes
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
    ),
  ),
  
  '/profile': (context) => Scaffold(
    appBar: AppBar(
      title: const Text('Profil', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF4F4CD2),
    ),
    body: const Center(
      child: Text('Page de profil en construction', style: TextStyle(fontSize: 18)),
    ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3,
      selectedItemColor: const Color(0xFF4F4CD2),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Produits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Commandes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/produits');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/commandes');
            break;
          case 3:
            // Déjà sur la page profil
            break;
        }
      },
    ),
  ),

  '/login': (context) => const LoginPage(),
};