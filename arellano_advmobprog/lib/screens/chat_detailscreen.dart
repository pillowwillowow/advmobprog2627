import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../services/chat_service.dart';
import '../widgets/custom_text.dart';

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;
  final bool isDummyChat;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
    this.isDummyChat = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();

  final TextEditingController _messageController = TextEditingController();

  final FocusNode _messageFocus = FocusNode();

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _dummyMessages = [];

  bool _isSending = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _messagesStream;

  String get _currentUserId {
    if (widget.isDummyChat) {
      return 'dummy_current';
    }

    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String get _tappedUserId {
    return widget.tappedUser['uid']?.toString() ?? '';
  }

  String get _tappedUserName {
    final firstName = widget.tappedUser['firstName']?.toString() ?? 'Unknown';

    final lastName = widget.tappedUser['lastName']?.toString() ?? '';

    return '$firstName $lastName'.trim();
  }

  String get _tappedUserImage {
    return widget.tappedUser['image']?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();

    if (!widget.isDummyChat) {
      _messagesStream = _chatService.getMessage(_currentUserId, _tappedUserId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markMessagesAsSeen();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsSeen() async {
    if (widget.isDummyChat || _currentUserId.isEmpty || _tappedUserId.isEmpty) {
      return;
    }

    await _chatService.markMessagesAsSeen(_currentUserId, _tappedUserId);
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    if (widget.isDummyChat) {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) {
        return;
      }

      setState(() {
        _dummyMessages.add({
          'id': DateTime.now().microsecondsSinceEpoch.toString(),
          'message': text,
          'isMe': true,
          'status': 'seen',
          'timestamp': DateTime.now(),
        });

        _messageController.clear();
        _isSending = false;
      });

      _messageFocus.requestFocus();
      return;
    }

    if (_tappedUserId.isEmpty) {
      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receiver user ID is missing.')),
      );

      return;
    }

    try {
      await _chatService.sendMessage(_tappedUserId, text);

      _messageController.clear();
      _messageFocus.requestFocus();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDummyChat && _currentUserId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please sign in before using chat.')),
      );
    }

    if (_tappedUserId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('The selected user has no ID.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10.w,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19.r,
              backgroundColor: const Color.fromARGB(255, 20, 107, 3),
              backgroundImage: _tappedUserImage.isNotEmpty
                  ? NetworkImage(_tappedUserImage)
                  : null,
              onBackgroundImageError: _tappedUserImage.isEmpty
                  ? null
                  : (_, _) {},
              child: _tappedUserImage.isEmpty
                  ? Text(
                      _tappedUserName.isEmpty
                          ? '?'
                          : _tappedUserName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: _tappedUserName,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomText(
                    text: widget.isDummyChat ? 'Mock conversation' : 'Online',
                    fontSize: 11.sp,
                    color: widget.isDummyChat ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (widget.isDummyChat)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              color: Colors.orange.withAlpha(25),
              child: const Text(
                'Messages in this conversation '
                'are not saved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),
            ),
          Expanded(
            child: widget.isDummyChat
                ? _buildDummyMessages()
                : _buildFirebaseMessages(),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildDummyMessages() {
    if (_dummyMessages.isEmpty) {
      return _emptyConversation();
    }

    final messages = _dummyMessages.reversed.toList();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        return _animatedMessageBubble(
          message['id'].toString(),
          message['message'].toString(),
          message['status'].toString(),
          message['isMe'] as bool? ?? true,
          message['timestamp'] as DateTime,
        );
      },
    );
  }

  Widget _buildFirebaseMessages() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages: '
              '${snapshot.error}',
            ),
          );
        }

        final documents = snapshot.data?.docs ?? [];

        if (documents.isEmpty) {
          return _emptyConversation();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _markMessagesAsSeen();
        });

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];

            final data = document.data();

            final timestamp = data['timestamp'] as Timestamp?;

            return _animatedMessageBubble(
              document.id,
              data['message']?.toString() ?? '',
              data['status']?.toString() ?? 'sent',
              data['senderId']?.toString() == _currentUserId,
              timestamp?.toDate() ?? DateTime.now(),
            );
          },
        );
      },
    );
  }

  Widget _emptyConversation() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 65.sp, color: Colors.grey),
            SizedBox(height: 15.h),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.h),
            Text(
              'Send a message to start '
              'the conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

// Enhancement 3: Chat Detail Screen – Redesign
  Widget _animatedMessageBubble(
    String messageId,
    String message,
    String status,
    bool isMe,
    DateTime timestamp,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final formattedTime = DateFormat('h:mm a').format(timestamp);

    final bubbleColor = isMe
        ? const Color.fromARGB(255, 73, 173, 77)
        : isDark
        ? const Color(0xFF263328)
        : const Color(0xFFFFE0B2);

    final messageColor = isMe
        ? Colors.white
        : isDark
        ? Colors.white
        : const Color(0xFF3E2723);

    final timeColor = isMe
        ? Colors.white70
        : isDark
        ? Colors.white60
        : Colors.black54;
        
    return TweenAnimationBuilder<double>(
      key: ValueKey(messageId),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(isMe ? 20 * (1 - value) : -20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r),
              topRight: Radius.circular(15.r),
              bottomLeft: isMe ? Radius.circular(15.r) : Radius.zero,
              bottomRight: isMe ? Radius.zero : Radius.circular(15.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: message.isEmpty ? '[empty]' : message,
                fontSize: 15.sp,
                fontWeight: FontWeight.normal,
                color: messageColor,
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: TextStyle(color: timeColor, fontSize: 9.sp),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: TextStyle(color: Colors.white70, fontSize: 9.sp),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      status == 'sent' ? Icons.done : Icons.done_all,
                      size: 13.sp,
                      color: status == 'seen'
                          ? Colors.lightBlueAccent
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 5.h, 8.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocus,
                enabled: !_isSending,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) {
                  if (!_isSending) {
                    _send();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isSending
                  ? Padding(
                      key: const ValueKey('sending'),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Sending...',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : IconButton(
                      key: const ValueKey('send'),
                      onPressed: _send,
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
