import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference sessionCollection = FirebaseFirestore.instance.collection('sessions');

  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    // This method uses .set with merge, which is correct.
    await userCollection.doc(uid).set(userData, SetOptions(merge: true));
  }

  Future<void> bookSession({
    required String mentorId,
    required String menteeId,
    required String mentorName,
    required String menteeName,
    required String sessionTime,
  }) async {
    // FIXED: Removed the 'return' keyword.
    await sessionCollection.add({
      'mentorId': mentorId,
      'menteeId': menteeId,
      'mentorName': mentorName,
      'menteeName': menteeName,
      'sessionTime': sessionTime,
      'sessionDate': DateTime.now().toIso8601String().split('T').first,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}