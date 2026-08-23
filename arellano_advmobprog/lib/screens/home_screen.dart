import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_screen.dart';
import 'cart_screen.dart';

import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    this.username = '',
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int _selectedIndex = 0;

  final PageController _pageController =
      PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(

        appBar: AppBar(
          automaticallyImplyLeading: false,

          title: _buildAppBarTitle(),

          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 24.sp,
              ),

              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/settings',
                );
              },
            ),
          ],
        ),

        // ENHANCEMENT 2:  Make the chat bottom navigation as FloatingActionButton. When in the cart_screen the FloatingActionButton must be hidden. | DONE.

        floatingActionButton:
            _selectedIndex == 1
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chat button pressed',
                          ),
                        ),
                      );
                    },

                    child: const Icon(
                      Icons.chat,
                    ),
                  ),

              body: PageView(
                controller:
                    _pageController,

                physics:
                    const NeverScrollableScrollPhysics(),

                children: const [

                  ProductScreen(),
                  CartScreen(
                    userId: 9,
                  ),

                  // Profile
                  Center(
                    child: Text(
                      'Profile',
                    ),
                  ),
                ],

                onPageChanged: (page) {
                  setState(() {
                    _selectedIndex = page;
                  });
                },
              ),
              bottomNavigationBar:
                  BottomNavigationBar(

                showSelectedLabels: false,

                showUnselectedLabels: false,

                currentIndex:
                    _selectedIndex,

                onTap:
                    _onTappedBar,

                items: const [

                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.shop_2,
                    ),
                    label: 'Shop',
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.shopping_cart,
                    ),
                    label: 'Cart',
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        }

      Widget _buildAppBarTitle() {

        if (_selectedIndex == 0) {
          return Row(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              Image.asset(
                'assets/images/guest.png',
                scale: 11.sp,
              ),

              SizedBox(width: 8.w),

              CustomText(
                text: 'Home',
                fontSize: 18.sp,
                fontWeight:
                    FontWeight.w600,
              ),
            ],
          );
        }

        String title; 

        if (_selectedIndex == 1) {
          title = 'Cart';
        } else if (_selectedIndex == 2) {
          title = 'Profile';
        } else {
          title = 'Home';
        }

        return CustomText(
          text: title,
          fontSize: 18.sp,
          fontWeight:
              FontWeight.w600, 
        );
      }

      void _onTappedBar(
        int value,
      ) {
        setState(() {
          _selectedIndex = value;
        });

        _pageController.jumpToPage(
          value,
        );
      }
    }