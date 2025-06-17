import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/product_page.dart';
import 'pages/user_page.dart';

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _loggedIn = false;
  int _selectedIndex = 0;
  static final List<Widget> _pages = <Widget>[
    const ProductPage(),
    const UserPage(),
  ];
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      setState(() {
        _loggedIn = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _onLoginSuccess(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    setState(() {
      _loggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      home: _loggedIn
          ? Scaffold(
              appBar: AppBar(
                title: const Text('GSB Gestion de Stock'),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              drawer: Drawer(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          DrawerHeader(
                            decoration: const BoxDecoration(color: Colors.lightBlue),
                            padding: EdgeInsets.zero,
                            child: Image.asset(
                              'lib/assets/gsbLogoSansNom.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.lightBlue : null),
                            title: Text('Accueil', style: TextStyle(color: _selectedIndex == 0 ? Colors.lightBlue : null)),
                            selected: _selectedIndex == 0,
                            onTap: () {
                              _onItemTapped(0);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.inventory, color: _selectedIndex == 1 ? Colors.lightBlue : null),
                            title: Text('Produits', style: TextStyle(color: _selectedIndex == 1 ? Colors.lightBlue : null)),
                            selected: _selectedIndex == 1,
                            onTap: () {
                              _onItemTapped(1);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.person, color: _selectedIndex == 2 ? Colors.lightBlue : null),
                            title: Text('Profil', style: TextStyle(color: _selectedIndex == 2 ? Colors.lightBlue : null)),
                            selected: _selectedIndex == 2,
                            onTap: () {
                              _onItemTapped(2);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Déconnexion',
                          style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        await _storage.delete(key: 'auth_token');
                        setState(() {
                          _loggedIn = false;
                          _selectedIndex = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              body: Center(
                child: _selectedIndex == 0
                    ? HomePage(onNavigate: _onItemTapped)
                    : _pages[_selectedIndex - 1],
              ),
            )
          : LoginPage(onLoginSuccess: (token) => _onLoginSuccess(token)),
    );
  }
}
