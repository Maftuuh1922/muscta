import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PostService {
  final _postsCol = FirebaseFirestore.instance.collection('posts');
  final _storage = FirebaseStorage.instance;

  // Create new music post
  Future<String> createPost({
    String? musicTitle,
    String? musicArtist,
    String? musicAlbumCover,
    String? musicDuration,
    required String caption,
    XFile? imageFile,
    String? spotifyId,
    String? previewUrl,
    int? clipStartMs,
    int? clipDurationMs,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final postId = _postsCol.doc().id;
    String? imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      imageUrl = await _uploadImage(postId, imageFile);
    }

    final musicMap = () {
      // Build music map only when at least one music-related field exists
      if (musicTitle == null && musicArtist == null && musicAlbumCover == null && musicDuration == null && spotifyId == null && previewUrl == null && clipStartMs == null && clipDurationMs == null) return null;
      final m = <String, dynamic>{};
      if (musicTitle != null) m['title'] = musicTitle;
      if (musicArtist != null) m['artist'] = musicArtist;
      if (musicAlbumCover != null) m['albumCover'] = musicAlbumCover;
      if (musicDuration != null) m['duration'] = musicDuration;
      if (spotifyId != null) m['spotifyId'] = spotifyId;
      if (previewUrl != null) m['previewUrl'] = previewUrl;
      if (clipStartMs != null) m['clipStartMs'] = clipStartMs;
      if (clipDurationMs != null) m['clipDurationMs'] = clipDurationMs;
      return m;
    }();

    final postData = {
      'id': postId,
      'userId': user.uid,
      'userEmail': user.email,
      'userDisplayName': user.displayName ?? 'Unknown User',
      'userPhotoURL': user.photoURL,
      if (musicMap != null) 'music': musicMap,
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': 0,
      'comments': 0,
      'reposts': 0,
      'likedBy': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _postsCol.doc(postId).set(postData);
    return postId;
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(String postId, XFile imageFile) async {
    final ref = _storage.ref().child('posts').child(postId).child('image.jpg');
    final uploadTask = ref.putFile(File(imageFile.path));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Get timeline posts (all posts, ordered by newest)
  Stream<List<Map<String, dynamic>>> getTimelinePosts() {
    try {
      return _postsCol
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .handleError((error) {
        print('Firestore error in getTimelinePosts: $error');
        // Return empty list when error occurs
        return [];
      })
          .asyncMap((snap) async {
        final List<Map<String, dynamic>> posts = [];
        
        for (var doc in snap.docs) {
          final data = doc.data();
          data['id'] = doc.id;

          // Convert timestamps to DateTime for UI convenience
          try {
            final createdAt = data['createdAt'];
            if (createdAt != null && createdAt is Timestamp) {
              data['createdAt'] = createdAt.toDate();
            }
            final updatedAt = data['updatedAt'];
            if (updatedAt != null && updatedAt is Timestamp) {
              data['updatedAt'] = updatedAt.toDate();
            }
          } catch (_) {}
          
          // Get user data
          if (data['userId'] != null) {
            try {
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(data['userId'])
                  .get();
              
              if (userDoc.exists) {
                data['userData'] = userDoc.data() ?? {};
              } else {
                data['userData'] = {
                  'username': 'Unknown User',
                  'profileImageUrl': '',
                  'isVerified': false,
                };
              }
            } catch (e) {
              data['userData'] = {
                'username': 'Unknown User',
                'profileImageUrl': '',
                'isVerified': false,
              };
            }
          }
          
          posts.add(data);
        }
        
        return posts;
      });
    } catch (e) {
      print('Critical error in getTimelinePosts: $e');
      // Return stream with empty list
      return Stream.value([]);
    }
  }

  // Get user's posts
  Stream<List<Map<String, dynamic>>> getUserPosts(String userId) {
    return _postsCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // Like/unlike post
  Future<void> toggleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postRef = _postsCol.doc(postId);
    
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) return;

      final data = postDoc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final currentLikes = data['likes'] ?? 0;

      if (likedBy.contains(user.uid)) {
        // Unlike
        likedBy.remove(user.uid);
        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': currentLikes - 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Like
        likedBy.add(user.uid);
        transaction.update(postRef, {
          'likedBy': likedBy,
          'likes': currentLikes + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Add comment to post
  Future<void> addComment(String postId, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final commentId = FirebaseFirestore.instance.collection('temp').doc().id;
    
    // Add comment to comments subcollection
    await _postsCol.doc(postId).collection('comments').doc(commentId).set({
      'id': commentId,
      'userId': user.uid,
      'userDisplayName': user.displayName ?? 'Unknown User',
      'userPhotoURL': user.photoURL,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update comment count in post
    await _postsCol.doc(postId).update({
      'comments': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get comments for a post
  Stream<List<Map<String, dynamic>>> getComments(String postId) {
    return _postsCol
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // Delete post (only by owner)
  Future<void> deletePost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postDoc = await _postsCol.doc(postId).get();
    if (!postDoc.exists) return;
    
    final postData = postDoc.data()!;
    if (postData['userId'] != user.uid) {
      throw Exception('You can only delete your own posts');
    }

    // Delete image from storage if exists
    if (postData['imageUrl'] != null) {
      try {
        await _storage.refFromURL(postData['imageUrl']).delete();
      } catch (e) {
        // Ignore if image doesn't exist
      }
    }

    // Delete all comments
    final comments = await _postsCol.doc(postId).collection('comments').get();
    for (final comment in comments.docs) {
      await comment.reference.delete();
    }

    // Delete post
    await _postsCol.doc(postId).delete();
  }
}
