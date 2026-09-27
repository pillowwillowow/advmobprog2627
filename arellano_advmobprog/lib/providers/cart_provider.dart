import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get discountedPrice {
    return product.price * (1 - product.discountPercentage / 100);
  }

  double get total {
    return discountedPrice * quantity;
  }
}

class CartProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  final List<CartItem> _items = [];

  bool _isLoaded = false;
  bool _isLoading = false;

  int? _loadedUserId;

  String _cartSource = '';

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isLoaded => _isLoaded;

  bool get isLoading => _isLoading;

  Future<void> loadCartFromApi(int userId) async {
    if (_isLoading) {
      return;
    }

    if (_isLoaded && _loadedUserId == userId && _cartSource == 'dummyjson') {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final cart = await _productService.fetchCartByUserId(userId);

      _items.clear();

      _cartSource = 'dummyjson';
      _loadedUserId = userId;

      if (cart == null) {
        _isLoaded = true;

        debugPrint(
          'No cart found for '
          'user $userId.',
        );

        return;
      }

      for (final cartProduct in cart.products) {
        try {
          final product = await _productService.fetchProductById(
            cartProduct.id,
          );

          _items.add(
            CartItem(product: product, quantity: cartProduct.quantity),
          );
        } catch (error) {
          debugPrint(
            'Failed to load product '
            '${cartProduct.id}: '
            '$error',
          );
        }
      }

      _isLoaded = true;

      debugPrint(
        'Cart for user $userId '
        'loaded successfully.',
      );

      debugPrint(
        'Products in cart: '
        '${_items.length}',
      );
    } catch (error) {
      _items.clear();

      _loadedUserId = userId;
      _cartSource = 'dummyjson';
      _isLoaded = true;

      debugPrint(
        'Failed to load cart for '
        'user $userId: $error',
      );
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void prepareFirebaseCart() {
    if (_cartSource == 'dummyjson') {
      _items.clear();
    }

    _cartSource = 'firebase';
    _loadedUserId = null;

    _isLoaded = true;
    _isLoading = false;

    notifyListeners();
  }

  void addToCart(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }

    debugPrint(
      'Added ${product.title}. '
      'Cart items: ${_items.length}',
    );

    notifyListeners();
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index == -1) {
      return 0;
    }

    return _items[index].quantity;
  }

  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index == -1) {
      return;
    }

    _items[index].quantity++;

    notifyListeners();
  }

  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

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
    _items.removeWhere((item) => item.product.id == productId);

    notifyListeners();
  }

  void clearCart() {
    _items.clear();

    _loadedUserId = null;
    _cartSource = '';

    _isLoaded = false;
    _isLoading = false;

    notifyListeners();
  }

  double get subtotal {
    return _items.fold(0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });
  }

  double get total {
    return _items.fold(0, (sum, item) {
      return sum + item.total;
    });
  }

  double get discount {
    return subtotal - total;
  }

  int get totalQuantity {
    return _items.fold(0, (sum, item) {
      return sum + item.quantity;
    });
  }
}
