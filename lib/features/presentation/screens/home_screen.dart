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
        title: const Text('Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final product = await _showProductFormDialog(context);
          if (product != null) {
            await context.read<ProductProvider>().createProduct(product);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product Created')),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ProductProvider, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductInitial() || ProductLoading() =>
              const Center(child: _PulsingProgressIndicator()),
            ProductError(:final message) => Center(child: Text(message)),
            ProductLoaded(:final products) => RefreshIndicator(
                onRefresh: () => context.read<ProductProvider>().loadProducts(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.image),
                      ),
                      title: Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(product.category),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final updated = await _showProductFormDialog(context, existing: product);
                              if (updated != null) {
                                await context.read<ProductProvider>().updateProduct(updated);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product Updated')),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.auto_fix_high_outlined),
                            onPressed: () async {
                              final newTitle = await _showTextInputDialog(
                                context,
                                title: 'Patch Title',
                                label: 'Title',
                                initialValue: product.title,
                              );
                              if (newTitle != null && newTitle.trim().isNotEmpty) {
                                await context.read<ProductProvider>().patchProduct(product.id!, {'title': newTitle.trim()});
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product Patched')),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Product'),
                                  content: const Text(
                                      'Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true && context.mounted) {
                                await context
                                    .read<ProductProvider>()
                                    .deleteProduct(product.id!);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Product Deleted')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          };
        },
      ),
    );
  }
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
        title: Text(existing == null ? 'Create Product' : 'Update Product'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Title required' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Price required';
                    final parsed = double.tryParse(value);
                    if (parsed == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null; // optional
                    if (value.trim().length < 3) return 'Description too short';
                    return null;
                  },
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Category required' : null,
                ),
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null; // optional
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
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final product = Product(
                  id: existing?.id,
                  title: titleController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  description: descriptionController.text.trim(),
                  category: categoryController.text.trim(),
                  image: imageController.text.trim(),
                );
                Navigator.of(context).pop(product);
              }
            },
            child: Text(existing == null ? 'Create' : 'Update'),
          ),
        ],
      );
    },
  );
}

class _PulsingProgressIndicator extends StatefulWidget {
  const _PulsingProgressIndicator();

  @override
  State<_PulsingProgressIndicator> createState() => _PulsingProgressIndicatorState();
}

class _PulsingProgressIndicatorState extends State<_PulsingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
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
      child: const CircularProgressIndicator(),
    );
  }
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
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Value required';
              if (value.trim().length > 250) return 'Too long';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}