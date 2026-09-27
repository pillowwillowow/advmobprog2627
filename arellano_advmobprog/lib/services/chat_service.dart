import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>>
  getUsersStream() {
    return _firestore
        .collection('Users')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            final user = document.data();

            return {
              ...user,
              'documentId': document.id,
            };
          }).toList();
        });
  }

  String getChatRoomId(
    String firstUserId,
    String secondUserId,
  ) {
    final ids = [firstUserId, secondUserId];

    ids.sort();

    return ids.join('_');
  }

  Future<void> sendMessage(
    String receiverId,
    String message,
  ) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No authenticated user found.');
    }

    final currentUserId = currentUser.uid;
    final currentUserEmail = currentUser.email ?? '';
    final timestamp = Timestamp.now();

    final newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      status: 'sent',
    );

    final chatRoomId = getChatRoomId(
      currentUserId,
      receiverId,
    );

    final messageDocument = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    await messageDocument.update({
      'status': 'delivered',
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
  getMessage(
    String userId,
    String otherUserId,
  ) {
    final chatRoomId = getChatRoomId(
      userId,
      otherUserId,
    );

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots();
  }

  Future<String?> getUidByEmail(
    String email,
  ) async {
    final query = await _firestore
        .collection('Users')
        .where(
          'email',
          isEqualTo: email,
        )
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return query.docs.first
        .data()['uid']
        ?.toString();
  }

  Future<void> markMessagesAsSeen(
    String currentUserId,
    String otherUserId,
  ) async {
    final chatRoomId = getChatRoomId(
      currentUserId,
      otherUserId,
    );

    final messages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    bool hasUpdates = false;

    for (final document in messages.docs) {
      final data = document.data();

      final receiverId =
          data['receiverId']?.toString() ?? '';

      final status =
          data['status']?.toString() ?? 'sent';

      if (receiverId == currentUserId &&
          status != 'seen') {
        batch.update(document.reference, {
          'status': 'seen',
        });

        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }
}