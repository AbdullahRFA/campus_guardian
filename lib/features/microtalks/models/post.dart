// lib/features/microtalks/models/post.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final String speakerName;
  final String thumbnailUrl;
  final Timestamp createdAt;
  final List<String> likes; // NEW: List of user IDs who liked the post

  const Post({
    required this.id,
    required this.title,
    required this.description,
    required this.speakerName,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.likes, // NEW: Add to constructor
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
      likes: List<String>.from(data['likes'] ?? []), // NEW: Get likes from Firestore
    );
  }
}