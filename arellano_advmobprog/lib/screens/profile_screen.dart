import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final UserService _userService =
      UserService();

  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();

    // Enhancement 3:
    // Load the authenticated user's saved data.
    _userFuture = _userService.getUser();
  }

  Future<void> _logout() async {
    await _userService.logoutUser();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signin',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load profile',
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'No user data found',
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
          );
        }

        final user = snapshot.data!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              CircleAvatar(
                radius: 55.r,
                backgroundImage:
                    user.image.isNotEmpty
                        ? NetworkImage(
                            user.image,
                          )
                        : null,
                child: user.image.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 55.sp,
                      )
                    : null,
              ),

              SizedBox(height: 16.h),

              Text(
                '${user.firstName} '
                '${user.lastName}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              SizedBox(height: 5.h),

              Text(
                '@${user.username}',
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 25.h),

              _profileItem(
                Icons.email_outlined,
                'Email',
                user.email,
              ),

              _profileItem(
                Icons.person_outline,
                'Gender',
                user.gender,
              ),

              _profileItem(
                Icons.badge_outlined,
                'User ID',
                user.id.toString(),
              ),

              SizedBox(height: 25.h),

              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout,
                  ),
                  label: const Text(
                    'Log Out',
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFF57C00,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _profileItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      margin: EdgeInsets.only(
        bottom: 12.h,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(
            0xFF4CAF50,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}