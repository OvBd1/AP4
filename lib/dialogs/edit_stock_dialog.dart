import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditStockDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditStockDialog({super.key, required this.product});

  @override
  State<EditStockDialog> createState() => _EditStockDialogState();
}

class _EditStockDialogState extends State<EditStockDialog> {
  late TextEditingController _stockController;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.product['stock']?.toString() ?? '');
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final updated = {
      'stock': int.tryParse(_stockController.text) ?? 0,
    };
    final response = await http.put(
      Uri.parse('http://localhost:3000/products/stock/${widget.product['id_produit']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated),
    );
    setState(() { _loading = false; });
    if (response.statusCode == 200) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _error = 'Erreur lors de la modification du stock'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le stock'),
      content: TextField(
        controller: _stockController,
        decoration: const InputDecoration(labelText: 'Stock'),
        keyboardType: TextInputType.number,
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
