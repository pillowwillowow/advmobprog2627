import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/cart_provider.dart';

import '../models/product_model.dart';
import '../widgets/custom_text.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  final bool showAddtocart;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.showAddtocart = true,
  });

  // SAME COLOR SCHEME AS CART

  static const Color orangeColor = Color(0xFFFFA000);
  static const Color darkOrangeColor = Color(0xFFF57C00);
  static const Color greenColor = Color(0xFF4CAF50);
  static const Color darkGreenColor = Color.fromARGB(255, 22, 70, 25);
  static const Color lightGreenColor = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 280.h,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),

                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.contain,

                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.image_not_supported_outlined,
                      size: 60.sp,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 20.h),

            CustomText(
              text: product.title,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText(
                  text: '₱${product.price.toStringAsFixed(2)}',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),

                SizedBox(width: 10.w),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),

                  decoration: BoxDecoration(
                    color: lightGreenColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),

                  child: Text(
                    '${product.discountPercentage.toStringAsFixed(0)}% OFF',

                    style: TextStyle(
                      color: darkGreenColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                const Icon(Icons.star, color: orangeColor),

                SizedBox(width: 5.w),

                CustomText(
                  text: product.rating.toString(),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),

                SizedBox(width: 8.w),

                CustomText(text: '•', fontSize: 15.sp),

                SizedBox(width: 8.w),

                CustomText(
                  text: '${product.reviews.length} reviews',
                  fontSize: 15.sp,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            _sectionTitle('Description'),

            SizedBox(height: 8.h),

            CustomText(text: product.description, fontSize: 15.sp),

            SizedBox(height: 24.h),

            _sectionTitle('Product Information'),

            SizedBox(height: 12.h),

            _infoCard(
              context: context,
              icon: Icons.storefront_outlined,
              label: 'Brand',
              value: product.brand,
            ),

            _infoCard(
              context: context,
              icon: Icons.category_outlined,
              label: 'Category',
              value: product.category,
            ),

            _infoCard(
              context: context,
              icon: Icons.inventory_2_outlined,
              label: 'Stock',
              value: product.stock.toString(),
            ),

            _infoCard(
              context: context,
              icon: Icons.qr_code_2,
              label: 'SKU',
              value: product.sku,
            ),

            _infoCard(
              context: context,
              icon: Icons.check_circle_outline,
              label: 'Availability',
              value: product.availabilityStatus,
            ),

            _infoCard(
              context: context,
              icon: Icons.verified_outlined,
              label: 'Warranty',
              value: product.warrantyInformation,
            ),

            _infoCard(
              context: context,
              icon: Icons.local_shipping_outlined,
              label: 'Shipping',
              value: product.shippingInformation,
            ),

            _infoCard(
              context: context,
              icon: Icons.assignment_return_outlined,
              label: 'Return Policy',
              value: product.returnPolicy,
            ),

            SizedBox(height: 24.h),

            // ADD TO CART ONLY WHEN ENABLED
            if (showAddtocart)
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      context.read<CartProvider>().addToCart(product);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} added to cart!'),
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to add product to cart.'),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.add_shopping_cart, size: 20.sp),
                  label: Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 22.h,

          decoration: BoxDecoration(
            color: orangeColor,

            borderRadius: BorderRadius.circular(4.r),
          ),
        ),

        SizedBox(width: 8.w),

        CustomText(text: title, fontSize: 18.sp, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _infoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(bottom: 8.h),

      padding: EdgeInsets.all(12.r),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10.r),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, size: 20.sp, color: const Color.fromARGB(255, 25, 78, 28)),

          SizedBox(width: 10.w),

          SizedBox(
            width: 90.w,

            child: CustomText(
              text: label,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: CustomText(text: value, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
