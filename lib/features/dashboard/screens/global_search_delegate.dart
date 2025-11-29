import 'package:cloud_firestore/cloud_firestore.dart'; // Import this for QuerySnapshot
import 'package:campus_guardian/features/mentorship/models/mentor.dart';
import 'package:campus_guardian/features/microtalks/models/post.dart';
import 'package:campus_guardian/features/skill_exchange/models/exchange_post.dart';
import 'package:campus_guardian/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GlobalSearchDelegate extends SearchDelegate {
  final DatabaseService _dbService = DatabaseService();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for mentors, posts, or skills...'));
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        _dbService.getAllMentors(),
        _dbService.getAllPosts(),
        _dbService.getAllExchangePosts(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data found.'));
        }

        // FIX: Explicitly cast dynamic results to QuerySnapshot.
        // This breaks the "dynamic" chain immediately.
        final QuerySnapshot mentorSnapshot = snapshot.data![0] as QuerySnapshot;
        final QuerySnapshot postSnapshot = snapshot.data![1] as QuerySnapshot;
        final QuerySnapshot exchangeSnapshot = snapshot.data![2] as QuerySnapshot;

        final lowerQuery = query.toLowerCase();

        // 1. Filter Mentors (Type Safe)
        final mentors = mentorSnapshot.docs
            .map<Mentor>((doc) => Mentor.fromFirestore(doc)) // Typed map
            .where((m) {
          final nameMatch = m.name.toLowerCase().contains(lowerQuery);
          final titleMatch = m.title.toLowerCase().contains(lowerQuery);
          final skillMatch = m.expertise.any((e) => e.toLowerCase().contains(lowerQuery));
          return nameMatch || titleMatch || skillMatch;
        })
            .toList();

        // 2. Filter Knowledge Hub Posts (Type Safe)
        final posts = postSnapshot.docs
            .map<Post>((doc) => Post.fromFirestore(doc)) // Typed map
            .where((p) {
          return p.title.toLowerCase().contains(lowerQuery);
        })
            .toList();

        // 3. Filter Skill Exchange (Type Safe)
        final exchanges = exchangeSnapshot.docs
            .map<ExchangePost>((doc) => ExchangePost.fromFirestore(doc)) // Typed map
            .where((e) {
          final titleMatch = e.offerTitle.toLowerCase().contains(lowerQuery);
          final tagMatch = e.offerTags.any((t) => t.toLowerCase().contains(lowerQuery));
          return titleMatch || tagMatch;
        })
            .toList();

        if (mentors.isEmpty && posts.isEmpty && exchanges.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (mentors.isNotEmpty) ...[
              _buildHeader('Mentors'),
              ...mentors.map((m) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: m.profileImageUrl.isNotEmpty
                      ? NetworkImage(m.profileImageUrl)
                      : null,
                  child: m.profileImageUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(m.name),
                subtitle: Text(m.title),
                onTap: () => context.push('/app/profile/${m.id}'),
              )),
            ],
            if (posts.isNotEmpty) ...[
              _buildHeader('Knowledge Hub Posts'),
              ...posts.map((p) => ListTile(
                leading: const Icon(Icons.article, color: Colors.blue),
                title: Text(p.title),
                subtitle: Text('By ${p.speakerName}'),
                onTap: () => context.push('/app/posts/${p.id}', extra: p),
              )),
            ],
            if (exchanges.isNotEmpty) ...[
              _buildHeader('Skill Exchange'),
              ...exchanges.map((e) => ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.green),
                title: Text(e.offerTitle),
                subtitle: Text('Tags: ${e.offerTags.join(", ")}'),
                onTap: () => context.push('/app/skill-exchange'),
              )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}