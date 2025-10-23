// import 'package:campus_guardian/services/database_service.dart';
// import 'package:campus_guardian/services/storage_service.dart';
// import 'package:campus_guardian/widgets/app_button.dart';
// import 'package:campus_guardian/widgets/app_textfield.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// class AddTalkScreen extends StatefulWidget {
//   const AddTalkScreen({super.key});
//
//   @override
//   State<AddTalkScreen> createState() => _AddTalkScreenState();
// }
//
// class _AddTalkScreenState extends State<AddTalkScreen> {
//   final _titleController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   // MODIFIED: We now store the PlatformFile object from the picker
//   PlatformFile? _audioPlatformFile;
//   bool _isLoading = false;
//
//   Future<void> _pickAudio() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//       // For web, we need to read the file bytes
//       withData: true,
//     );
//     if (result != null) {
//       setState(() {
//         _audioPlatformFile = result.files.single;
//       });
//     }
//   }
//
//   Future<void> _submitTalk() async {
//     if (!_formKey.currentState!.validate() || _audioPlatformFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please provide a title and select an audio file.'), backgroundColor: Colors.orange),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final user = FirebaseAuth.instance.currentUser!;
//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
//       final userData = userDoc.data()!;
//
//       // 1. Upload audio using the correct method
//       final audioUrl = await StorageService().uploadMicroTalkAudio(user.uid, _audioPlatformFile!);
//
//       // 2. Create the document in Firestore
//       await DatabaseService().createMicroTalk(
//         title: _titleController.text.trim(),
//         speakerId: user.uid,
//         speakerName: userData['fullName'] ?? 'A Mentor',
//         speakerTitle: userData['mentorTitle'] ?? 'Mentor',
//         audioUrl: audioUrl,
//       );
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Micro-Talk posted successfully!'), backgroundColor: Colors.green),
//         );
//         context.pop();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to post talk: $e'), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create a Micro-Talk')),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16.0),
//           children: [
//             AppTextField(controller: _titleController, labelText: 'Talk Title'),
//             const SizedBox(height: 24),
//             OutlinedButton.icon(
//               icon: const Icon(Icons.audiotrack),
//               label: const Text('Select Audio File'),
//               onPressed: _pickAudio,
//             ),
//             if (_audioPlatformFile != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Text('Selected: ${_audioPlatformFile!.name}', textAlign: TextAlign.center),
//               ),
//             const SizedBox(height: 32),
//             AppButton(
//               text: _isLoading ? 'Posting...' : 'Post Micro-Talk',
//               onPressed: _isLoading ? null : _submitTalk,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }