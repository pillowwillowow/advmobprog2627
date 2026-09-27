import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  String _loginType = '';
  String _currentDummyEmail = '';

  int _currentDummyUserId = 0;

  bool _isLoading = true;

  List<Map<String, dynamic>> _dummyUsers = [];

  User? get _currentFirebaseUser {
    return FirebaseAuth.instance.currentUser;
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final loginType = await _userService.getLoginType();

      if (loginType == 'dummyjson') {
        final userData = await _userService.getUserData();

        final response = await http.get(Uri.parse('$host/users?limit=0'));

        if (response.statusCode != 200) {
          throw Exception('Unable to load DummyJSON users.');
        }

        final body = jsonDecode(response.body);

        final users = (body['users'] as List<dynamic>? ?? [])
            .map((user) => Map<String, dynamic>.from(user as Map))
            .toList();

        if (!mounted) {
          return;
        }

        setState(() {
          _loginType = loginType;
          _currentDummyUserId = userData['id'] as int? ?? 0;

          _currentDummyEmail = userData['email']?.toString() ?? '';

          _dummyUsers = users;
          _isLoading = false;
        });

        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _loginType = loginType;
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
      ).showSnackBar(SnackBar(content: Text('Unable to load chats: $error')));
    }
  }

  bool _matchesSearch(Map<String, dynamic> user) {
    if (_searchText.isEmpty) {
      return true;
    }

    final firstName = user['firstName']?.toString() ?? '';

    final lastName = user['lastName']?.toString() ?? '';

    final username = user['username']?.toString() ?? '';

    final email = user['email']?.toString() ?? '';

    final query = _searchText.toLowerCase();

    return firstName.toLowerCase().contains(query) ||
        lastName.toLowerCase().contains(query) ||
        username.toLowerCase().contains(query) ||
        email.toLowerCase().contains(query) ||
        '$firstName $lastName'.toLowerCase().contains(query);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchText = '';
    });
  }

//Enhancement 2: Chat List – Search Functionality
  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by name or email',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Widget _userAvatar(String image, String firstName) {
    return CircleAvatar(
      radius: 25.r,
      backgroundColor: const Color.fromARGB(255, 20, 107, 3),
      backgroundImage: image.isEmpty ? null : NetworkImage(image),
      onBackgroundImageError: image.isEmpty ? null : (_, _) {},
      child: image.isEmpty
          ? Text(
              firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _userTile({
    required Map<String, dynamic> user,
    required bool isDummyChat,
    required String currentUserEmail,
  }) {
    final firstName = user['firstName']?.toString() ?? 'Unknown';

    final lastName = user['lastName']?.toString() ?? '';

    final email = user['email']?.toString() ?? 'No email';

    final image = user['image']?.toString() ?? '';

    final fullName = '$firstName $lastName'.trim();

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      leading: _userAvatar(image, firstName),
      title: Text(
        fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        isDummyChat ? 'Tap to start a mock chat' : email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return ChatDetailScreen(
                currentUserEmail: currentUserEmail,
                tappedUser: user,
                isDummyChat: isDummyChat,
              );
            },
          ),
        );
      },
    );
  }
  Widget _dummyJsonChats() {
    final users = _dummyUsers
        .where((user) {
          final userId = user['id'] as int? ?? 0;

          return userId != _currentDummyUserId;
        })
        .where(_matchesSearch)
        .toList();

    if (users.isEmpty) {
      return Center(
        child: Text(
          _searchText.isEmpty
              ? 'No other users found.'
              : 'No matching users found.',
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(25),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DummyJSON chats are for '
                  'UI demonstration only.',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = users[index];

              return _userTile(
                user: {...user, 'uid': 'dummy_${user['id']}'},
                isDummyChat: true,
                currentUserEmail: _currentDummyEmail,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _firebaseChats() {
    final currentUser = _currentFirebaseUser;

    if (currentUser == null) {
      return const Center(child: Text('Please sign in to use chat.'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allUsers = snapshot.data ?? [];

      // Enhancement 1: Chat List – User Display with DummyJSON
        final users = allUsers
            .where((user) {
              final uid = user['uid']?.toString() ?? '';

              final email = user['email']?.toString() ?? '';

              return uid != currentUser.uid &&
                  email.toLowerCase() !=
                      (currentUser.email ?? '').toLowerCase();
            })
            .where(_matchesSearch)
            .toList();

        if (users.isEmpty) {
          return Center(
            child: Text(
              _searchText.isEmpty
                  ? 'No other users found.'
                  : 'No matching users found.',
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: users.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _userTile(
              user: users[index],
              isDummyChat: false,
              currentUserEmail: currentUser.email ?? '',
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _searchBar(),
        Expanded(
          child: _loginType == 'dummyjson'
              ? _dummyJsonChats()
              : _firebaseChats(),
        ),
      ],
    );
  }
}
