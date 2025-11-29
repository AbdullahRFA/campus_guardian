import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String description;
  final String speakerId;
  final String speakerName;
  final String thumbnailUrl;
  final Timestamp createdAt;
  final List<String> likes;

  const Post({
    required this.id,
    required this.title,
    required this.description,
    required this.speakerId,
    required this.speakerName,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.likes,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // FIX: Check for 'thumbnailUrl', but fall back to 'imageUrl' or 'image'
    // if the new key doesn't exist.
    String imageLink = data['thumbnailUrl'] ?? data['imageUrl'] ?? data['image'] ?? '';

    return Post(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      speakerId: data['speakerId'] ?? '',
      speakerName: data['speakerName'] ?? 'Unknown Author',
      thumbnailUrl: imageLink, // Use the resolved link
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }
}