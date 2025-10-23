import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  // --- NEW: Add reference to the sessions collection ---
  final CollectionReference sessionCollection = FirebaseFirestore.instance.collection('sessions');

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    return await userCollection.doc(uid).set(userData, SetOptions(merge: true));
  }

  // --- NEW: Method to book a new session ---
  Future<void> bookSession({
    required String mentorId,
    required String menteeId,
    required String mentorName,
    required String menteeName,
    required String sessionTime,
  }) async {
    return await sessionCollection.add({
      'mentorId': mentorId,
      'menteeId': menteeId,
      'mentorName': mentorName,
      'menteeName': menteeName,
      'sessionTime': sessionTime,
      'sessionDate': DateTime.now().toIso8601String().split('T').first, // Just the date part
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(), // Let Firestore handle the timestamp
    });
  }
}