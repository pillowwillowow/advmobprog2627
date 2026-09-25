import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import '../providers/cart_provider.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ProductService _productService = ProductService();

  static const Color darkOrangeColor = Color(0xFFF57C00);
  static const Color greenColor = Color(0xFF4CAF50);

  Future<void> _openProductDetails(int productId) async {
    try {
      final Product product = await _productService.fetchProductById(productId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProductDetailsScreen(product: product, showAddtocart: false),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load product details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      child: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.items;

          if (items.isEmpty) {
            return _buildEmptyCart();
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),

            children: [
              ...items.map((item) => _buildCartItem(item, cartProvider)),

              SizedBox(height: 4.h),

              _buildOrderSummary(cartProvider),

              SizedBox(height: 10.h),

              _buildConfirmButton(cartProvider),

              SizedBox(height: 10.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
    final product = item.product;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),

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
            _openProductDetails(product.id);
          },

          child: Padding(
            padding: EdgeInsets.all(10.r),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                Container(
                  width: 78.w,
                  height: 78.h,

                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,

                    borderRadius: BorderRadius.circular(12.r),
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),

                    child: Image.network(
                      product.thumbnail,

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
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      CustomText(
                        text: product.title,

                        fontSize: 14.sp,

                        fontWeight: FontWeight.bold,

                        maxLines: 2,
                      ),

                      SizedBox(height: 4.h),

                      // Price
                      CustomText(
                        text: '₱${product.price.toStringAsFixed(2)}',

                        fontSize: 13.sp,

                        fontWeight: FontWeight.bold,
                      ),

                      SizedBox(height: 3.h),

                      CustomText(
                        text:
                            '${product.discountPercentage.toStringAsFixed(0)}% off • ₱${item.total.toStringAsFixed(2)} total',

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
                        cartProvider.increaseQuantity(product.id);
                      },
                    ),

                    SizedBox(height: 5.h),

                    SizedBox(
                      width: 28.w,

                      child: Center(
                        child: CustomText(
                          text: '${item.quantity}',

                          fontSize: 13.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 5.h),

                    _buildQuantityButton(
                      icon: Icons.remove,

                      backgroundColor: const Color(0xFFFFF3E0),

                      iconColor: darkOrangeColor,

                      onTap: () {
                        cartProvider.decreaseQuantity(product.id);
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

          child: Icon(icon, size: 16.sp, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 4.h),

      child: Column(
        children: [
          _summaryRow(
            label: 'Subtotal:',

            value: '₱${cartProvider.subtotal.toStringAsFixed(2)}',
          ),

          SizedBox(height: 5.h),

          _summaryRow(
            label: 'Discount:',

            value: '₱${cartProvider.discount.toStringAsFixed(2)}',
          ),

          SizedBox(height: 8.h),

          Divider(color: Colors.grey.shade300, height: 1),

          SizedBox(height: 8.h),

          _summaryRow(
            label: 'Total:',

            value: '₱${cartProvider.total.toStringAsFixed(2)}',

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        CustomText(
          text: label,

          fontSize: labelSize ?? 12.sp,

          fontWeight: labelBold ? FontWeight.bold : FontWeight.normal,
        ),

        CustomText(
          text: value,

          fontSize: valueSize ?? 12.sp,

          fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildConfirmButton(CartProvider cartProvider) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,

      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,

            builder: (BuildContext dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),

                title: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_checkout,

                      color: greenColor,

                      size: 24.sp,
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Text(
                        'Confirm Order',

                        style: TextStyle(
                          fontSize: 18.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                content: Text(
                  'Are you sure you want to confirm your order?',

                  style: TextStyle(fontSize: 14.sp),
                ),

                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },

                    child: Text(
                      'Cancel',

                      style: TextStyle(
                        color: darkOrangeColor,

                        fontSize: 14.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order confirmed!')),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),

                    child: Text(
                      'Confirm',

                      style: TextStyle(
                        fontSize: 14.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 29, 85, 31),

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.shopping_cart_checkout, size: 18.sp),

            SizedBox(width: 8.w),

            Text(
              'Confirm Order',

              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

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

          CustomText(text: 'Add products to your cart.', fontSize: 13.sp),
        ],
      ),
    );
  }
}
