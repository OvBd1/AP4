import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formeController = TextEditingController();
  final _dosageController = TextEditingController();
  final _prixController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _restrictionController = TextEditingController();
  final _conservationController = TextEditingController();
  final _stockController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final data = {
      'nom_produit': _nomController.text,
      'description': _descriptionController.text,
      'forme': _formeController.text,
      'dosage': _dosageController.text,
      'prix': _prixController.text,
      'image_url': _imageUrlController.text,
      'restriction': _restrictionController.text,
      'conservation': _conservationController.text,
      'stock': int.tryParse(_stockController.text) ?? 0,
    };
    final response = await http.post(
      Uri.parse('http://localhost:3000/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    setState(() { _loading = false; });
    if (response.statusCode == 201 || response.statusCode == 200) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _error = "Erreur lors de l'ajout du produit"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un produit'),
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
                controller: _restrictionController,
                decoration: const InputDecoration(labelText: 'Restriction'),
              ),
              TextFormField(
                controller: _conservationController,
                decoration: const InputDecoration(labelText: 'Conservation'),
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