import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../local_storage_service.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');
  final _storage = FirebaseStorage.instance;

  // Complete user profile setup (for new users)
  Future<void> createOrUpdateUserProfile({
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
      // Upload profile image if provided
      if (profileImage != null) {
        print('Uploading profile image...');
        try {
          profileImageUrl = await _uploadProfileImage(userId, profileImage);
          print('Profile image uploaded successfully: $profileImageUrl');
        } catch (imageError) {
          print('Image upload failed, saving locally: $imageError');
          // Save image locally as fallback
          try {
            profileImageUrl = await _saveImageLocally(userId, profileImage);
            print('Image saved locally: $profileImageUrl');
          } catch (localError) {
            print('Local image save failed: $localError');
            profileImageUrl = null;
          }
        }
      }

      print('Creating user profile data...');
      final userData = {
        'uid': userId,
        'username': username.toLowerCase().trim(),
        'fullName': fullName.trim(),
        'bio': bio?.trim() ?? '',
        'profileImageUrl': profileImageUrl ?? '',
        'email': FirebaseAuth.instance.currentUser?.email,
        'displayName': fullName.trim(),
        'photoURL': profileImageUrl,
        'posts': 0,
        'followers': 0,
        'following': 0,
        'isVerified': false,
        'genres': genres ?? <String>[],
        'topArtists': topArtists ?? <String>[],
        'website': '',
        'profileCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Saving user profile to Firestore...');
      try {
        await _col.doc(userId).set(userData, SetOptions(merge: true)).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Firestore operation timeout. Please check your connection.');
          },
        );
        print('User profile saved successfully');
      } on FirebaseException catch (firestoreError) {
        print('Firestore error: ${firestoreError.code} - ${firestoreError.message}');
        
        // Handle specific Firestore errors
        switch (firestoreError.code) {
          case 'not-found':
            print('Firestore database not found, saving locally...');
            await LocalStorageService.saveUserProfile(
              userId: userId,
              username: username.toLowerCase().trim(),
              fullName: fullName.trim(),
              bio: bio?.trim(),
              profileImageUrl: profileImageUrl,
              genres: genres,
              topArtists: topArtists,
            );
            print('Profile saved locally as fallback');
            return; // Exit successfully with local storage
          case 'permission-denied':
            print('Firestore permission denied, saving locally...');
            await LocalStorageService.saveUserProfile(
              userId: userId,
              username: username.toLowerCase().trim(),
              fullName: fullName.trim(),
              bio: bio?.trim(),
              profileImageUrl: profileImageUrl,
              genres: genres,
              topArtists: topArtists,
            );
            print('Profile saved locally as fallback');
            return; // Exit successfully with local storage
          case 'unavailable':
            print('Firestore unavailable, saving locally...');
            await LocalStorageService.saveUserProfile(
              userId: userId,
              username: username.toLowerCase().trim(),
              fullName: fullName.trim(),
              bio: bio?.trim(),
              profileImageUrl: profileImageUrl,
              genres: genres,
              topArtists: topArtists,
            );
            print('Profile saved locally as fallback');
            return; // Exit successfully with local storage
          case 'deadline-exceeded':
            throw Exception('Firestore request timeout. Please check your connection.');
          default:
            print('Unknown Firestore error, saving locally...');
            await LocalStorageService.saveUserProfile(
              userId: userId,
              username: username.toLowerCase().trim(),
              fullName: fullName.trim(),
              bio: bio?.trim(),
              profileImageUrl: profileImageUrl,
              genres: genres,
              topArtists: topArtists,
            );
            print('Profile saved locally as fallback');
            return; // Exit successfully with local storage
        }
      } catch (timeoutError) {
        if (timeoutError.toString().contains('timeout')) {
          print('Firestore timeout, saving locally as fallback...');
          await LocalStorageService.saveUserProfile(
            userId: userId,
            username: username.toLowerCase().trim(),
            fullName: fullName.trim(),
            bio: bio?.trim(),
            profileImageUrl: profileImageUrl,
            genres: genres,
            topArtists: topArtists,
          );
          print('Profile saved locally as fallback');
          return; // Exit successfully with local storage
        }
        rethrow;
      }

      // Update Firebase Auth profile
      print('Updating Firebase Auth profile...');
      try {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(fullName.trim());
        if (profileImageUrl != null) {
          await FirebaseAuth.instance.currentUser?.updatePhotoURL(profileImageUrl);
        }
        print('Firebase Auth profile updated successfully');
      } catch (authError) {
        print('Failed to update auth profile, but continuing: $authError');
        // Don't fail the entire operation if auth update fails
      }
      
    } on FirebaseException catch (e) {
      print('Firebase error in createOrUpdateUserProfile: ${e.code} - ${e.message}');
      throw Exception('Failed to create profile: ${e.message ?? e.code}');
    } catch (e) {
      print('Error in createOrUpdateUserProfile: $e');
      throw Exception('Failed to create profile: ${e.toString()}');
    }
  }

  // Upload profile image to Firebase Storage
  Future<String> _uploadProfileImage(String userId, File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$timestamp.jpg';
      
      // Use a simpler path structure
      final ref = _storage.ref('profile_images/$userId/$fileName');
      
      print('Uploading to path: profile_images/$userId/$fileName');
      print('File size: ${await imageFile.length()} bytes');
      
      // Add metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': userId,
          'upload_time': timestamp.toString(),
        },
      );
      
      // Start upload
      final uploadTask = ref.putFile(imageFile, metadata);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      // Wait for upload to complete with timeout
      final snapshot = await uploadTask.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          uploadTask.cancel();
          throw Exception('Upload timeout - please check your internet connection');
        },
      );
      
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
      
    } on FirebaseException catch (e) {
      print('Firebase error uploading image: ${e.code} - ${e.message}');
      
      // Handle specific Firebase Storage errors
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('Not authorized to upload images. Please check Firebase Storage rules.');
        case 'storage/canceled':
          throw Exception('Upload was canceled. Please try again.');
        case 'storage/unknown':
          throw Exception('An unknown error occurred. Please try again.');
        case 'storage/object-not-found':
          throw Exception('Storage bucket not found. Please check Firebase configuration.');
        case 'storage/bucket-not-found':
          throw Exception('Storage bucket not found. Please contact support.');
        case 'storage/project-not-found':
          throw Exception('Firebase project not found. Please check configuration.');
        case 'storage/quota-exceeded':
          throw Exception('Storage quota exceeded. Please try again later.');
        case 'storage/unauthenticated':
          throw Exception('User not authenticated. Please sign in again.');
        case 'storage/retry-limit-exceeded':
          throw Exception('Upload failed after multiple attempts. Please try again.');
        case 'storage/invalid-checksum':
          throw Exception('File corrupted during upload. Please try again.');
        default:
          throw Exception('Upload failed: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      print('General error uploading image: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('Upload timeout. Please check your internet connection and try again.');
      }
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      // First try Firestore
      final doc = await _col.doc(userId).get().timeout(
        const Duration(seconds: 10),
      );
      
      if (doc.exists) {
        final data = doc.data()!;
        return data['profileCompleted'] == true &&
               data['username'] != null &&
               data['fullName'] != null &&
               data['username'].toString().isNotEmpty &&
               data['fullName'].toString().isNotEmpty;
      }
    } catch (e) {
      print('Firestore not available for profile check: $e');
    }
    
    // Fallback to local storage
    try {
      return await LocalStorageService.isProfileCompleted();
    } catch (e) {
      print('Error checking local profile completion: $e');
      return false;
    }
  }

  Future<void> upsertCurrentUser() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    try {
      final ref = _col.doc(u.uid);
      final snap = await ref.get();

      final base = {
        'uid': u.uid,
        'email': u.email,
        'displayName': u.displayName,
        'photoURL': u.photoURL,
        'providerIds': u.providerData.map((e) => e.providerId).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (snap.exists) {
        await ref.set(base, SetOptions(merge: true));
      } else {
        final username = (u.displayName?.trim().isNotEmpty == true)
            ? u.displayName!.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
            : (u.email?.split('@').first ?? 'user');
        await ref.set({
          ...base,
          'username': username,
          'bio': '',
          'website': '',
          'posts': 0,
          'followers': 0,
          'following': 0,
          'genres': [],
          'topArtists': [],
          'verified': false,
          'profileCompleted': false, // New users need to complete profile
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error upserting user: $e');
      // Continue without Firestore for now
    }
  }

  Stream<Map<String, dynamic>?> currentUserStream() {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      return const Stream.empty();
    }
    return _col.doc(u.uid).snapshots().map((d) => d.data());
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? website,
    String? photoURL,
  }) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    final ref = _col.doc(u.uid);

    final data = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (username != null)
        'username': username.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_'),
      if (bio != null) 'bio': bio,
      if (website != null) 'website': website,
      if (photoURL != null) 'photoURL': photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await ref.set(data, SetOptions(merge: true));
  }
  
  Future<String> _saveImageLocally(String userId, File imageFile) async {
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
