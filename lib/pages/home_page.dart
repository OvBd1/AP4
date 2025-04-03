import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 80,
                backgroundImage: AssetImage('lib/assets/logo/logo512x512.png'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bienvenue sur GSB Stock',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F4CD2),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  children: [
                    TextSpan(text: 'GSB Stock vous accompagne '),
                    TextSpan(
                      text: 'dans la gestion de votre stock', 
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Gérez vos stock de médicaments en temps réels pour ne plus jamas manquer de dose !',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Comment ça marche ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F4CD2),
                ),
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: const [
                        Icon(Icons.notifications, color: Color(0xFF4F4CD2)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: const [
                        Icon(Icons.history, color: Color(0xFF4F4CD2)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Suivez l'historique des prises et recevez des alertes en cas d'oubli.",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),            
            ],
          ),
        ),
      ),
    );
  }
}