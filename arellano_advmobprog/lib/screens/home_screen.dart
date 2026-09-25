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
  final UserService _userService = UserService();

  User? _user;
  bool _isLoadingUser = true;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUser();

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
            ? const Center(child: CircularProgressIndicator())
            : PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),

                children: [
                  // Shop / Home
                  const ProductScreen(),

                  //  Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it.
                  //  Based on the saved user data render the cart by userId
                  CartScreen(userId: _user!.id),

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
  final messageController =
      TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: 24.w,
        ),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            22.r,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chat Header
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF4CAF50,
                  ),
                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(
                      22.r,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: 0.18,
                        ),
                        shape:
                            BoxShape.circle,
                      ),
                      child: Icon(
                        Icons
                            .support_agent_rounded,
                        color: Colors.white,
                        size: 25.sp,
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Customer Support',
                            style: TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 17.sp,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration:
                                    const BoxDecoration(
                                  color:
                                      Colors.white,
                                  shape:
                                      BoxShape
                                          .circle,
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              Text(
                                'Online',
                                style:
                                    TextStyle(
                                  color: Colors
                                      .white
                                      .withValues(
                                    alpha:
                                        0.9,
                                  ),
                                  fontSize:
                                      11.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        FocusScope.of(
                          dialogContext,
                        ).unfocus();

                        Navigator.pop(
                          dialogContext,
                        );
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  18.w,
                  20.h,
                  18.w,
                  18.h,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Support message
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration:
                              const BoxDecoration(
                            color: Color(
                              0xFFE8F5E9,
                            ),
                            shape:
                                BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .support_agent_rounded,
                            color: const Color(
                              0xFF4CAF50,
                            ),
                            size: 19.sp,
                          ),
                        ),

                        SizedBox(width: 9.w),

                        Flexible(
                          child: Container(
                            padding:
                                EdgeInsets
                                    .symmetric(
                              horizontal:
                                  14.w,
                              vertical:
                                  11.h,
                            ),
                            decoration:
                                BoxDecoration(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius
                                      .only(
                                topRight:
                                    Radius
                                        .circular(
                                  15.r,
                                ),
                                bottomLeft:
                                    Radius
                                        .circular(
                                  15.r,
                                ),
                                bottomRight:
                                    Radius
                                        .circular(
                                  15.r,
                                ),
                              ),
                            ),
                            child: Text(
                              'Hello! 👋 How can '
                              'we help you today?',
                              style: TextStyle(
                                fontSize:
                                    13.sp,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 22.h),

                    Text(
                      'Your Message',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight:
                            FontWeight.w600,
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 7.h),

                    TextField(
                      controller:
                          messageController,
                      minLines: 3,
                      maxLines: 4,
                      textCapitalization:
                          TextCapitalization
                              .sentences,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Type your message here...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        )
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(
                              alpha: 0.5,
                            ),
                        contentPadding:
                            EdgeInsets.all(
                          14.r,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14.r,
                          ),
                          borderSide:
                              BorderSide
                                  .none,
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14.r,
                          ),
                          borderSide:
                              BorderSide(
                            color: Theme.of(
                              context,
                            ).dividerColor,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14.r,
                          ),
                          borderSide:
                              const BorderSide(
                            color: Color(
                              0xFF4CAF50,
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final message =
                              messageController
                                  .text
                                  .trim();

                          if (message.isEmpty) {
                            ScaffoldMessenger
                                    .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a message.',
                                ),
                              ),
                            );

                            return;
                          }

                          FocusScope.of(
                            dialogContext,
                          ).unfocus();

                          Navigator.pop(
                            dialogContext,
                          );

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Message sent successfully!',
                              ),
                            ),
                          );
                        },
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF4CAF50,
                          ),
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12.r,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .send_rounded,
                              size: 18.sp,
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              'Send Message',
                              style:
                                  TextStyle(
                                fontSize:
                                    14.sp,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildAppBarTitle() {
    if (_selectedIndex == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
