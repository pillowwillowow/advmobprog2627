import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();

  final TextEditingController _searchController = TextEditingController();

  static const Color orangeColor = Color(0xFFFFA000);
  static const Color greenColor = Color(0xFF4CAF50);
  static const Color darkGreenColor = Color(0xFF388E3C);
  static const Color lightGreenColor = Color(0xFFE8F5E9);

  List<Product> _products = [];

  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;

  static const int _productsPerPage = 10;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();

        _currentPage = 1;
      });
    });

    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.fetchAllProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _currentPage = 1;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load products.\n\n$error';
      });
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      final title = product.title.toLowerCase();

      final category = product.category.toLowerCase();

      final brand = product.brand.toLowerCase();

      return title.contains(_searchQuery) ||
          category.contains(_searchQuery) ||
          brand.contains(_searchQuery);
    }).toList();
  }

  List<Product> get _paginatedProducts {
    final products = _filteredProducts;

    final startIndex = (_currentPage - 1) * _productsPerPage;

    if (startIndex >= products.length) {
      return [];
    }

    final endIndex = startIndex + _productsPerPage;

    return products.sublist(
      startIndex,
      endIndex > products.length ? products.length : endIndex,
    );
  }

  int get _totalPages {
    if (_filteredProducts.isEmpty) {
      return 1;
    }

    return (_filteredProducts.length / _productsPerPage).ceil();
  }

  void _openProductDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailsScreen(product: product, showAddtocart: true),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: greenColor));
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: greenColor,
      onRefresh: _loadProducts,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'All Products',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomText(
                    text: '${_filteredProducts.length} products',
                    fontSize: 12.sp,
                  ),
                ],
              ),
            ),
          ),

          if (_paginatedProducts.isEmpty)
            SliverToBoxAdapter(child: _buildNoProducts())
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.66,
                ),
                itemCount: _paginatedProducts.length,
                itemBuilder: (context, index) {
                  final product = _paginatedProducts[index];

                  return _buildProductCard(product);
                },
              ),
            ),

          if (_filteredProducts.isNotEmpty)
            SliverToBoxAdapter(child: _buildPagination()),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            _openProductDetails(product);
          },
          child: Padding(
            padding: EdgeInsets.all(9.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
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
                            size: 40.sp,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: lightGreenColor,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    _formatCategory(product.category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: darkGreenColor,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 5.h),

                CustomText(
                  text: product.title,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                ),

                SizedBox(height: 4.h),

                Row(
                  children: [
                    Icon(Icons.star, color: orangeColor, size: 14.sp),
                    SizedBox(width: 3.w),
                    Text(
                      product.rating.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                        color: darkGreenColor,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 5.h),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '₱${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildPagination() {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 1 ? _previousPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Previous'),
          ),

          SizedBox(width: 16.w),

          Text(
            'Page $_currentPage of $_totalPages',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),

          SizedBox(width: 16.w),

          ElevatedButton(
            onPressed: _currentPage < _totalPages ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: greenColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),

            SizedBox(height: 16.h),

            CustomText(
              text: 'Unable to load products',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),

            SizedBox(height: 18.h),

            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProducts() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 55.sp,
              color: Colors.grey.shade400,
            ),

            SizedBox(height: 12.h),

            CustomText(
              text: 'No products found',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    return category
        .split('-')
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
