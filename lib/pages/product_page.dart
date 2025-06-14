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
      final response = await http.get(Uri.parse('http://192.168.1.39:3000/products'));
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
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Affiche toujours le menu "plus" en haut à droite
                          return PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => edit_dialog.EditProductDialog(product: product),
                                );
                                if (result == true) _fetchProducts();
                              } else if (value == 'stock') {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => EditStockDialog(product: product),
                                );
                                if (result == true) _fetchProducts();
                              } else if (value == 'delete') {
                                final result = await showDialog(
                                  context: context,
                                  builder: (context) => DeleteProductDialog(product: product),
                                );
                                if (result == true) _fetchProducts();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: const [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Modifier')],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'stock',
                                child: Row(
                                  children: const [Icon(Icons.inventory_2, size: 18), SizedBox(width: 8), Text('Stock')],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
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
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 48.0, bottom: 8.0), // Ajout d'un padding à droite pour éviter le chevauchement avec le bouton
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
                                  Text(product['nom_produit'] ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold), softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (product['description'] != null)
                                    Text(product['description'], softWrap: true, maxLines: 3, overflow: TextOverflow.ellipsis),
                                  Text('Forme : ${product['forme'] ?? 'N/A'}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  Text('Dosage : ${product['dosage'] ?? 'N/A'}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  Text('Prix : ${product['prix'] ?? 'N/A'} €', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  Text('Stock : ${product['stock'] ?? 'N/A'}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (product['restriction'] != null)
                                    Text('Restriction : ${product['restriction']}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  if (product['conservation'] != null)
                                    Text('Conservation : ${product['conservation']}', softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
