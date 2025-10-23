import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('My Posts')),
          body: const Center(child: Text('Please log in to see your posts.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Published Posts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('speakerId', isEqualTo: _userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // This will now print the full error to your console
            print("--- MY POSTS SCREEN ERROR ---");
            print(snapshot.error);
            print("-----------------------------");
            return Center(child: Text('Error loading posts: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You haven\'t published any posts yet.'));
          }

          final posts =
          snapshot.data!.docs.map((doc) => Post.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}