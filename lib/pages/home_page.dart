import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final void Function(int)? onNavigate;
  const HomePage({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'lib/assets/gsbLogoAvecNom.png',
              height: 80,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bienvenue sur l\'app de gestion de stock',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue),
              title: const Text('Gérez vos produits', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: const Text('Ajoutez, modifiez, supprimez et gérez le stock de vos produits.', softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (onNavigate != null) {
                  onNavigate!(1);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Gérez vos utilisateurs', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: const Text('Consultez et modifiez votre profil utilisateur.', softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (onNavigate != null) {
                  onNavigate!(2);
                }
              },
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              'GSB - Gestion de Stock\n© 2025',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
