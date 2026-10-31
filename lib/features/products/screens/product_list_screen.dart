import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Map<String, dynamic>> products = [];

  void showProductDialog({int? index}) {
    final product = index == null ? null : products[index];

    final nameController =
        TextEditingController(text: product?['name'] ?? '');
    final typeController =
        TextEditingController(text: product?['type'] ?? '');
    final salesController =
        TextEditingController(text: product?['sales']?.toString() ?? '');
    final costController =
        TextEditingController(text: product?['cost']?.toString() ?? '');
    final variantController =
        TextEditingController(text: product?['variant'] ?? '');
    final notesController =
        TextEditingController(text: product?['notes'] ?? '');

    String brand = product?['brand'] ?? 'Other';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(index == null ? 'Add Product' : 'Edit Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(
                        labelText: 'Product Type',
                      ),
                    ),
                    TextField(
                      controller: salesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sales Price (₹)',
                      ),
                    ),
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price (₹)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: brand,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                        DropdownMenuItem(
                          value: 'Odoo',
                          child: Text('Odoo'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => brand = value);
                        }
                      },
                    ),
                    TextField(
                      controller: variantController,
                      decoration: const InputDecoration(
                        labelText: 'Product Variant',
                        hintText: 'Example: Small, Medium, Large',
                      ),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final sales = double.tryParse(salesController.text);
                    final cost = double.tryParse(costController.text);

                    if (nameController.text.trim().isEmpty ||
                        sales == null ||
                        cost == null ||
                        sales < 0 ||
                        cost < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a product name and valid prices.',
                          ),
                        ),
                      );
                      return;
                    }

                    final newProduct = {
                      'name': nameController.text.trim(),
                      'type': typeController.text.trim(),
                      'sales': sales,
                      'cost': cost,
                      'brand': brand,
                      'variant': variantController.text.trim(),
                      'notes': notesController.text.trim(),
                    };

                    setState(() {
                      if (index == null) {
                        products.add(newProduct);
                      } else {
                        products[index] = newProduct;
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text(
          'Are you sure you want to delete this product?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => products.removeAt(index));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BrightLoop - Products'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: products.isEmpty
          ? const Center(
              child: Text(
                'No products added yet.\nTap Add Product to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final basePrice = product['sales'] as double;
                final finalPrice =
                    basePrice + (product['brand'] == 'Odoo' ? 560 : 0);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.shopping_bag),
                    ),
                    title: Text(
                      product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Type: ${product['type']}\n'
                      'Brand: ${product['brand']}\n'
                      'Variant: ${product['variant']}\n'
                      'Sales Price: ₹${finalPrice.toStringAsFixed(2)}\n'
                      'Cost Price: ₹${product['cost']}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showProductDialog(index: index);
                        } else if (value == 'delete') {
                          deleteProduct(index);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}