import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;
  bool _editMode = false;
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _mailController = TextEditingController();
  final _numTelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Non connecté.';
          _loading = false;
        });
        return;
      }
      final response = await http.get(
        Uri.parse('http://localhost:3000/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _profile = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement du profil';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion à l\'API';
        _loading = false;
      });
    }
  }

  void _startEdit(Map<String, dynamic> profile) {
    setState(() {
      _editMode = true;
      _prenomController.text = profile['prenom'] ?? '';
      _nomController.text = profile['nom'] ?? '';
      _mailController.text = profile['mail'] ?? '';
      _numTelController.text = profile['num_tel'] ?? '';
    });
  }

  Future<void> _saveEdit() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null || token.isEmpty) return;
    final updated = {
      'nom': _nomController.text,
      'prenom': _prenomController.text,
      'mail': _mailController.text,
      'num_tel': _numTelController.text,
    };
    final response = await http.put(
      Uri.parse('http://localhost:3000/users/${_profile?['id_user']}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updated),
    );
    if (response.statusCode == 200) {
      setState(() {
        _editMode = false;
        _fetchProfile();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      }
    } else {
      setState(() {
        _error = "Erreur lors de la mise à jour du profil";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    final profile = _profile;
    if (profile == null) {
      return const Center(child: Text('Aucune information de profil.'));
    }
    return Center(
      child: _editMode
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextField(
                      controller: _mailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: TextField(
                      controller: _numTelController,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                          onPressed: _saveEdit,
                          child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.lightBlue, side: const BorderSide(color: Colors.lightBlue)),
                          onPressed: () {
                            setState(() { _editMode = false; });
                          },
                          child: const Text('Annuler'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.lightBlue,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text('${profile['prenom'] ?? ''} ${profile['nom'] ?? ''}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(profile['mail'] ?? '', style: const TextStyle(fontSize: 16), softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (profile['num_tel'] != null)
                  Text('Téléphone : ${profile['num_tel']}', style: const TextStyle(fontSize: 16), softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (profile['date_naissance'] != null)
                  Text('Date de naissance : '
                    '${(() {
                      final date = DateTime.tryParse(profile['date_naissance'].toString());
                      if (date != null) {
                        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                      } else {
                        return '';
                      }
                    })()}',
                    style: const TextStyle(fontSize: 16),
                    softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    (profile['admin'] == 1) ? 'Rôle : Administrateur' : 'Rôle : Utilisateur',
                    style: const TextStyle(fontSize: 16),
                    softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  onPressed: () => _startEdit(profile),
                  child: const Text('Modifier le profil', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
    );
  }
}
