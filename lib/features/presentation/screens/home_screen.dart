import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dio_bloc/features/presentation/providers/product_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: BlocBuilder<ProductProvider, ProductState>(
        builder: (context, state) {
          return switch (state) {
            ProductInitial() || ProductLoading() =>
              const Center(child: CircularProgressIndicator()),
            ProductError(:final message) => Center(child: Text(message)),
            ProductLoaded(:final products) => RefreshIndicator(
                onRefresh: () => context.read<ProductProvider>().loadProducts(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.image),
                      ),
                      title: Text(product.title),
                      subtitle: Text(product.category),
                      trailing: Text('\$${product.price.toStringAsFixed(2)}'),
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