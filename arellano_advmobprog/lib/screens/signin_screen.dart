import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _useFirebase = false;

  static const Color green = Color(0xFF4CAF50);

  static const Color darkGreen = Color(0xFF2E7D32);

  static const Color orange = Color(0xFFF57C00);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_useFirebase) {
        await _userService.signIn(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _userService.loginUser(
          _usernameController.text.trim(),
          _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: green),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(90),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(80),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 32.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 105.w,
                    height: 105.w,
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: Image.asset(
                        'assets/icons/nuicon.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 26.h),

                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  'Sign in to continue shopping',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 28.h),

                Text(
                  'Sign in using',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 10.h),

                Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  //Enhancement 2: Dummy JSON vs Firebase Auth
                  // • DummyJSON: API call (https://dummyjson.com/auth/login).
                  // • Firebase: Use FirebaseAuth SDK, token refresh, security rules.
                  // • UI: Create user interface for signup_screen under the screen folder that requires the following
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('DummyJSON'),
                        icon: Icon(Icons.storage_rounded),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Firebase'),
                        icon: Icon(Icons.local_fire_department_rounded),
                      ),
                    ],
                    selected: {_useFirebase},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      setState(() {
                        _useFirebase = selection.first;

                        _usernameController.clear();

                        _passwordController.clear();
                      });
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                TextFormField(
                  controller: _usernameController,
                  keyboardType: _useFirebase
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: _useFirebase ? 'Email Address' : 'Username',
                    icon: _useFirebase
                        ? Icons.email_outlined
                        : Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _useFirebase
                          ? 'Enter your email'
                          : 'Enter your username';
                    }

                    if (_useFirebase && !value.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 16.h),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _login();
                    }
                  },
                  decoration: _inputDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                SizedBox(
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: darkGreen.withAlpha(120),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _useFirebase
                                    ? Icons.local_fire_department_rounded
                                    : Icons.login_rounded,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _useFirebase
                                    ? 'Sign In with Firebase'
                                    : 'Sign In',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                if (_useFirebase) ...[
                  SizedBox(height: 22.h),

                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/signup');
                              },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 16.h),

                Center(
                  child: Text(
                    _useFirebase
                        ? 'Firebase Authentication'
                        : 'DummyJSON Authentication',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
