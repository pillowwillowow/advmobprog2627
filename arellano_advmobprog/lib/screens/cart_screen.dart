import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  late Future<Cart> _cartFuture;
  final ProductService _productService = ProductService();
  final Map<int, int> _quantities = {};


  static const Color darkOrangeColor = Color(0xFFF57C00);
  static const Color greenColor = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _cartFuture = _productService.fetchUserCart(
      widget.userId,
    );
  }

  Future<void> _openProductDetails(int productId) async {
    try {
      final Product product =
          await _productService.fetchProductById(productId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            product: product,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load product details.',
          ),
        ),
      );
    }
  }

  void _increaseQuantity(CartProduct item) {
    setState(() {
      final currentQuantity =
          _quantities[item.id] ?? item.quantity;

      _quantities[item.id] = currentQuantity + 1;
    });
  }

  void _decreaseQuantity(CartProduct item) {
    setState(() {
      final currentQuantity =
          _quantities[item.id] ?? item.quantity;

      if (currentQuantity > 1) {
        _quantities[item.id] = currentQuantity - 1;
      }
    });
  }

  int _getQuantity(CartProduct item) {
    return _quantities[item.id] ?? item.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: greenColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: CustomText(
                  text: 'Error: ${snapshot.error}',
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          final cart = snapshot.data;

          if (cart == null || cart.products.isEmpty) {
            return _buildEmptyCart();
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              12.w,
              12.h,
              12.w,
              10.h,
            ),
            children: [

              ...cart.products.map(
                (item) => _buildCartItem(item),
              ),

              SizedBox(height: 4.h),

              _buildOrderSummary(cart),

              SizedBox(height: 10.h),

              _buildConfirmButton(),

              SizedBox(height: 10.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartProduct item) {
    final int quantity = _getQuantity(item);

    final double discountedTotal =
        item.discountedPrice * quantity;

    return Container(
      margin: EdgeInsets.only(
        bottom: 10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),

          onTap: () {
            _openProductDetails(item.id);
          },

          child: Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Container(
                  width: 78.w,
                  height: 78.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius:
                        BorderRadius.circular(12.r),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12.r),
                    child: Image.network(
                      item.thumbnail,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.image_not_supported_outlined,
                          size: 30.sp,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: item.title,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        maxLines: 2,
                      ),

                      SizedBox(height: 4.h),

                      // Price
                      CustomText(
                        text:
                            '\$${item.price.toStringAsFixed(2)}',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),

                      SizedBox(height: 3.h),

                      CustomText(
                        text:
                            '${item.discountPercentage.toStringAsFixed(0)}% off • \$${discountedTotal.toStringAsFixed(2)} total',
                        fontSize: 10.sp,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 6.w),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    _buildQuantityButton(
                      icon: Icons.add,
                      backgroundColor: greenColor,
                      iconColor: Colors.white,
                      onTap: () {
                        _increaseQuantity(item);
                      },
                    ),

                    SizedBox(height: 5.h),

                    SizedBox(
                      width: 28.w,
                      child: Center(
                        child: CustomText(
                          text: '$quantity',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    _buildQuantityButton(
                      icon: Icons.remove,
                      backgroundColor:
                          const Color(0xFFFFF3E0),
                      iconColor: darkOrangeColor,
                      onTap: () {
                        _decreaseQuantity(item);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildQuantityButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(7.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(7.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(5.r),
          child: Icon(
            icon,
            size: 16.sp,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Cart cart) {
    double subtotal = 0;
    double discountedTotal = 0;

    for (final item in cart.products) {
      final quantity = _getQuantity(item);

      subtotal += item.price * quantity;
      discountedTotal +=
          item.discountedPrice * quantity;
    }

    final double discount =
        subtotal - discountedTotal;

    return Container(
      padding: EdgeInsets.fromLTRB(
        6.w,
        10.h,
        6.w,
        4.h,
      ),
      child: Column(
        children: [
          _summaryRow(
            label: 'Subtotal:',
            value:
                '\$${subtotal.toStringAsFixed(2)}',
          ),

          SizedBox(height: 5.h),

          _summaryRow(
            label: 'Discount:',
            value:
                '-\$${discount.toStringAsFixed(2)}',
          ),

          SizedBox(height: 8.h),

          Divider(
            color: Colors.grey.shade300,
            height: 1,
          ),

          SizedBox(height: 8.h),

          _summaryRow(
            label: 'Total:',
            value:
                '\$${discountedTotal.toStringAsFixed(2)}',
            labelBold: true,
            valueBold: true,
            labelSize: 16.sp,
            valueSize: 17.sp,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    bool labelBold = false,
    bool valueBold = false,
    double? labelSize,
    double? valueSize,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: label,
          fontSize: labelSize ?? 12.sp,
          fontWeight: labelBold
              ? FontWeight.bold
              : FontWeight.normal,
        ),

        CustomText(
          text: value,
          fontSize: valueSize ?? 12.sp,
          fontWeight: valueBold
              ? FontWeight.bold
              : FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {},

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 29, 85, 31),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.r),
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_checkout,
              size: 18.sp,
            ),

            SizedBox(width: 8.w),

            Text(
              'Confirm Order',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 70.sp,
            color: Colors.grey.shade400,
          ),

          SizedBox(height: 14.h),

          CustomText(
            text: 'Your cart is empty',
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),

          SizedBox(height: 6.h),

          CustomText(
            text: 'Add products to your cart.',
            fontSize: 13.sp,
          ),
        ],
      ),
    );
  }
}