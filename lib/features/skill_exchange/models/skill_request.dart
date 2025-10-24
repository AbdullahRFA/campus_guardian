import 'package:cloud_firestore/cloud_firestore.dart';

class SkillRequest {
  final String id;
  final String title;
  final String description;
  final String requesterName;
  final int creditsOffered;
  final List<String> tags;

  const SkillRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.requesterName,
    required this.creditsOffered,
    required this.tags,
  });

  // --- ADD THIS FACTORY CONSTRUCTOR ---
  factory SkillRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SkillRequest(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      requesterName: data['requesterName'] ?? 'Unknown User',
      creditsOffered: data['creditsOffered'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}