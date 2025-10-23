// lib/features/microtalks/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description; // The main content of the post
  final String speakerName;
  final String thumbnailUrl;
  final Timestamp createdAt;

  const Post({
    required this.id,
    required this.title,
    required this.description,
    required this.speakerName,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      speakerName: data['speakerName'] ?? 'Unknown Author',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}