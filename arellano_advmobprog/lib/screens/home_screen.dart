import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_text.dart';
import 'chat_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';
import '../services/user_service.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTappedBar(int index) {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
  }

  Widget _buildAppBarTitle() {
    const titles = ['Home', 'Chats', 'Profile'];

    return CustomText(
      text: titles[_selectedIndex],
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
    );
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
              tooltip: 'Cart',
              icon: Icon(Icons.shopping_cart_outlined, size: 24.sp),
              onPressed: () async {
                final userService = UserService();

                final loginType = await userService.getLoginType();

                int? userId;

                if (loginType == 'dummyjson') {
                  final userData = await userService.getUserData();

                  userId = userData['id'] as int?;
                }

                if (!context.mounted) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CartScreen(userId: userId, loginType: loginType),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Settings',
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: const [ProductScreen(), ChatScreen(), ProfileScreen()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(
              icon: Icon(Icons.mark_unread_chat_alt_outlined),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
