import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart' as user_model;
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  String _profileImagePath = '';
  String _profileImageUrl = '';
  String _loginType = '';

  bool _isLoading = true;

  user_model.User? _dummyUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _profileImagePath = '';
        _profileImageUrl = '';
        _dummyUser = null;
      });
    }

    try {
      final loginType = await _userService.getLoginType();

      final localImagePath = await _userService.getProfileImage();

      String imageUrl = '';
      user_model.User? dummyUser;

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (loginType == 'firebase' && firebaseUser != null) {
        final document = await FirebaseFirestore.instance
            .collection('Users')
            .doc(firebaseUser.uid)
            .get();

        imageUrl =
            document.data()?['image']?.toString() ??
            firebaseUser.photoURL ??
            '';
      }

      if (loginType == 'dummyjson') {
        dummyUser = await _userService.getUser();

        if (localImagePath.isEmpty) {
          imageUrl = dummyUser.image;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _loginType = loginType;
        _dummyUser = dummyUser;
        _profileImagePath = localImagePath;
        _profileImageUrl = imageUrl;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load profile: $error')));
    }
  }

  ImageProvider? get _profileImageProvider {
    if (_profileImagePath.isNotEmpty) {
      final imageFile = File(_profileImagePath);

      if (imageFile.existsSync()) {
        return FileImage(imageFile);
      }
    }

    if (_profileImageUrl.isNotEmpty) {
      return NetworkImage(_profileImageUrl);
    }

    return null;
  }

  Future<void> _showPhotoOptions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                subtitle: const Text('Visible only on this device'),
                onTap: () {
                  Navigator.pop(sheetContext, 'local');
                },
              ),
              if (_loginType == 'firebase')
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Use image URL'),
                  subtitle: const Text('Visible on profile and chat'),
                  onTap: () {
                    Navigator.pop(sheetContext, 'url');
                  },
                ),
              if (_profileImagePath.isNotEmpty || _profileImageUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Remove photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext, 'remove');
                  },
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'local') {
      await _pickLocalPhoto();
    } else if (action == 'url') {
      await _showImageUrlDialog();
    } else if (action == 'remove') {
      await _removeProfilePhoto();
    }
  }

  Future<void> _pickLocalPhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (image == null || !mounted) {
        return;
      }

      await _userService.saveProfileImage(image.path);

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (_loginType == 'firebase' && firebaseUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(firebaseUser.uid)
            .set({'image': ''}, SetOptions(merge: true));

        await firebaseUser.updatePhotoURL(null);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = image.path;
        _profileImageUrl = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local profile photo updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to select photo: $error')));
    }
  }

  Future<void> _showImageUrlDialog() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    final controller = TextEditingController(text: _profileImageUrl);

    final imageUrl = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Use Image URL'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/photo.jpg',
              prefixIcon: Icon(Icons.link),
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
              onPressed: () {
                final value = controller.text.trim();

                final uri = Uri.tryParse(value);

                final validUrl =
                    uri != null &&
                    (uri.scheme == 'http' || uri.scheme == 'https');

                if (!validUrl) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Enter a valid image URL.')),
                  );

                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Use Photo'),
            ),
          ],
        );
      },
    );

    if (imageUrl == null || !mounted) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser.uid)
          .set({'image': imageUrl}, SetOptions(merge: true));

      await firebaseUser.updatePhotoURL(imageUrl);

      await _userService.saveProfileImage('');

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = '';
        _profileImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Online profile photo updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update photo: $error')));
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      await _userService.saveProfileImage('');

      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (_loginType == 'firebase' && firebaseUser != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(firebaseUser.uid)
            .set({'image': ''}, SetOptions(merge: true));

        await firebaseUser.updatePhotoURL(null);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImagePath = '';
        _profileImageUrl = '';

        if (_loginType == 'dummyjson' && _dummyUser != null) {
          _profileImageUrl = _dummyUser!.image;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo removed.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to remove photo: $error')));
    }
  }

  Future<void> _showUpdateUsername() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      return;
    }

    final controller = TextEditingController(
      text: firebaseUser.displayName ?? '',
    );

    final newUsername = await showDialog<String>(
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
              onPressed: () {
                final username = controller.text.trim();

                if (username.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, username);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (newUsername == null || !mounted) {
      return;
    }

    try {
      await _userService.updateUsername(username: newUsername);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser.uid)
          .set({'username': newUsername}, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username updated.')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $error')));
    }
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least '
          '8 characters';
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
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    TextField(
                      controller: newController,
                      obscureText: obscureNew,
                      enabled: !isChanging,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Example: User123!',
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isChanging
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
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
                            _showDialogMessage(
                              dialogContext,
                              'Enter your current '
                              'password.',
                            );

                            return;
                          }

                          final passwordError = _validatePassword(newPassword);

                          if (passwordError != null) {
                            _showDialogMessage(dialogContext, passwordError);

                            return;
                          }

                          if (currentPassword == newPassword) {
                            _showDialogMessage(
                              dialogContext,
                              'The new password must '
                              'be different.',
                            );

                            return;
                          }

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

                            Navigator.pop(dialogContext);

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password updated.'),
                              ),
                            );
                          } catch (error) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              isChanging = false;
                            });

                            _showDialogMessage(
                              dialogContext,
                              _passwordErrorMessage(error),
                            );
                          }
                        },
                  child: isChanging
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDialogMessage(BuildContext dialogContext, String message) {
    ScaffoldMessenger.of(
      dialogContext,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _passwordErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('invalid-credential') ||
        message.contains('wrong-password')) {
      return 'Your current password is incorrect.';
    }

    if (message.contains('weak-password')) {
      return 'Your new password is too weak.';
    }

    if (message.contains('requires-recent-login')) {
      return 'Please sign in again before '
          'changing your password.';
    }

    return 'Unable to change password.';
  }

  Future<void> _showDeleteAccount() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null || firebaseUser.email == null) {
      return;
    }

    final controller = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This action cannot be undone.'),
              SizedBox(height: 15.h),
              TextField(
                controller: controller,
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
              onPressed: () {
                if (controller.text.isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (password == null || !mounted) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(firebaseUser.uid)
          .delete();

      await _userService.deleteAccount(
        email: firebaseUser.email!,
        password: password,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFF57C00)),
              SizedBox(width: 10),
              Text('Confirm Logout'),
            ],
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      if (_loginType == 'firebase') {
        await _userService.signOut();
      } else {
        await _userService.logoutUser();
      }

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loginType == 'firebase') {
      return _firebaseProfile();
    }

    if (_loginType == 'dummyjson' && _dummyUser != null) {
      return _dummyJsonProfile(_dummyUser!);
    }

    return Center(
      child: Text('No user data found', style: TextStyle(fontSize: 16.sp)),
    );
  }

  Widget _profileAvatar() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 55.r,
            backgroundColor: Theme.of(context).colorScheme.surface,
            backgroundImage: _profileImageProvider,
            child: _profileImageProvider == null
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
              onTap: _showPhotoOptions,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(9.r),
                child: Icon(Icons.edit, size: 19.sp, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _firebaseProfile() {
    final user = _userService.currentFirebaseUser;

    if (user == null) {
      return const Center(child: Text('No Firebase user found'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _profileHeader(
            name: user.displayName ?? 'Firebase User',
            email: user.email ?? '',
            accountType: 'Firebase Account',
          ),
          SizedBox(height: 24.h),
          _sectionTitle('Account Information'),
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
          _sectionTitle('Account Settings'),
          SizedBox(height: 12.h),
          _fullButton(
            icon: Icons.edit_outlined,
            text: 'Update Username',
            onPressed: _showUpdateUsername,
          ),
          SizedBox(height: 10.h),
          _fullButton(
            icon: Icons.lock_reset,
            text: 'Change Password',
            onPressed: _showChangePassword,
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

  Widget _dummyJsonProfile(user_model.User user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _profileHeader(
            name: '${user.firstName} ${user.lastName}',
            email: user.email,
            accountType: 'DummyJSON Account',
          ),
          SizedBox(height: 24.h),
          _sectionTitle('Account Information'),
          SizedBox(height: 12.h),
          _profileItem(Icons.alternate_email, 'Username', user.username),
          _profileItem(Icons.email_outlined, 'Email Address', user.email),
          _profileItem(Icons.person_outline, 'Gender', user.gender),
          _profileItem(Icons.badge_outlined, 'User ID', user.id.toString()),
          _profileItem(Icons.storage_outlined, 'Login Type', 'DummyJSON'),
          SizedBox(height: 20.h),
          _logoutButton(),
        ],
      ),
    );
  }

  Widget _profileHeader({
    required String name,
    required String email,
    required String accountType,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        children: [
          _profileAvatar(),
          SizedBox(height: 16.h),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA000).withAlpha(25),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              accountType,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF57C00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _fullButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: _confirmLogout,
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
