import 'package:flutter/material.dart';

class ProductDetailDialog extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(product['nom_produit'] ?? 'Produit'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product['image_url'] != null && product['image_url'].toString().isNotEmpty)
              Center(
                child: Image.network(
                  product['image_url'],
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 12),
            Text('Nom du produit : ${product['nom_produit'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Description : ${product['description'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Forme : ${product['forme'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Dosage : ${product['dosage'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Prix (€) : ${product['prix']?.toString() ?? ''}'),
            const SizedBox(height: 8),
            Text('Stock : ${product['stock']?.toString() ?? ''}'),
            if (product['restriction'] != null && product['restriction'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Restriction : ${product['restriction']}'),
            ],
            if (product['conservation'] != null && product['conservation'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Conservation : ${product['conservation']}'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer', style: TextStyle(color: Colors.lightBlue)),
        ),
      ],
    );
  }
}
