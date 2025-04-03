import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AP4"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/fondBurger.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/menu');
              }
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Liste des médicaments'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/produits');
              }
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Gestion des médicaments'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/gestion');
              }
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/profile');
              }
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Se déconnecter'),
              onTap : () async {
                Navigator.of(context).pop();
                SharedPreferences preferences = await SharedPreferences.getInstance();
                await preferences.clear();
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ]
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16.0), 
              child: child,
            ),
          )
        ],
      ),
    );
  }
}