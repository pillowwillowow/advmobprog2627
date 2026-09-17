import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Screens
import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../models/user.dart';
import '../services/user_service.dart'; 

// Widgets
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();
  final UserService _userService =
    UserService();

    User? _user;
    bool _isLoadingUser = true;
@override
void initState() {
  super.initState();
  _loadUser();
}

Future<void> _loadUser() async {
  final user =
      await _userService.getUser();

  if (!mounted) return;

  setState(() {
    _user = user;
    _isLoadingUser = false;
  });
}

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

          // App bar title changes depending on selected page
          title: _buildAppBarTitle(),

          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),

        // Chat button
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                onPressed: () {
                  _showChatDialog(context);
                },
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                child: const Icon(Icons.chat),
              ),

        body: _isLoadingUser
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(),

        children: [
          // Shop / Home
          const ProductScreen(),

        //  Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it. 
        //  Based on the saved user data render the cart by userId 

          CartScreen(
            userId: _user!.id,
          ),

          // Profile
          const ProfileScreen(),
        ],

        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
      ),

        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,

          currentIndex: _selectedIndex,

          onTap: _onTappedBar,

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),

            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),

            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),

          title: Row(
            children: [
              Icon(Icons.chat, color: const Color(0xFF4CAF50), size: 24.sp),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello! How can we help you?',
                  style: TextStyle(fontSize: 14.sp),
                ),

                SizedBox(height: 16.h),

                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    prefixIcon: const Icon(Icons.message_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final message = messageController.text.trim();

                if (message.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message sent: $message')),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),

              child: Text(
                'Send',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBarTitle() {
    if (_selectedIndex == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/guest.png', scale: 11.sp),

          SizedBox(width: 8.w),

          CustomText(
            text: 'Home',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ],
      );
    }

    // Cart
    if (_selectedIndex == 1) {
      return CustomText(
        text: 'Cart',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      );
    }

    // Profile
    if (_selectedIndex == 2) {
      return CustomText(
        text: 'Profile',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      );
    }

    // Default
    return CustomText(
      text: 'Home',
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });

    _pageController.jumpToPage(value);
  }
}
