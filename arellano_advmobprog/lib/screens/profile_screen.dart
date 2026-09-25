import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  String _profileImage = '';

  bool _isLoading = true;
  String _loginType = '';

  User? _dummyUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

// Enhancement 3: Profile Screen
// • Fetch user data via UserService().getUserData().
// • Show user details depending on the LoginType ().
// • Allow update username, change password, delete account.
// • Include Logout in settings → back to login.
  Future<void> _loadProfile() async {
    final loginType = await _userService.getLoginType();

    final profileImage = await _userService.getProfileImage();

    User? dummyUser;

    if (loginType == 'dummyjson') {
      dummyUser = await _userService.getUser();
    }

    if (!mounted) return;

    setState(() {
      _loginType = loginType;
      _dummyUser = dummyUser;
      _profileImage = profileImage;
      _isLoading = false;
    });
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    await _userService.saveProfileImage(image.path);

    if (!mounted) return;

    setState(() {
      _profileImage = image.path;
    });
  }

  Future<void> _logout() async {
    if (_loginType == 'firebase') {
      await _userService.signOut();
    } else {
      await _userService.logoutUser();
    }

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  Future<void> _showUpdateUsername() async {
    final controller = TextEditingController(
      text: _userService.currentFirebaseUser?.displayName ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Update Username'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = controller.text.trim();

                if (username.isEmpty) {
                  return;
                }

                try {
                  await _userService.updateUsername(username: username);

                  if (!dialogContext.mounted) {
                    return;
                  }

                  Navigator.pop(dialogContext);

                  if (!mounted) return;

                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username updated.')),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Add at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Add at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Add at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_]').hasMatch(value)) {
      return 'Add at least one special character';
    }

    return null;
  }

  Future<void> _showChangePassword() async {
    final currentController = TextEditingController();

    final newController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool isChanging = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isChanging,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Row(
                children: [
                  const Icon(Icons.lock_reset, color: Color(0xFF4CAF50)),
                  SizedBox(width: 10.w),
                  const Text('Change Password'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter your current password '
                      'before creating a new one.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    TextField(
                      controller: currentController,
                      obscureText: obscureCurrent,
                      enabled: !isChanging,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureCurrent = !obscureCurrent;
                            });
                          },
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    TextFormField(
                      controller: newController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Example: User123!',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      validator: _validatePassword,
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isChanging
                      ? null
                      : () {
                          FocusScope.of(dialogContext).unfocus();

                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: isChanging
                      ? null
                      : () async {
                          final currentPassword = currentController.text;

                          final newPassword = newController.text;

                          if (currentPassword.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Enter your current password.'),
                              ),
                            );

                            return;
                          }

                          final passwordError = _validatePassword(newPassword);

                          if (passwordError != null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(passwordError)),
                            );

                            return;
                          }

                          if (currentPassword == newPassword) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'New password must be different from your current password.',
                                ),
                              ),
                            );

                            return;
                          }

                          FocusScope.of(dialogContext).unfocus();

                          setDialogState(() {
                            isChanging = true;
                          });

                          try {
                            await _userService.resetPasswordFromCurrentPassword(
                              currentPassword: currentPassword,
                              newPassword: newPassword,
                            );

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop();

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password updated successfully.'),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              isChanging = false;
                            });

                            String message = 'Unable to change password.';

                            final error = e.toString();

                            if (error.contains('invalid-credential') ||
                                error.contains('wrong-password') ||
                                error.contains(
                                  'auth credential is incorrect',
                                )) {
                              message = 'Your current password is incorrect.';
                            } else if (error.contains('weak-password')) {
                              message = 'Your new password is too weak.';
                            } else if (error.contains(
                              'requires-recent-login',
                            )) {
                              message =
                                  'Please sign in again before changing your password.';
                            }

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: isChanging
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );

    // Do not manually dispose these here.
    //
    // The dialog/keyboard may still be completing its
    // removal animation when showDialog returns on some
    // Android devices. Disposing them here can result in
    // lifecycle errors during that transition.
  }

  Future<void> _showDeleteAccount() async {
    final user = _userService.currentFirebaseUser;

    if (user == null || user.email == null) {
      return;
    }

    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This action cannot be undone.'),
              SizedBox(height: 16.h),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text.isEmpty) {
                  return;
                }

                try {
                  await _userService.deleteAccount(
                    email: user.email!,
                    password: passwordController.text,
                  );

                  if (!dialogContext.mounted) {
                    return;
                  }

                  Navigator.pop(dialogContext);

                  if (!mounted) return;

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (route) => false,
                  );
                } catch (e) {
                  if (!dialogContext.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loginType == 'firebase') {
      return _firebaseProfile();
    }

    if (_dummyUser != null) {
      return _dummyJsonProfile(_dummyUser!);
    }

    return Center(
      child: Text('No user data found', style: TextStyle(fontSize: 16.sp)),
    );
  }

  Widget _dummyJsonProfile(User user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          CircleAvatar(
            radius: 55.r,
            backgroundImage: user.image.isNotEmpty
                ? NetworkImage(user.image)
                : null,
            child: user.image.isEmpty ? Icon(Icons.person, size: 55.sp) : null,
          ),

          SizedBox(height: 16.h),

          Text(
            '${user.firstName} '
            '${user.lastName}',
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 5.h),

          Text('@${user.username}', style: TextStyle(fontSize: 14.sp)),

          SizedBox(height: 25.h),

          _profileItem(Icons.email_outlined, 'Email', user.email),

          _profileItem(Icons.person_outline, 'Gender', user.gender),

          _profileItem(Icons.badge_outlined, 'User ID', user.id.toString()),

          _profileItem(Icons.storage_outlined, 'Login Type', 'DummyJSON'),

          SizedBox(height: 25.h),

          _logoutButton(),
        ],
      ),
    );
  }

  Widget _firebaseProfile() {
    final user = _userService.currentFirebaseUser;

    if (user == null) {
      return Center(
        child: Text(
          'No Firebase user found',
          style: TextStyle(fontSize: 16.sp),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50),
                      ),
                      child: CircleAvatar(
                        radius: 55.r,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        backgroundImage: _profileImage.isNotEmpty
                            ? FileImage(File(_profileImage))
                            : null,
                        child: _profileImage.isEmpty
                            ? Icon(Icons.person, size: 55.sp)
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: const Color(0xFFF57C00),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _pickProfileImage,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(9.r),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 19.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                Text(
                  user.displayName ?? 'Firebase User',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4.h),

                Text(
                  user.email ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 12.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA000).withAlpha(25),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: Color(0xFFF57C00),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'Firebase Account',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF57C00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Account Information',
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 12.h),

          _profileItem(
            Icons.alternate_email,
            'Username',
            user.displayName ?? '',
          ),

          _profileItem(Icons.email_outlined, 'Email Address', user.email ?? ''),
          _profileItem(Icons.badge_outlined, 'Firebase UID', user.uid),
          _profileItem(Icons.local_fire_department, 'Login Type', 'Firebase'),

          SizedBox(height: 16.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Account Settings',
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUpdateUsername,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Update Username'),
            ),
          ),

          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showChangePassword,
              icon: const Icon(Icons.lock_reset),
              label: const Text('Change Password'),
            ),
          ),

          SizedBox(height: 10.h),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showDeleteAccount,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Account'),
            ),
          ),

          SizedBox(height: 20.h),

          _logoutButton(),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Log Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF57C00),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(110),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withAlpha(25),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: const Color(0xFF4CAF50)),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? 'Not available' : value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
