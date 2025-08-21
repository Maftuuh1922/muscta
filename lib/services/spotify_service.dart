import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyService {
  static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID'; // Ganti dengan client ID Anda
  static const String redirectUri = 'muscta://callback';
  static const String scopes = 'user-read-recently-played user-top-read playlist-read-private user-library-read';
  
  static String? _accessToken;
  static DateTime? _tokenExpiry;
  
  // Check if user is connected to Spotify
  static Future<bool> isConnected() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('spotify_access_token');
    final expiry = prefs.getString('spotify_token_expiry');
    
    if (token == null || expiry == null) return false;
    
    final expiryDate = DateTime.parse(expiry);
    if (DateTime.now().isAfter(expiryDate)) {
      await _refreshToken();
    }
    
    _accessToken = token;
    return true;
  }
  
  // Connect to Spotify
  static Future<void> connectSpotify() async {
    final authUrl = 'https://accounts.spotify.com/authorize'
        '?client_id=$clientId'
        '&response_type=code'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&scope=${Uri.encodeComponent(scopes)}'
        '&show_dialog=true';
    
    if (await canLaunchUrl(Uri.parse(authUrl))) {
      await launchUrl(Uri.parse(authUrl));
    }
  }
  
  // Handle callback and get access token
  static Future<bool> handleCallback(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': 'YOUR_CLIENT_SECRET', // Ganti dengan client secret
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('spotify_access_token', _accessToken!);
        await prefs.setString('spotify_refresh_token', data['refresh_token']);
        
        final expiry = DateTime.now().add(Duration(seconds: data['expires_in']));
        await prefs.setString('spotify_token_expiry', expiry.toIso8601String());
        
        return true;
      }
    } catch (e) {
      print('Error getting Spotify token: $e');
    }
    return false;
  }
  
  // Get user's top tracks
  static Future<List<Map<String, dynamic>>> getTopTracks({int limit = 20}) async {
    if (!await isConnected()) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/tracks?limit=$limit&time_range=medium_term'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['items']);
      }
    } catch (e) {
      print('Error getting top tracks: $e');
    }
    return [];
  }
  
  // Get user's top artists
  static Future<List<Map<String, dynamic>>> getTopArtists({int limit = 10}) async {
    if (!await isConnected()) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/artists?limit=$limit&time_range=medium_term'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['items']);
      }
    } catch (e) {
      print('Error getting top artists: $e');
    }
    return [];
  }
  
  // Get recently played tracks
  static Future<List<Map<String, dynamic>>> getRecentlyPlayed({int limit = 20}) async {
    if (!await isConnected()) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/recently-played?limit=$limit'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['items']);
      }
    } catch (e) {
      print('Error getting recently played: $e');
    }
    return [];
  }
  
  // Refresh token
  static Future<void> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('spotify_refresh_token');
    
    if (refreshToken == null) return;
    
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
          'client_secret': 'YOUR_CLIENT_SECRET',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        await prefs.setString('spotify_access_token', _accessToken!);
        final expiry = DateTime.now().add(Duration(seconds: data['expires_in']));
        await prefs.setString('spotify_token_expiry', expiry.toIso8601String());
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
  }
  
  // Disconnect from Spotify
  static Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('spotify_access_token');
    await prefs.remove('spotify_refresh_token');
    await prefs.remove('spotify_token_expiry');
    _accessToken = null;
  }
}