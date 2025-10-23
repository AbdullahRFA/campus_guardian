import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // This method remains the same for profile pictures
  Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  // This is the placeholder method for profile picture uploads
  Future<String> uploadProfilePicture(String userId, dynamic imageFile) async {
    print("Image uploading is temporarily disabled.");
    return '';
  }

  // MODIFIED: This method now handles both web (bytes) and mobile/desktop (file)
  Future<String> uploadMicroTalkAudio(String userId, PlatformFile file) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final ref = _storage.ref().child('micro_talks').child(fileName);

      UploadTask uploadTask;

      // Check if running on web
      if (kIsWeb) {
        // For web, use putData with the file's bytes
        uploadTask = ref.putData(file.bytes!);
      } else {
        // For mobile/desktop, use putFile with the file's path
        uploadTask = ref.putFile(File(file.path!));
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading audio: $e");
      rethrow; // Rethrow the error to be caught by the UI
    }
  }
}