import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$host/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      await saveUserData(data);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('loginType', 'dummyjson');

      return data;
    }

    throw Exception(response.body);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final user = User.fromJson(userData);

    await prefs.setInt('id', user.id);

    await prefs.setString('username', user.username);

    await prefs.setString('email', user.email);

    await prefs.setString('firstName', user.firstName);

    await prefs.setString('lastName', user.lastName);

    await prefs.setString('gender', user.gender);

    await prefs.setString('image', user.image);

    await prefs.setString('accessToken', user.accessToken);

    await prefs.setString('refreshToken', user.refreshToken);
  }

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('id');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('gender');
    await prefs.remove('image');

    await prefs.setString('loginType', 'firebase');

    await prefs.setString('email', credential.user?.email ?? email);

    await prefs.setString('username', credential.user?.displayName ?? '');

    return credential;
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'image': prefs.getString('image') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'age': prefs.getInt('age') ?? 0,
      'contactNo': prefs.getString('contactNo') ?? '',
      'loginType': prefs.getString('loginType') ?? '',
    };
  }

  Future<User> getUser() async {
    final userData = await getUserData();

    return User.fromJson(userData);
  }

  Future<String> getLoginType() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('loginType') ?? '';
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final loginType = prefs.getString('loginType') ?? '';

    if (loginType == 'firebase') {
      return _firebaseAuth.currentUser != null;
    }

    final accessToken = prefs.getString('accessToken') ?? '';

    return accessToken.isNotEmpty;
  }

  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();

    const sessionKeys = [
      'id',
      'username',
      'email',
      'firstName',
      'lastName',
      'gender',
      'image',
      'accessToken',
      'refreshToken',
      'age',
      'contactNo',
      'loginType',
    ];

    for (final key in sessionKeys) {
      await prefs.remove(key);
    }
  }

  Future<void> logoutUser() async {
    await _firebaseAuth.signOut();
    await _clearSessionData();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _clearSessionData();
  }

  // nhancement 1: UserService Functions
  // • Implement signIn, createAccount, signOut, updateUsername, deleteAccount, resetPasswordFromCurrentPassword.
  // • Add Logout button → clears session/token and redirects to login.
  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('loginType', 'firebase');

    return credential;
  }
  Future<void> updateUsername({required String username}) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No Firebase user is signed in.');
    }

    await user.updateDisplayName(username);

    await user.reload();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('No Firebase user is signed in.');
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);

    await user.delete();

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null || user.email == null) {
      throw Exception('No Firebase user is signed in.');
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    await user.updatePassword(newPassword);
  }

  Future<String> _getProfileImageKey() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = prefs.getString('loginType') ?? '';

    if (loginType == 'firebase') {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        return 'profileImage_firebase_${firebaseUser.uid}';
      }
    }

    if (loginType == 'dummyjson') {
      final userId = prefs.getInt('id') ?? 0;
      return 'profileImage_dummy_$userId';
    }

    return 'profileImage_guest';
  }

  Future<void> saveProfileImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getProfileImageKey();

    if (imagePath.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, imagePath);
    }
  }

  Future<String> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getProfileImageKey();

    return prefs.getString(key) ?? '';
  }
}
