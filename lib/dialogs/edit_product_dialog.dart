import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _formeController;
  late TextEditingController _dosageController;
  late TextEditingController _prixController;
  late TextEditingController _imageUrlController;
  late TextEditingController _stockController;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nomController = TextEditingController(text: p['nom_produit'] ?? '');
    _descriptionController = TextEditingController(text: p['description'] ?? '');
    _formeController = TextEditingController(text: p['forme'] ?? '');
    _dosageController = TextEditingController(text: p['dosage'] ?? '');
    _prixController = TextEditingController(text: p['prix']?.toString() ?? '');
    _imageUrlController = TextEditingController(text: p['image_url'] ?? '');
    _stockController = TextEditingController(text: p['stock']?.toString() ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final updated = {
      'nom_produit': _nomController.text,
      'description': _descriptionController.text,
      'forme': _formeController.text,
      'dosage': _dosageController.text,
      'prix': _prixController.text,
      'image_url': _imageUrlController.text,
      'stock': int.tryParse(_stockController.text) ?? 0,
    };
    final response = await http.put(
      Uri.parse('http://localhost:3000/products/${widget.product['id_produit']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated),
    );
    setState(() { _loading = false; });
    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _error = 'Erreur lors de la modification du produit'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le produit'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom du produit*'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description*'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _formeController,
                decoration: const InputDecoration(labelText: 'Forme*'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(labelText: 'Dosage*'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(labelText: 'Prix*'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "URL de l'image"),
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock*'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler', style: TextStyle(color: Colors.lightBlue)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Enregistrer', style: TextStyle(color: Colors.lightBlue)),
        ),
      ],
    );
  }
}

