// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import '../models/post.dart';
//
// class TalkPlayerScreen extends StatefulWidget {
//   final Talk talk;
//   const TalkPlayerScreen({super.key, required this.talk});
//
//   @override
//   State<TalkPlayerScreen> createState() => _TalkPlayerScreenState();
// }
//
// class _TalkPlayerScreenState extends State<TalkPlayerScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//
//   // We will use a dummy URL for now.
//   final String _audioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Listen to player state changes
//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = state == PlayerState.playing;
//         });
//       }
//     });
//
//     // Listen to audio duration
//     _audioPlayer.onDurationChanged.listen((newDuration) {
//       if (mounted) {
//         setState(() {
//           _duration = newDuration;
//         });
//       }
//     });
//
//     // Listen to audio position
//     _audioPlayer.onPositionChanged.listen((newPosition) {
//       if (mounted) {
//         setState(() {
//           _position = newPosition;
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.talk.title)),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 widget.talk.thumbnailUrl,
//                 height: 250,
//                 width: 250,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text(widget.talk.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
//             const SizedBox(height: 8),
//             Text(widget.talk.speakerName, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
//             const SizedBox(height: 32),
//             Slider(
//               min: 0,
//               max: _duration.inSeconds.toDouble(),
//               value: _position.inSeconds.toDouble(),
//               onChanged: (value) async {
//                 final position = Duration(seconds: value.toInt());
//                 await _audioPlayer.seek(position);
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(_formatDuration(_position)),
//                   Text(_formatDuration(_duration)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             CircleAvatar(
//               radius: 35,
//               child: IconButton(
//                 icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//                 iconSize: 50,
//                 onPressed: () async {
//                   if (_isPlaying) {
//                     await _audioPlayer.pause();
//                   } else {
//                     // MODIFIED: Use the play() method to start the audio
//                     await _audioPlayer.play(UrlSource(_audioUrl));
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }