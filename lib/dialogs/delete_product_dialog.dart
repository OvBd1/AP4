import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeleteProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  const DeleteProductDialog({super.key, required this.product});

  @override
  State<DeleteProductDialog> createState() => _DeleteProductDialogState();
}

class _DeleteProductDialogState extends State<DeleteProductDialog> {
  bool _loading = false;
  String? _error;

  Future<void> _deleteProduct() async {
    setState(() { _loading = true; _error = null; });
    final response = await http.delete(
      Uri.parse('http://192.168.1.39:3000/products/${widget.product['id_produit']}'),
      headers: {'Content-Type': 'application/json'},
    );
    setState(() { _loading = false; });
    if (response.statusCode == 204) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _error = "Erreur lors de la suppression du produit"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer le produit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Voulez-vous vraiment supprimer le produit : \"${widget.product['nom_produit']}\" ?"),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler', style: TextStyle(color: Colors.lightBlue)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _deleteProduct,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Supprimer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
