import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  final void Function(String token) onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final response = await http.post(
      Uri.parse('http://192.168.1.39:3000/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mail': _usernameController.text,
        'mdp': _passwordController.text,
      }),
    );
    setState(() { _loading = false; });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'] ?? '';
      if (token.isNotEmpty) {
        widget.onLoginSuccess(token);
      } else {
        setState(() { _error = 'Token manquant dans la réponse.'; });
      }
    } else {
      setState(() { _error = 'Identifiants invalides'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/gsbLogoAvecNom.png',
              height: 80,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Adresse e-mail'),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red), softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
              onPressed: _loading ? null : _login,
              child: _loading ? const CircularProgressIndicator() : const Text('Se connecter', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
