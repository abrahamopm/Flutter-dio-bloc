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
}