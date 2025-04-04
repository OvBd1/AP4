import 'package:flutter/material.dart';
import 'package:ap4/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'route.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const authRedirector(),
      routes: appRoutes,
    );
  }
}

class authRedirector extends StatefulWidget {
  const authRedirector({super.key});

  @override
  _authRedirectorState createState() => _authRedirectorState();
}

class _authRedirectorState extends State<authRedirector> {
  Future<String> _getInitialPageRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final lname = prefs.getString('nom') ?? '';
    final fname = prefs.getString('prenom') ?? '';
    final email = prefs.getString('adresse_mail') ?? '';

    if (lname.isNotEmpty && fname.isNotEmpty && email.isNotEmpty) {
      return '/home';
    } else {
      return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialPageRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            )
          );
        }

        Future.microtask(() {
          Navigator.of(context).pushReplacementNamed(snapshot.data!);
        });

        return const SizedBox.shrink();
      },
    );
  }
}