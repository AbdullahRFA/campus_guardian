import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id; // NEW: Added session ID
  final String mentorName;
  final String menteeName;
  final String mentorId;
  final String menteeId;
  final String sessionTime;
  final String sessionDate;
  final String status;
  final String sessionTopic; // Add the topic
  final String? mentorFeedback;
  final int? mentorRating;
  final String? menteeFeedback;
  final int? menteeRating;

  Session({
    required this.id, // NEW
    required this.mentorName,
    required this.menteeName,
    required this.mentorId,
    required this.menteeId,
    required this.sessionTime,
    required this.sessionDate,
    required this.status,
    required this.sessionTopic,
    this.mentorFeedback,
    this.mentorRating,
    this.menteeFeedback,
    this.menteeRating,
  });

  factory Session.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Session(
      id: doc.id, // NEW: Get the document ID
      mentorName: data['mentorName'] ?? '',
      menteeName: data['menteeName'] ?? '',
      mentorId: data['mentorId'] ?? '',
      menteeId: data['menteeId'] ?? '',
      sessionTime: data['sessionTime'] ?? '',
      sessionDate: data['sessionDate'] ?? '',
      status: data['status'] ?? '',
      sessionTopic: data['sessionTopic'] ?? 'No Topic',
      mentorFeedback: data['mentorFeedback'],
      mentorRating: data['mentorRating'],
      menteeFeedback: data['menteeFeedback'],
      menteeRating: data['menteeRating'],
    );
  }
}