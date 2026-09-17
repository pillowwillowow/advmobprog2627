import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

//  Enhancement 1: Make your own UI for the splash_screen implementing the persistent authentication. *//
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    final loggedIn = await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home', arguments: userData);
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/nuicon.jpeg', width: 100.w, height: 100.h),

            SizedBox(height: 20.h),

            Text(
              'E-Commerce App',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30.h),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
