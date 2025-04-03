import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint('Données utilisateur avant enregistrement: $userData');

      final idUser = userData['id_user'];
      debugPrint('id_user: $idUser, type: ${idUser.runtimeType}');
      if (idUser is String) {
        debugPrint('Conversion de id_user en int: $idUser');
        await prefs.setInt(
          'id_user',
          int.tryParse(idUser) ?? 0
        );
      }
      else if (idUser is int) {
        await prefs.setInt(
          'id_user', 
          idUser
        );
      }

      final nom = userData['nom'];
      debugPrint('nom: $nom, type: ${nom.runtimeType}');
      await prefs.setString('nom', nom);

      final prenom = userData['prenom'];
      debugPrint('prenom: $prenom, type: ${prenom.runtimeType}');
      await prefs.setString('prenom', prenom);

      final mail = userData['mail'];
      debugPrint('mail: $mail, type: ${mail.runtimeType}');
      await prefs.setString('mail', mail);

      final num = userData['num_tel'];
      debugPrint('num: $num, type: ${num.runtimeType}');
      await prefs.setString('num_tel', num);

      final dateNaissance = userData['date_naissance'];
      debugPrint('dateNaissance: $dateNaissance, type: ${dateNaissance.runtimeType}');
      await prefs.setString('date_naissance', dateNaissance);

      final mdp = userData['mdp'];
      debugPrint('mdp: $mdp, type: ${mdp.runtimeType}');
      await prefs.setString('mdp', mdp);

      final admin = userData['admin'];
      debugPrint('admin: $admin, type: ${admin.runtimeType}');
      await prefs.setInt(
        'admin', 
        admin is int ? admin : 0
      );

      String userDataJson = json.encode(userData);
      debugPrint('User data JSON: $userDataJson');
      await prefs.setString('user_data', userDataJson);

      debugPrint("Données de l'utilisateur enregistrées avec succès.");
    } catch(e) {
      debugPrint("Erreur lors de l'accès à SharedPreferences: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('lib/assets/boy.png'),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text("Pas encore de compte ? S'en créer un"),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final String email = _emailController.text;
                          final String password = _passwordController.text;
                          debugPrint('Adresse mail: $email, Mot de passe: $password');

                          final Map<String, String> body = {
                            "email": email,
                            "password": password,
                          };

                          try {
                            final response = await http.post(
                              Uri.parse('http://localhost:3000/auth/'),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode(body),
                            );

                            if (response.statusCode == 200) {
                              debugPrint('Connexion réussi: ${response.body}');
                              setState(() {
                                _errorMessage = null;
                              });

                              final dataUser = await http.post(
                                Uri.parse('http://localhost:3000/user/'),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode({
                                  "mail": email,
                                  "mdp": password
                                }),
                              );

                              var sentData = dataUser.body;
                              debugPrint('$sentData datause');
                              await _saveUserData(json.decode(dataUser.body));

                              Navigator.pushReplacementNamed(context, '/gestion');
                            } else {
                              setState(() {
                                _passwordController.clear();
                                _errorMessage = "Le mot de passe ou l'adresse mail est erroné.";
                              });

                              debugPrint('Erreur de connexion: ${response.body}');
                            }
                          } catch (e) {
                            setState(() {
                              _errorMessage = 'Erreur réseau, veuillez réessayer';
                            });
                            debugPrint('Erreur réseau: $e');
                          }
                        }
                      },
                      child: const Text('Se connecter'),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      )
    );
  }
}