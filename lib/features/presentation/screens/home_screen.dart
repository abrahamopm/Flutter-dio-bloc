import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dio_bloc/features/presentation/providers/product_provider.dart';
import 'package:flutter_dio_bloc/features/data/models/product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'STOREBOARD',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFBB86FC).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBB86FC).withValues(alpha: 0.3)),
              ),
              child: const Text(
                'BLOC ENGINE',
                style: TextStyle(
                  color: Color(0xFFBB86FC),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ProductProvider>().loadProducts(),
            tooltip: 'Refresh Products',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFBB86FC),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () async {
          final product = await _showProductFormDialog(context);
          if (product != null && context.mounted) {
            final provider = context.read<ProductProvider>();
            await provider.createProduct(product);
            if (context.mounted) {
              _showFeedback(context, 'Product created successfully!');
            }
          }
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: BlocBuilder<ProductProvider, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductInitial() || ProductLoading() =>
              const Center(child: _SkeletonProductLoader()),
            ProductError(:final message) => Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141221),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'An error occurred',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ProductProvider>().loadProducts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ProductLoaded(:final products) => RefreshIndicator(
                color: const Color(0xFFBB86FC),
                onRefresh: () => context.read<ProductProvider>().loadProducts(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductTile(product: product);
                  },
                ),
              ),
          };
        },
      ),
    );
  }
}

void _showFeedback(BuildContext context, String message, {bool isError = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: isError ? Colors.redAccent : const Color(0xFF03DAC6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF141221),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isError ? Colors.redAccent.withValues(alpha: 0.3) : const Color(0xFFBB86FC).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}

Future<Product?> _showProductFormDialog(BuildContext context, {Product? existing}) {
  final titleController = TextEditingController(text: existing?.title ?? '');
  final priceController = TextEditingController(text: existing != null ? existing.price.toString() : '');
  final descriptionController = TextEditingController(text: existing?.description ?? '');
  final categoryController = TextEditingController(text: existing?.category ?? '');
  final imageController = TextEditingController(text: existing?.image ?? '');

  final formKey = GlobalKey<FormState>();

  return showDialog<Product?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          existing == null ? 'Create Product' : 'Update Product',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title', hintText: 'Enter title'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Title required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price', hintText: 'Enter price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Price required';
                    final parsed = double.tryParse(value);
                    if (parsed == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'Enter description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    if (value.trim().length < 3) return 'Description too short';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category', hintText: 'Enter category'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Category required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL', hintText: 'Enter image URL'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !(uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https'))) {
                      return 'Enter a valid http(s) URL';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBB86FC),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final title = titleController.text.trim();
                final price = double.parse(priceController.text.trim());
                final description = descriptionController.text.trim();
                final category = categoryController.text.trim();
                final image = imageController.text.trim();

                final result = Product(
                  id: existing?.id,
                  title: title,
                  price: price,
                  description: description,
                  category: category,
                  image: image.isNotEmpty ? image : (existing?.image ?? ''),
                );

                Navigator.of(context).pop(result);
              }
            },
            child: Text(existing == null ? 'Create' : 'Update', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

Future<String?> _showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? initialValue,
}) {
  final controller = TextEditingController(text: initialValue ?? '');
  final formKey = GlobalKey<FormState>();

  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label, hintText: 'Enter new value'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Value required';
              if (value.trim().length > 250) return 'Too long';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBB86FC),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.image_not_supported_rounded,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBB86FC).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBB86FC).withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.0,
                        color: Color(0xFFBB86FC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF03DAC6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Color(0xFFBB86FC), size: 20),
                  tooltip: 'Update (PUT)',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFBB86FC).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final updated = await _showProductFormDialog(context, existing: product);
                    if (updated != null && context.mounted) {
                      final provider = context.read<ProductProvider>();
                      await provider.updateProduct(updated);
                      if (context.mounted) {
                        _showFeedback(context, 'Product updated successfully!');
                      }
                    }
                  },
                ),
                const SizedBox(height: 6),
                IconButton(
                  icon: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF03DAC6), size: 20),
                  tooltip: 'Patch Title',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF03DAC6).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final newTitle = await _showTextInputDialog(
                      context,
                      title: 'Patch Title',
                      label: 'Title',
                      initialValue: product.title,
                    );
                    if (newTitle != null && newTitle.trim().isNotEmpty && context.mounted) {
                      final provider = context.read<ProductProvider>();
                      await provider.patchProduct(
                        product.id!,
                        {'title': newTitle.trim()},
                      );
                      if (context.mounted) {
                        _showFeedback(context, 'Product title patched successfully!');
                      }
                    }
                  },
                ),
                const SizedBox(height: 6),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  tooltip: 'Delete',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Product'),
                        content: Text('Delete "${product.title}"? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final provider = context.read<ProductProvider>();
                      await provider.deleteProduct(product.id!);
                      if (context.mounted) {
                        _showFeedback(context, 'Product deleted');
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonProductLoader extends StatefulWidget {
  const _SkeletonProductLoader();

  @override
  State<_SkeletonProductLoader> createState() => _SkeletonProductLoaderState();
}

class _SkeletonProductLoaderState extends State<_SkeletonProductLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B2E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B2E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B2E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
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