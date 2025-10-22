import 'package:image_picker/image_picker.dart';

class StorageService {
  // Method to pick an image from the gallery
  Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  // --- WORKAROUND ---
  // This is a placeholder. We will implement the real upload later.
  Future<String> uploadProfilePicture(String userId, dynamic imageFile) async {
    // For now, we do nothing and return an empty string.
    print("Image uploading is temporarily disabled.");
    return '';
  }
}