import 'package:flutter/material.dart';
import '../models/skill_request.dart';

class RequestCard extends StatelessWidget {
  final SkillRequest request;
  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // We'll navigate to a detail/offer help screen later
          print('Tapped on request: ${request.title}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Posted by: ${request.requesterName}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8.0,
                    children: request.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                  Chip(
                    label: Text('${request.creditsOffered} Wisdom Credits', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.amber[100],
                    avatar: Icon(Icons.star, color: Colors.amber[800]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}