import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'local_storage_service.dart';

class OfflineUserService {
  // Create or update user profile locally (tries to upload image if possible)
  static Future<void> createOrUpdateUserProfileOffline({
    required String userId,
    required String username,
    required String fullName,
    String? bio,
    File? profileImage,
    List<String>? genres,
    List<String>? topArtists,
  }) async {
    String? profileImageUrl;

    try {
      // Use existing auth photo if available
      final user = FirebaseAuth.instance.currentUser;
      if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
        profileImageUrl = user.photoURL;
      }

      // Try to upload image (best-effort)
      if (profileImage != null) {
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('$userId.jpg');
          await ref.putFile(profileImage);
          profileImageUrl = await ref.getDownloadURL();

          // Try update auth photo (best-effort)
          if (user != null) {
            await user.updatePhotoURL(profileImageUrl);
          }
        } catch (e) {
          print('Firebase upload failed, saving locally: $e');
          // Save image locally as fallback
          try {
            profileImageUrl = await _saveImageLocally(userId, profileImage);
          } catch (localError) {
            print('Local save also failed: $localError');
            // Use existing auth photo or null
          }
        }
      }

      // Save to local storage (authoritative for offline mode)
      await LocalStorageService.saveUserProfile(
        userId: userId,
        username: username,
        fullName: fullName,
        bio: bio,
        profileImageUrl: profileImageUrl,
        genres: genres,
        topArtists: topArtists,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Check completion from local storage only
  static Future<bool> isProfileCompleteOffline(String userId) async {
    final data = await LocalStorageService.getUserProfile();
    if (data == null) return false;

    final uid = (data['uid'] as String?) ?? (data['userId'] as String?);
    if (uid == null || uid != userId) return false;

    final username = (data['username'] as String?)?.trim() ?? '';
    final fullName = (data['fullName'] as String?)?.trim() ?? (data['displayName'] as String?)?.trim() ?? '';

    return username.isNotEmpty && fullName.isNotEmpty;
  }

  // Normalized profile map for UI (keys match ProfileScreen expectations)
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final data = await LocalStorageService.getUserProfile();
    if (data == null) return null;

    return {
      'uid': data['uid'] ?? data['userId'],
      'username': data['username'] ?? '',
      'displayName': data['fullName'] ?? data['displayName'] ?? '',
      'photoURL': data['profileImageUrl'] ?? data['photoURL'] ?? '',
      'bio': data['bio'] ?? '',
      'website': data['website'] ?? '',
      'posts': data['posts'] ?? 0,
      'followers': data['followers'] ?? 0,
      'following': data['following'] ?? 0,
      'genres': (data['genres'] as List?)?.cast<String>() ?? <String>[],
      'topArtists': (data['topArtists'] as List?)?.cast<String>() ?? <String>[],
      'verified': data['isVerified'] ?? data['verified'] ?? false,
      'profileCompleted': data['profileCompleted'] ?? true,
    };
  }
  
  static Future<String> _saveImageLocally(String userId, File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localDir = Directory('${appDir.path}/profile_images');
      if (!await localDir.exists()) {
        await localDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_${userId}_$timestamp.jpg';
      final localFile = File('${localDir.path}/$fileName');
      
      await imageFile.copy(localFile.path);
      print('Image saved locally to: ${localFile.path}');
      return localFile.path;
    } catch (e) {
      print('Error saving image locally: $e');
      throw Exception('Failed to save image locally: $e');
    }
  }
}
