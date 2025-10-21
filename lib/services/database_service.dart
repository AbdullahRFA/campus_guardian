import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // Reference to the 'users' collection in Firestore
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // Method to create or update user data
  Future<void> updateUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'profilePicUrl': '', // Will be updated later
      'department': '',   // Example field
      'batch': '',        // Example field
    });
  }

  // Add this method inside your DatabaseService class
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    return await userCollection.doc(uid).update(userData);
  }
}