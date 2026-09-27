import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(Uri.parse('$host/products?limit=0'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products. '
        'Status code: '
        '${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);

    final List productsJson = data['products'] ?? [];

    return productsJson
        .map((product) => Product.fromJson(Map<String, dynamic>.from(product)))
        .toList();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse(
        '$host/products/category/'
        '$category',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load category: '
        '$category',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);

    final List productsJson = data['products'] ?? [];

    return productsJson
        .map((product) => Product.fromJson(Map<String, dynamic>.from(product)))
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('$host/products/categories'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }

    final List data = json.decode(response.body);

    return data
        .map((category) {
          if (category is String) {
            return category;
          }

          if (category is Map<String, dynamic>) {
            return category['slug']?.toString() ??
                category['name']?.toString() ??
                '';
          }

          return '';
        })
        .where((category) => category.isNotEmpty)
        .toList();
  }

  Future<Product> fetchProductById(int productId) async {
    final response = await http.get(Uri.parse('$host/products/$productId'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load product '
        '$productId',
      );
    }

    final Map<String, dynamic> data = json.decode(response.body);

    return Product.fromJson(data);
  }

  Future<Cart?> fetchCartByUserId(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Unable to load user cart.');
    }

    final data = jsonDecode(response.body);

    final carts = data['carts'] as List<dynamic>? ?? [];

    if (carts.isEmpty) {
      return null;
    }

    return Cart.fromJson(Map<String, dynamic>.from(carts.first));
  }

  Future<Cart> fetchCartById(int id) async {
    final response = await http.get(Uri.parse('$host/carts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cart $id');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    return Cart.fromJson(data);
  }

  Future<Cart> addToCart({
    required int cartId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('$host/carts/$cartId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'merge': true,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    return Cart.fromJson(data);
  }
}
