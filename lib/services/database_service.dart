import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference sessionCollection = FirebaseFirestore.instance.collection('sessions');

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    await userCollection.doc(uid).set(userData, SetOptions(merge: true));
  }

  Future<void> bookSession({
    required String mentorId,
    required String menteeId,
    required String mentorName,
    required String menteeName,
    required String sessionTime,
  }) async {
    await sessionCollection.add({
      'mentorId': mentorId,
      'menteeId': menteeId,
      'mentorName': mentorName,
      'menteeName': menteeName,
      'sessionTime': sessionTime,
      'sessionDate': DateTime.now().toIso8601String().split('T').first,
      // MODIFIED: Initial status is now "pending"
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'participants': [mentorId, menteeId],
    });
  }

  // NEW: Method to update a session's status
  Future<void> updateSessionStatus(String sessionId, String newStatus) async {
    await sessionCollection.doc(sessionId).update({'status': newStatus});
  }
}