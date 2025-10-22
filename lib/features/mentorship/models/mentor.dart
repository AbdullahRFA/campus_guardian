import 'package:cloud_firestore/cloud_firestore.dart';

class Mentor {
  final String id;
  final String name;
  final String title;
  final String profileImageUrl;
  final List<String> expertise;

  const Mentor({
    required this.id,
    required this.name,
    required this.title,
    required this.profileImageUrl,
    required this.expertise,
  });

  // NEW: A factory constructor to create a Mentor from a Firestore document
  factory Mentor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Mentor(
      id: doc.id,
      name: data['fullName'] ?? 'No Name',
      title: data['mentorTitle'] ?? 'Mentor',
      profileImageUrl: data['profilePicUrl'] ?? '',
      expertise: List<String>.from(data['mentorExpertise'] ?? []),
    );
  }
}