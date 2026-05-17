import 'package:flutter_dio_bloc/features/data/datasources/product_remote_datasource.dart';
import 'package:flutter_dio_bloc/features/data/models/product.dart';

class ProductRepository {
  ProductRepository({required ProductRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  final ProductRemoteDatasource _remoteDatasource;

  Future<List<Product>> getProducts() => _remoteDatasource.getProducts();

  Future<Product> getProductById(int id) => _remoteDatasource.getProductById(id);

  Future<Product> createProduct(Product product) => _remoteDatasource.createProduct(product);

  Future<Product> updateProduct(Product product) => _remoteDatasource.updateProduct(product);

  Future<void> deleteProduct(int id) => _remoteDatasource.deleteProduct(id);
}