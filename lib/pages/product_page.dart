import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../dialogs/add_product_dialog.dart';
import '../dialogs/edit_product_dialog.dart' as edit_dialog;
import '../dialogs/edit_stock_dialog.dart';
import '../dialogs/product_detail_dialog.dart';
import '../dialogs/delete_product_dialog.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<dynamic> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/products'));
      if (response.statusCode == 200) {
        setState(() {
          _products = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement des produits';
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return Stack(
      children: [
        ListView.builder(
          itemCount: _products.length,
          itemBuilder: (context, index) {
            final product = _products[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  product['image_url'] != null
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(product['image_url']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.medical_services, size: 40),
                        ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ProductDetailDialog(product: product),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['nom_produit'] ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (product['description'] != null)
                              Text(product['description']),
                            Text('Forme : ${product['forme'] ?? 'N/A'}'),
                            Text('Dosage : ${product['dosage'] ?? 'N/A'}'),
                            Text('Prix : ${product['prix'] ?? 'N/A'} €'),
                            Text('Stock : ${product['stock'] ?? 'N/A'}'),
                            if (product['restriction'] != null)
                              Text('Restriction : ${product['restriction']}'),
                            if (product['conservation'] != null)
                              Text('Conservation : ${product['conservation']}'),
                            Row(
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Modifier'),
                                  onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (context) => edit_dialog.EditProductDialog(product: product),
                                    );
                                    if (result == true) {
                                      _fetchProducts();
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.inventory_2, size: 18),
                                  label: const Text('Stock'),
                                  onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (context) => EditStockDialog(product: product),
                                    );
                                    if (result == true) {
                                      _fetchProducts();
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  onPressed: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (context) => DeleteProductDialog(product: product),
                                    );
                                    if (result == true) {
                                      _fetchProducts();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const AddProductDialog(),
              );
              if (result == true) {
                _fetchProducts();
              }
            },
            tooltip: 'Ajouter un produit',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
