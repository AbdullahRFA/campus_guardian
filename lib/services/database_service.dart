import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // --- Collection References ---
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference sessionCollection = FirebaseFirestore.instance.collection('sessions');
  final CollectionReference postCollection = FirebaseFirestore.instance.collection('posts');
  final CollectionReference exchangePostCollection = FirebaseFirestore.instance.collection('skill_exchange_posts');
  final CollectionReference privateChatCollection = FirebaseFirestore.instance.collection('private_chats');

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    await userCollection.doc(uid).set(userData, SetOptions(merge: true));
  }

  Future<void> bookSession({
    required String mentorId,
    required String menteeId,
    required String mentorName,
    required String menteeName,
    required String sessionTime,
    required String sessionTopic,
  }) async {
    await sessionCollection.add({
      'mentorId': mentorId,
      'menteeId': menteeId,
      'mentorName': mentorName,
      'menteeName': menteeName,
      'sessionTime': sessionTime,
      'sessionTopic': sessionTopic,
      'sessionDate': DateTime.now().toIso8601String().split('T').first,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'participants': [mentorId, menteeId],
    });
  }

  Future<void> updateSessionStatus(String sessionId, String newStatus) async {
    await sessionCollection.doc(sessionId).update({'status': newStatus});
  }

  Future<void> submitFeedback({
    required String sessionId,
    required int rating,
    required String feedback,
    required bool isUserTheMentor,
  }) async {
    if (isUserTheMentor) {
      await sessionCollection.doc(sessionId).update({
        'mentorRating': rating,
        'mentorFeedback': feedback,
      });
    } else {
      await sessionCollection.doc(sessionId).update({
        'menteeRating': rating,
        'menteeFeedback': feedback,
      });
    }
  }

  Future<void> createPost({
    required String title,
    required String description,
    required String thumbnailUrl,
    required String speakerId,
    required String speakerName,
    required String speakerTitle,
  }) async {
    await postCollection.add({
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'speakerId': speakerId,
      'speakerName': speakerName,
      'speakerTitle': speakerTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
    });
  }

  Future<void> togglePostLike(String postId, String userId) async {
    final postRef = postCollection.doc(postId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) {
        throw Exception("Post does not exist!");
      }
      final data = snapshot.data() as Map<String, dynamic>;
      List<String> likes = List<String>.from(data['likes'] ?? []);
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      transaction.update(postRef, {'likes': likes});
    });
  }

  Future<void> addComment({
    required String postId,
    required String text,
    required String commenterId,
    required String commenterName,
  }) async {
    if (text.trim().isEmpty) return;
    final commentCollection = postCollection.doc(postId).collection('comments');
    await commentCollection.add({
      'text': text,
      'commenterId': commenterId,
      'commenterName': commenterName,
      'createdAt': FieldValue.serverTimestamp(),
      'replies': [],
    });
  }

  Future<void> addReplyToComment({
    required String postId,
    required String commentId,
    required String text,
    required String replierId,
    required String replierName,
  }) async {
    if (text.trim().isEmpty) return;
    final commentRef = postCollection.doc(postId).collection('comments').doc(commentId);

    final replyData = {
      'text': text,
      'replierId': replierId,
      'replierName': replierName,
      'createdAt': Timestamp.now(),
    };

    await commentRef.update({
      'replies': FieldValue.arrayUnion([replyData])
    });
  }

  Future<void> createExchangePost({
    required String offererId,
    required String offererName,
    required String offerTitle,
    required String offerDescription,
    required List<String> offerTags,
    required String requestTitle,
    required String requestDescription,
    required List<String> requestTags,
  }) async {
    await exchangePostCollection.add({
      'offererId': offererId,
      'offererName': offererName,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'offerTitle': offerTitle,
      'offerDescription': offerDescription,
      'offerTags': offerTags,
      'requestTitle': requestTitle,
      'requestDescription': requestDescription,
      'requestTags': requestTags,
    });
  }

  // --- NEW: Method to update an existing skill exchange post ---
  Future<void> updateExchangePost({
    required String postId,
    required String offerTitle,
    required String offerDescription,
    required List<String> offerTags,
    required String requestTitle,
    required String requestDescription,
    required List<String> requestTags,
  }) async {
    await exchangePostCollection.doc(postId).update({
      'offerTitle': offerTitle,
      'offerDescription': offerDescription,
      'offerTags': offerTags,
      'requestTitle': requestTitle,
      'requestDescription': requestDescription,
      'requestTags': requestTags,
    });
  }

  // --- NEW: Method to delete a skill exchange post ---
  Future<void> deleteExchangePost(String postId) async {
    await exchangePostCollection.doc(postId).delete();
  }

  // In services/database_service.dart

// ... (keep existing collection references)

// --- NEW & IMPROVED: Method to send a message and manage chat links ---
  Future<void> sendPrivateMessage({
    required String chatId,
    required String text,
    required String senderId,
    required String receiverId,
  }) async {
    if (text.trim().isEmpty) return;

    // 1. Send the actual message
    final messageCollection = privateChatCollection.doc(chatId).collection('messages');
    await messageCollection.add({
      'text': text,
      'senderId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Get user names for the chat link metadata
    final senderDoc = await userCollection.doc(senderId).get();
    final senderName = (senderDoc.data() as Map<String, dynamic>)['fullName'] ?? 'A User';
    final receiverDoc = await userCollection.doc(receiverId).get();
    final receiverName = (receiverDoc.data() as Map<String, dynamic>)['fullName'] ?? 'Another User';

    // 3. Create/update the chat link for both users so it appears in their inbox
    final timestamp = FieldValue.serverTimestamp();

    // Set the link for the sender
    await userCollection
        .doc(senderId)
        .collection('user_chats')
        .doc(receiverId)
        .set({
      'chatId': chatId,
      'otherUserId': receiverId,
      'otherUserName': receiverName,
      'lastActivity': timestamp,
    }, SetOptions(merge: true)); // Use merge to create or update

    // Set the link for the receiver
    await userCollection
        .doc(receiverId)
        .collection('user_chats')
        .doc(senderId)
        .set({
      'chatId': chatId,
      'otherUserId': senderId,
      'otherUserName': senderName,
      'lastActivity': timestamp,
    }, SetOptions(merge: true));
  }
}