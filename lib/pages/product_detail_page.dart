import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['nom_produit'] ?? 'Produit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product['image_url'] != null && product['image_url'].toString().isNotEmpty)
                Center(
                  child: Image.network(
                    product['image_url'],
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 16),
              Text('Nom du produit : ${product['nom_produit'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold), softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('Description : ${product['description'] ?? ''}', softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('Forme : ${product['forme'] ?? ''}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('Dosage : ${product['dosage'] ?? ''}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('Prix (€) : ${product['prix']?.toString() ?? ''}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('Stock : ${product['stock']?.toString() ?? ''}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (product['restriction'] != null && product['restriction'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Restriction : ${product['restriction']}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              if (product['conservation'] != null && product['conservation'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Conservation : ${product['conservation']}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
