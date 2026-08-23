import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse(
        '$host/products/category/sports-accessories',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body);

      final List productsJson =
          data['products'] ?? [];

      return productsJson
          .map(
            (json) => Product.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } else {
      throw Exception(
        'Failed to load products',
      );
    }
  }

 
  // ENHANCEMENT 1: Make a cart_screen in order to render the new API endpoint. The items on the cart_screen must be clickable going to the detail_screen for the utilization of the screen widget. | DONE. 
  Future<Product> fetchProductById(
    int productId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$host/products/$productId',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body);

      return Product.fromJson(data);
    } else {
      throw Exception(
        'Failed to load product',
      );
    }
  }
  
  // ENHANCEMENT 3: Read the Cart documentation https://dummyjson.com/docs/carts and check how to integrate cart by user id. | DONE.

  Future<Cart> fetchUserCart(
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$host/carts/user/$userId',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body);

      final List carts =
          data['carts'] ?? [];

      if (carts.isEmpty) {
        throw Exception(
          'No cart found for user $userId',
        );
      }

      return Cart.fromJson(
        Map<String, dynamic>.from(
          carts.first,
        ),
      );
    } else {
      throw Exception(
        'Failed to load cart for user $userId',
      );
    }
  }

  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$host/carts/add',
      ),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'userId': userId,

        'products': [
          {
            'id': productId,
            'quantity': quantity,
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(response.body);

      return Cart.fromJson(data);
    } else {
      throw Exception(
        'Failed to add product to cart',
      );
    }
  }
}