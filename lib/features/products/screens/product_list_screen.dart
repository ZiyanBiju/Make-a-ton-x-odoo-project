import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  static const Color navy = Color(0xFF151A35);
  static const Color purple = Color(0xFF7657F6);
  static const Color background = Color(0xFFF6F5FB);

  final List<Map<String, dynamic>> products = [];
  final searchController = TextEditingController();

  String searchQuery = '';

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      return product['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                index == null ? 'Add New Product' : 'Edit Product',
                style: const TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _field(nameController, 'Product Name',
                          Icons.shopping_bag_outlined),
                      _field(typeController, 'Product Type',
                          Icons.category_outlined),
                      _field(salesController, 'Sales Price (₹)',
                          Icons.currency_rupee,
                          number: true),
                      _field(costController, 'Cost Price (₹)',
                          Icons.account_balance_wallet_outlined,
                          number: true),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: brand,
                        decoration: _decoration(
                          'Brand',
                          Icons.branding_watermark_outlined,
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
                      const SizedBox(height: 16),
                      _field(variantController, 'Product Variant',
                          Icons.style_outlined),
                      _field(notesController, 'Notes',
                          Icons.notes_outlined,
                          maxLines: 2),
                      if (brand == 'Odoo')
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0ECFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: purple),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Odoo brand adds ₹560 to the sales price.',
                                  style: TextStyle(
                                    color: navy,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final sales = double.tryParse(salesController.text);
                    final cost = double.tryParse(costController.text);

                    if (nameController.text.trim().isEmpty ||
                        sales == null ||
                        cost == null ||
                        sales < 0 ||
                        cost < 0) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
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
                  child: Text(index == null ? 'Add Product' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      typeController.dispose();
      salesController.dispose();
      costController.dispose();
      variantController.dispose();
      notesController.dispose();
    });
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: purple),
      filled: true,
      fillColor: const Color(0xFFF8F7FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool number = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        maxLines: maxLines,
        decoration: _decoration(label, icon),
      ),
    );
  }

  void deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedProducts = filteredProducts;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Product Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProductDialog(),
        backgroundColor: purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Your Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Add, update and organize your product catalogue.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: purple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Products',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                Text(
                  '${products.length} Products',
                  style: const TextStyle(
                    color: purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: displayedProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 65,
                          color: Color(0xFFB9B2D0),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          searchQuery.isEmpty
                              ? 'No products added yet'
                              : 'No matching products found',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Tap Add Product to get started.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 90),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, index) {
                      final product = displayedProducts[index];
                      final actualIndex = products.indexOf(product);

                      final basePrice = product['sales'] as double;
                      final finalPrice = basePrice +
                          (product['brand'] == 'Odoo' ? 560 : 0);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: const Color(0xFFECEAF4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.035),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0ECFF),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: purple,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: const TextStyle(
                                          color: navy,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        product['type'].toString().isEmpty
                                            ? 'General Product'
                                            : product['type'],
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      showProductDialog(index: actualIndex);
                                    } else {
                                      deleteProduct(actualIndex);
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
                              ],
                            ),
                            const Divider(height: 25),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _badge('Brand: ${product['brand']}'),
                                if (product['variant'].toString().isNotEmpty)
                                  _badge('Variant: ${product['variant']}'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _priceInfo(
                                  'Cost Price',
                                  '₹${(product['cost'] as double).toStringAsFixed(2)}',
                                ),
                                _priceInfo(
                                  'Sales Price',
                                  '₹${finalPrice.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                            if (product['brand'] == 'Odoo')
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'Includes ₹560 Odoo brand addition',
                                  style: TextStyle(
                                    color: purple,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            if (product['notes'].toString().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                product['notes'],
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: purple,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _priceInfo(String label, String price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: const TextStyle(
            color: navy,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}