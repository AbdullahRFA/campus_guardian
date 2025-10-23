import 'package:flutter/material.dart';
import '../models/talk.dart';
import '../widgets/talk_card.dart';

class MicroTalksScreen extends StatelessWidget {
  const MicroTalksScreen({super.key});

  // Dummy data for the talks
  final List<Talk> dummyTalks = const [
    const Talk(
      id: '1',
      title: 'Cracking the Technical Interview: A Guide for JU Students',
      speakerName: 'Ahsin Abid',
      duration: '15 min',
      thumbnailUrl: 'https://images.unsplash.com/photo-1556740758-90de374c12ad?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzNjUyOXwwfDF8c2VhcmNofDE0fHx0ZWNofGVufDB8fHx8MTY4MjYxMjYyNA&ixlib=rb-4.0.3&q=80&w=400',
    ),
    const Talk(
      id: '2',
      title: 'The Power of Algorithms in Modern AI',
      speakerName: 'Dr. Md. Ezharul Islam',
      duration: '22 min',
      thumbnailUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwzNjUyOXwwfDF8c2VhcmNofDEyfHxBSSUyMHRlY2hub2xvZ3l8ZW58MHx8fHwxNjgyNjEyNjY5&ixlib=rb-4.0.3&q=80&w=400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Micro-Talks')),
      body: ListView.builder(
        itemCount: dummyTalks.length,
        itemBuilder: (context, index) {
          return TalkCard(talk: dummyTalks[index]);
        },
      ),
    );
  }
}