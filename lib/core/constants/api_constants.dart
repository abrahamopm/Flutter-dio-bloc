class ApiConstants {
  static const String baseUrl = 'https://fakestoreapi.com';

  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';

  static String productById(int id) => '/products/$id';
  static String productsByCategory(String category) => '/products/category/$category';
}