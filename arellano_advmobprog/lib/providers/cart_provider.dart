import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get discountedPrice {
    return product.price *
        (1 - product.discountPercentage / 100);
  }

  double get total {
    return discountedPrice * quantity;
  }
}

class CartProvider extends ChangeNotifier {
  final ProductService _productService =
      ProductService();

  final List<CartItem> _items = [];

  bool _isLoaded = false;
  bool _isLoading = false;

  List<CartItem> get items =>
      List.unmodifiable(_items);

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;


  Future<void> loadCartFromApi() async {
    if (_isLoaded || _isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // ALWAYS fetch Cart 1.
      final cart =
          await _productService.fetchCartById(1);

      // Clear local list first.
      _items.clear();

      // Load every product that belongs to Cart 1.
      for (final cartProduct in cart.products) {
        try {
          final product =
              await _productService.fetchProductById(
            cartProduct.id,
          );

          _items.add(
            CartItem(
              product: product,
              quantity: cartProduct.quantity,
            ),
          );
        } catch (error) {
          debugPrint(
            'Failed to load product '
            '${cartProduct.id}: $error',
          );
        }
      }

      _isLoaded = true;

      debugPrint(
        'Cart 1 loaded successfully.',
      );

      debugPrint(
        'Products in local cart: ${_items.length}',
      );
    } catch (error) {
      debugPrint(
        'Failed to load Cart 1: $error',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void addToCart(Product product) {
    final existingIndex =
        _items.indexWhere(
      (item) =>
          item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Product already exists.
      // Increase quantity by 1.
      _items[existingIndex].quantity++;
    } else {
      // Product does not exist.
      _items.add(
        CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  bool isInCart(int productId) {
    return _items.any(
      (item) =>
          item.product.id == productId,
    );
  }

  int getQuantity(int productId) {
    final index =
        _items.indexWhere(
      (item) =>
          item.product.id == productId,
    );

    if (index == -1) {
      return 0;
    }

    return _items[index].quantity;
  }

  void increaseQuantity(int productId) {
    final index =
        _items.indexWhere(
      (item) =>
          item.product.id == productId,
    );

    if (index == -1) {
      return;
    }

    _items[index].quantity++;

    notifyListeners();
  }


  void decreaseQuantity(int productId) {
    final index =
        _items.indexWhere(
      (item) =>
          item.product.id == productId,
    );

    if (index == -1) {
      return;
    }

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere(
      (item) =>
          item.product.id == productId,
    );

    notifyListeners();
  }

  void clearCart() {
    _items.clear();

    notifyListeners();
  }


  double get subtotal {
    return _items.fold(
      0,
      (sum, item) {
        return sum +
            (item.product.price *
                item.quantity);
      },
    );
  }

  double get total {
    return _items.fold(
      0,
      (sum, item) {
        return sum + item.total;
      },
    );
  }

  double get discount {
    return subtotal - total;
  }

  int get totalQuantity {
    return _items.fold(
      0,
      (sum, item) {
        return sum + item.quantity;
      },
    );
  }
}