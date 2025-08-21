import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestService {
  static Future<void> testFirebaseConnections() async {
    print('=== Testing Firebase Connections ===');
    
    // Test Auth
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('✅ Auth: User ${user?.uid ?? 'not logged in'}');
    } catch (e) {
      print('❌ Auth Error: $e');
    }
    
    // Test Firestore
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('test')
          .set({'timestamp': FieldValue.serverTimestamp()});
      print('✅ Firestore: Connection successful');
    } catch (e) {
      print('❌ Firestore Error: $e');
    }
    
    // Test Storage
    try {
      final ref = FirebaseStorage.instance.ref('test/test.txt');
      print('✅ Storage: Reference created - ${ref.fullPath}');
      print('Storage bucket: ${FirebaseStorage.instance.bucket}');
      
      // Try to list files in root (to test permissions)
      try {
        final listResult = await FirebaseStorage.instance.ref().listAll();
        print('✅ Storage: Can list files (${listResult.items.length} items)');
      } catch (listError) {
        print('⚠️  Storage: Cannot list files - $listError');
      }
      
    } catch (e) {
      print('❌ Storage Error: $e');
    }
    
    print('=== Firebase Test Complete ===');
  }
  
  static Future<void> testImageUpload() async {
    print('=== Testing Image Upload Path ===');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }
      
      // Test creating references with different path structures
      final paths = [
        'profile_images/${user.uid}/test.jpg',
        'users/${user.uid}/profile.jpg',
        'images/profiles/${user.uid}.jpg',
      ];
      
      for (final path in paths) {
        try {
          final ref = FirebaseStorage.instance.ref(path);
          print('✅ Reference created: $path');
          print('   Full path: ${ref.fullPath}');
          print('   Bucket: ${ref.bucket}');
        } catch (e) {
          print('❌ Failed to create reference for $path: $e');
        }
      }
      
    } catch (e) {
      print('❌ Test failed: $e');
    }
    
    print('=== Image Upload Test Complete ===');
  }
}
