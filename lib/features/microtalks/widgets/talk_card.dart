import 'package.flutter/material.dart';
import '../models/talk.dart';

class TalkCard extends StatelessWidget {
  final Talk talk;
  const TalkCard({super.key, required this.talk});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple stays within the rounded corners
      child: InkWell(
        onTap: () {
          // We'll navigate to a player screen later
          print('Tapped on talk: ${talk.title}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with play icon
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  talk.thumbnailUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 60),
              ],
            ),
            // Talk details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    talk.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(talk.speakerName, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Icon(Icons.timer_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(talk.duration, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}