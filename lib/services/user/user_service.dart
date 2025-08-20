import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  }) async {
    String? profileImageUrl;

    // Upload profile image if provided
    if (profileImage != null) {
      profileImageUrl = await _uploadProfileImage(userId, profileImage);
    }

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
      'genres': <String>[],
      'topArtists': <String>[],
      'website': '',
      'profileCompleted': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _col.doc(userId).set(userData, SetOptions(merge: true));

    // Update Firebase Auth profile
    await FirebaseAuth.instance.currentUser?.updateDisplayName(fullName.trim());
    if (profileImageUrl != null) {
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(profileImageUrl);
    }
  }

  // Upload profile image to Firebase Storage
  Future<String> _uploadProfileImage(String userId, File imageFile) async {
    final ref = _storage.ref().child('users').child(userId).child('profile.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Check if user profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      final doc = await _col.doc(userId).get();
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      return data['profileCompleted'] == true &&
             data['username'] != null &&
             data['fullName'] != null &&
             data['username'].toString().isNotEmpty &&
             data['fullName'].toString().isNotEmpty;
    } catch (e) {
      // If Firestore is not available, assume profile is not complete
      print('Error checking profile completion: $e');
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
}
