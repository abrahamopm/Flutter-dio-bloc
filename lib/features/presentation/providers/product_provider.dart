import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dio_bloc/features/data/models/product.dart';
import 'package:flutter_dio_bloc/features/data/repositories/product_repository.dart';

sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductLoaded extends ProductState {
  const ProductLoaded(this.products);

  final List<Product> products;

  @override
  List<Object?> get props => [products];
}

final class ProductError extends ProductState {
  const ProductError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProductProvider extends Cubit<ProductState> {
  ProductProvider({required ProductRepository repository})
      : _repository = repository,
        super(const ProductInitial());

  final ProductRepository _repository;

  Future<void> loadProducts() async {
    emit(const ProductLoading());

    try {
      final products = await _repository.getProducts();
      emit(ProductLoaded(products));
    } catch (error) {
      emit(ProductError(error.toString()));
    }
  }

  Future<void> createProduct(String title) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    try {
      final newProduct = await _repository.createProduct(
        Product(
          title: title,
          price: 10.99,
          description: 'A new product',
          category: 'electronics',
          image: 'https://i.pravatar.cc/150?u=$title',
        ),
      );

      emit(ProductLoaded([newProduct, ...currentState.products]));
    } catch (error) {
      emit(ProductError(error.toString()));
    }
  }

  Future<void> updateProduct(Product product, String newTitle) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    try {
      final updatedProduct = await _repository.updateProduct(
        Product(
          id: product.id,
          title: newTitle,
          price: product.price,
          description: product.description,
          category: product.category,
          image: product.image,
        ),
      );

      final newProducts = currentState.products.map((p) {
        return p.id == updatedProduct.id ? updatedProduct : p;
      }).toList();

      emit(ProductLoaded(newProducts));
    } catch (error) {
      emit(ProductError(error.toString()));
    }
  }

  Future<void> deleteProduct(int id) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    try {
      await _repository.deleteProduct(id);

      final newProducts =
          currentState.products.where((p) => p.id != id).toList();

      emit(ProductLoaded(newProducts));
    } catch (error) {
      emit(ProductError(error.toString()));
    }
  }
}