import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Modifier l'URL de base pour correspondre à votre serveur
  final String apiBaseUrl = "http://localhost:3000";
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/products'),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        
        // Check if the response is a map or a list
        if (decodedData is Map) {
          // If it's a map, check if it has a data field that contains the products
          if (decodedData.containsKey('data') && decodedData['data'] is List) {
            setState(() {
              _products = List<Map<String, dynamic>>.from(decodedData['data']);
              _isLoading = false;
            });
          } else {
            // If there's no data field, try to convert the whole map to a single product
            setState(() {
              _products = [Map<String, dynamic>.from(decodedData)];
              _isLoading = false;
            });
          }
        } else if (decodedData is List) {
          // If it's already a list, use it directly
          setState(() {
            _products = List<Map<String, dynamic>>.from(decodedData);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Format de réponse inattendu';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des produits: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  // First, let's fix the update stock function
  Future<void> _updateStock(int productId, int newStock) async {
    try {
      // Utilisons POST au lieu de PUT pour être cohérent avec la méthode _updateProduct
      final response = await http.post(
        Uri.parse('$apiBaseUrl/products/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_produit': productId,
          'stock': newStock
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock mis à jour avec succès')),
        );
        _loadProducts(); // Reload products to get updated data
      } else {
        print('Erreur de mise à jour du stock: ${response.statusCode}');
        print('Réponse: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  // Now let's create a comprehensive update product function
  // Mise à jour complète d'un produit
  Future<void> _updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      // Solution temporaire avec POST au lieu de PUT
      final Map<String, dynamic> dataToSend = {
        ...productData,
        'id_produit': productId, // Conserver l'ID dans le corps
      };
      
      print('Mise à jour du produit $productId avec les données: ${jsonEncode(dataToSend)}');
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/products/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSend),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit mis à jour avec succès')),
        );
        _loadProducts(); // Recharger les produits pour obtenir les données mises à jour
      } else {
        // Affichons plus d'informations sur l'erreur
        print('Erreur de mise à jour: ${response.statusCode}');
        print('Réponse: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  // Supprimez la deuxième définition de _updateStock qui se trouve ici
  // et gardez uniquement celle ci-dessus

  // Modifions également la fonction de suppression pour utiliser la même convention
  Future<void> _deleteProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/products/$productId'), // Revenons à la route plurielle
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit supprimé avec succès')),
        );
        _loadProducts(); // Reload products to get updated data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  // Replace the stock update dialog with a comprehensive edit dialog
  void _showStockUpdateDialog(Map<String, dynamic> product) {
    final TextEditingController nameController = TextEditingController(
      text: product['nom_produit']?.toString() ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: product['description']?.toString() ?? '',
    );
    final TextEditingController formeController = TextEditingController(
      text: product['forme']?.toString() ?? '',
    );
    final TextEditingController dosageController = TextEditingController(
      text: product['dosage']?.toString() ?? '',
    );
    final TextEditingController prixController = TextEditingController(
      text: product['prix']?.toString() ?? '0',
    );
    final TextEditingController stockController = TextEditingController(
      text: product['stock']?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${product['nom_produit']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: formeController,
                decoration: const InputDecoration(
                  labelText: 'Forme',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prixController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix (€)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Show confirmation dialog for delete
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmer la suppression'),
                  content: const Text('Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close confirmation dialog
                        Navigator.pop(context); // Close edit dialog
                        _deleteProduct(product['id_produit']);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate and update product
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le nom du produit est requis')),
                );
                return;
              }

              final prix = double.tryParse(prixController.text);
              if (prix == null || prix < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un prix valide')),
                );
                return;
              }

              final stock = int.tryParse(stockController.text);
              if (stock == null || stock < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un stock valide')),
                );
                return;
              }

              Navigator.pop(context);
              _updateProduct(product['id_produit'], {
                'nom_produit': nameController.text,
                'description': descriptionController.text,
                'forme': formeController.text,
                'dosage': dosageController.text,
                'prix': prix,
                'stock': stock,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F4CD2),
              foregroundColor: Colors.white, // Add this to make text white
            ),
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  // Now let's fix the button color in the product card
  // In the product card, change the ElevatedButton.icon style:
  // Remove this duplicate method - it's causing the error
  void _showSimpleStockUpdateDialog(Map<String, dynamic> product) {
    final TextEditingController stockController = TextEditingController(
      text: product['stock'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier le stock de ${product['nom_produit']}'),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Nouveau stock',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                Navigator.pop(context);
                _updateStock(product['id_produit'], newStock);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un nombre valide')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F4CD2),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  String _getStockStatus(int stock) {
    if (stock <= 5) return 'Critique';
    if (stock <= 20) return 'Faible';
    return 'Normal';
  }

  Color _getStockColor(int stock) {
    if (stock <= 5) return Colors.red;
    if (stock <= 20) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des produits', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4F4CD2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty && _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F4CD2),
                        ),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun produit trouvé',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Liste des produits',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F4CD2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                final stock = product['stock'] as int;
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Product image or placeholder
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: product['image_url'] != null && product['image_url'].toString().isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    product['image_url'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const Icon(Icons.medication, size: 30, color: Colors.grey);
                                                    },
                                                  ),
                                                )
                                              : const Icon(Icons.medication, size: 30, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 12),
                                        // Product details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['nom_produit'] ?? 'Sans nom',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                product['description'] ?? 'Aucune description',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Forme: ${product['forme'] ?? 'N/A'}',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'Dosage: ${product['dosage'] ?? 'N/A'}',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                'Prix: ${product['prix'] ?? 0} €',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Stock information and update button
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: _getStockColor(stock).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: _getStockColor(stock), width: 0.5),
                                              ),
                                              child: Text(
                                                'Stock: $stock (${_getStockStatus(stock)})',
                                                style: TextStyle(
                                                  color: _getStockColor(stock),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () => _showStockUpdateDialog(product),
                                              icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                              label: const Text('Modifier', 
                                                style: TextStyle(fontSize: 12, color: Colors.white)
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF4F4CD2),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                minimumSize: const Size(80, 30),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Set to 1 since we're on the Products page
        selectedItemColor: const Color(0xFF4F4CD2),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          // Handle navigation based on index
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Already on products page
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/commandes');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
      // Remove the duplicate floatingActionButton and keep only this one
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add product page
          _showAddProductDialog();
        },
        backgroundColor: const Color(0xFF4F4CD2),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController formeController = TextEditingController();
    final TextEditingController dosageController = TextEditingController();
    final TextEditingController prixController = TextEditingController();
    final TextEditingController stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un nouveau produit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: formeController,
                decoration: const InputDecoration(
                  labelText: 'Forme',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prixController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix (€)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock initial',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate and add product
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le nom du produit est requis')),
                );
                return;
              }

              final prix = double.tryParse(prixController.text);
              if (prix == null || prix < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un prix valide')),
                );
                return;
              }

              final stock = int.tryParse(stockController.text);
              if (stock == null || stock < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un stock valide')),
                );
                return;
              }

              _addProduct({
                'nom_produit': nameController.text,
                'description': descriptionController.text,
                'forme': formeController.text,
                'dosage': dosageController.text,
                'prix': prix,
                'stock': stock,
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F4CD2),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct(Map<String, dynamic> productData) async {
    try {
      // Modifier cette URL pour utiliser /products au lieu de /api/produits
      final response = await http.post(
        Uri.parse('$apiBaseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit ajouté avec succès')),
        );
        _loadProducts(); // Reload products to get updated data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }
}