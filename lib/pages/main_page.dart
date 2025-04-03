import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "GSB Stock est une application conçue pour vous aider à gérer vos stock de médicaments avec une interface simple et intuitive afin de simplifier votre gestion",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Divider(height: 30, thickness: 1),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF4F4CD2)),
                SizedBox(width: 10),
                Text(
                  "Service opérationnel",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Icon(Icons.update, color: Color(0xFF4F4CD2)),
                SizedBox(width: 10),
                Text(
                  "Dernière mise à jour : 21 Mars 2025",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            const SizedBox(height: 10),
            const Text(
              "Version : 1.0.0",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}