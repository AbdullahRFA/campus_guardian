import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference sessionCollection = FirebaseFirestore.instance.collection('sessions');

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    await userCollection.doc(uid).set(userData, SetOptions(merge: true));
  }

  // Inside the DatabaseService class
  Future<void> bookSession({
    required String mentorId,
    required String menteeId,
    required String mentorName,
    required String menteeName,
    required String sessionTime,
    required String sessionTopic, // NEW: Add the topic parameter
  }) async {
    await sessionCollection.add({
      'mentorId': mentorId,
      'menteeId': menteeId,
      'mentorName': mentorName,
      'menteeName': menteeName,
      'sessionTime': sessionTime,
      'sessionTopic': sessionTopic, // NEW: Save the topic
      'sessionDate': DateTime.now().toIso8601String().split('T').first,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'participants': [mentorId, menteeId],
    });
  }

  // NEW: Method to update a session's status
  Future<void> updateSessionStatus(String sessionId, String newStatus) async {
    await sessionCollection.doc(sessionId).update({'status': newStatus});
  }

  // Add this method inside your DatabaseService class
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
}