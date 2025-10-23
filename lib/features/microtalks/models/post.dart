import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final String speakerId; // The ID of the user who created the post
  final String speakerName;
  final String thumbnailUrl;
  final Timestamp createdAt;
  final List<String> likes;

  const Post({
    required this.id,
    required this.title,
    required this.description,
    required this.speakerId, // Add to constructor
    required this.speakerName,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.likes,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      speakerId: data['speakerId'] ?? '', // Get speakerId from Firestore
      speakerName: data['speakerName'] ?? 'Unknown Author',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }
}