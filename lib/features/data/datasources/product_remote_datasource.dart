import 'package:dio/dio.dart';
import 'package:flutter_dio_bloc/core/constants/api_constants.dart';
import 'package:flutter_dio_bloc/features/data/models/product.dart';

class ProductRemoteDatasource {
  ProductRemoteDatasource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<Product>> getProducts() async {
    final response = await _dio.get(ApiConstants.productsEndpoint);
    final items = response.data as List<dynamic>;
    return items
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductById(int id) async {
    final response = await _dio.get(ApiConstants.productById(id));
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> createProduct(Product product) async {
    final response = await _dio.post(
      ApiConstants.productsEndpoint,
      data: product.toJson(),
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(Product product) async {
    if (product.id == null) {
      throw ArgumentError('Product id is required for updates.');
    }

    final response = await _dio.put(
      ApiConstants.productById(product.id!),
      data: product.toJson(),
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> patchProduct(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch(
      ApiConstants.productById(id),
      data: data,
    );
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete(ApiConstants.productById(id));
  }
}