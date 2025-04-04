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

  '/produits': (context) => const AppLayout(
    child: ProductPage()),

  // '/gestion': (context) => const AppLayout(
  //   child: MedicamentGestionPage()),
  
  // '/profile': (context) => const AppLayout(
  //   child: ProfilePage()),

  '/login': (context) => const LoginPage(),
};