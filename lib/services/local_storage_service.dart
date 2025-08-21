import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userProfileKey = 'user_profile_data';
  static const String _profileCompletedKey = 'profile_completed';
  static const String _settingsKey = 'app_settings_data';
  
  // Save profile data locally
  static Future<void> saveUserProfile({
    required String userId,
    required String username,
    required String fullName,
    String? bio,
    String? profileImageUrl,
    List<String>? genres,
    List<String>? topArtists,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final profileData = {
        'uid': userId,
        'username': username.toLowerCase().trim(),
        'fullName': fullName.trim(),
        'bio': bio?.trim() ?? '',
        'profileImageUrl': profileImageUrl ?? '',
        'genres': genres ?? <String>[],
        'topArtists': topArtists ?? <String>[],
        'posts': 0,
        'followers': 0,
        'following': 0,
        'isVerified': false,
        'website': '',
        'profileCompleted': true,
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_userProfileKey, json.encode(profileData));
      await prefs.setBool(_profileCompletedKey, true);
      
      print('Profile saved locally successfully');
    } catch (e) {
      print('Error saving profile locally: $e');
      throw Exception('Failed to save profile data');
    }
  }
  
  // Get profile data from local storage
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);
      
      if (profileJson != null) {
        return json.decode(profileJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting local profile: $e');
      return null;
    }
  }
  
  // Check if profile is completed locally
  static Future<bool> isProfileCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_profileCompletedKey) ?? false;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }
  
  // Clear local profile data
  static Future<void> clearUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProfileKey);
      await prefs.remove(_profileCompletedKey);
    } catch (e) {
      print('Error clearing local profile: $e');
    }
  }
  
  // Sync local data to Firestore when available
  static Future<bool> syncToFirestore() async {
    try {
      final localProfile = await getUserProfile();
      if (localProfile == null) return false;
      
      // Try to save to Firestore
      // This would be called from UserService when Firestore is available
      print('Local profile data ready for sync: ${localProfile['username']}');
      return true;
    } catch (e) {
      print('Error preparing sync data: $e');
      return false;
    }
  }

  // Save app settings locally
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, json.encode(settings));
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Get app settings
  static Future<Map<String, dynamic>?> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_settingsKey);
      if (jsonStr == null) return null;
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }
}
