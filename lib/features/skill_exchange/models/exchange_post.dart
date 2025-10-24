import 'package:cloud_firestore/cloud_firestore.dart';

class ExchangePost {
  final String id;
  final String offererId;
  final String offererName;
  final String status;
  final Timestamp createdAt;
  final String offerTitle;
  final String offerDescription;
  final List<String> offerTags;
  final String requestTitle;
  final String requestDescription;
  final List<String> requestTags;

  const ExchangePost({
    required this.id,
    required this.offererId,
    required this.offererName,
    required this.status,
    required this.createdAt,
    required this.offerTitle,
    required this.offerDescription,
    required this.offerTags,
    required this.requestTitle,
    required this.requestDescription,
    required this.requestTags,
  });

  factory ExchangePost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExchangePost(
      id: doc.id,
      offererId: data['offererId'] ?? '',
      offererName: data['offererName'] ?? '',
      status: data['status'] ?? 'open',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      offerTitle: data['offerTitle'] ?? '',
      offerDescription: data['offerDescription'] ?? '',
      offerTags: List<String>.from(data['offerTags'] ?? []),
      requestTitle: data['requestTitle'] ?? '',
      requestDescription: data['requestDescription'] ?? '',
      requestTags: List<String>.from(data['requestTags'] ?? []),
    );
  }
}