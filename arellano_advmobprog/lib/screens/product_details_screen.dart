import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product_model.dart';
import '../widgets/custom_text.dart';

// Enhancement 2: Add details page when clicked the card | DONE.

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  product.thumbnail,
                  width: double.infinity,
                  height: 280.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 280.h,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.broken_image,
                        size: 50.sp,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20.h),

              CustomText(
                text: product.title,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),

              SizedBox(height: 8.h),

              CustomText(
                text: '\$${product.price.toStringAsFixed(2)}',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20.sp,
                  ),

                  SizedBox(width: 5.w),

                  CustomText(
                    text: product.rating.toString(),
                    fontSize: 15.sp,
                  ),

                  SizedBox(width: 8.w),

                  CustomText(
                    text: '•',
                    fontSize: 15.sp,
                  ),

                  SizedBox(width: 8.w),

                  CustomText(
                    text: '${product.reviews.length} reviews',
                    fontSize: 15.sp,
                  ),
                ],
              ),

              SizedBox(height: 24.h), 

              CustomText(
                text: 'Description',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),

              SizedBox(height: 8.h),

              CustomText(
                text: product.description,
                fontSize: 15.sp,
              ),

              SizedBox(height: 24.h), 

              CustomText(
                text: 'Product Information',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),

              SizedBox(height: 12.h),

              _infoRow('Brand', product.brand),
              _infoRow('Category', product.category),
              _infoRow('Stock', product.stock.toString()),
              _infoRow('SKU', product.sku),
              _infoRow(
                'Availability',
                product.availabilityStatus,
              ),
              _infoRow(
                'Warranty',
                product.warrantyInformation,
              ),
              _infoRow(
                'Shipping',
                product.shippingInformation,
              ),
              _infoRow(
                'Return Policy',
                product.returnPolicy,
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: CustomText(
              text: '$label:',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: CustomText(
              text: value,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}