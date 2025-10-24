import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference sessionCollection = FirebaseFirestore.instance.collection('sessions');
  final CollectionReference postCollection = FirebaseFirestore.instance.collection('posts');
  // --- ADD THIS MISSING LINE ---
  final CollectionReference skillRequestCollection = FirebaseFirestore.instance.collection('skill_requests');

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

  Future<void> createSkillRequest({
    required String title,
    required String description,
    required List<String> tags,
    required int creditsOffered,
    required String requesterId,
    required String requesterName,
  }) async {
    await skillRequestCollection.add({
      'title': title,
      'description': description,
      'tags': tags,
      'creditsOffered': creditsOffered,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'status': 'open', // Default status for a new request
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}