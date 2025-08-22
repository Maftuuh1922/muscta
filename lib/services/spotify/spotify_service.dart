import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyService {
  // Values provided by the user (Spotify Dashboard)
  static const String clientId = '8ba68d2ba63241daa853c44ec9dc5670';
  static const String clientSecret = '265454da071140ab8f1d9e94e891aa15';
  static const String redirectUri = 'muscta://callback';
  static const String scopes = 'user-read-recently-played user-top-read playlist-read-private user-library-read user-read-currently-playing';
  
  static String? _accessToken;
  // Token expiry is tracked in SharedPreferences; no in-memory field needed
  
  // Check if user is connected to Spotify
  static Future<bool> isConnected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('spotify_access_token');
      final expiry = prefs.getString('spotify_token_expiry');
      
      if (token == null || expiry == null) return false;
      
      final expiryDate = DateTime.parse(expiry);
      if (DateTime.now().isAfter(expiryDate)) {
        final refreshed = await _refreshToken();
        if (!refreshed) return false;
      }
      
      _accessToken = prefs.getString('spotify_access_token');
      return _accessToken != null;
    } catch (e) {
      print('Error checking Spotify connection: $e');
      return false;
    }
  }
  
  // Connect to Spotify
  static Future<void> connectSpotify() async {
    // Build URI safely using Uri.https to avoid encoding issues
    final uri = Uri.https(
      'accounts.spotify.com',
      '/authorize',
      {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'scope': scopes,
        'show_dialog': 'true',
      },
    );

    // Try multiple launch modes; some devices/browsers report false negatives
    final attempts = <LaunchMode>[
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
      LaunchMode.inAppWebView,
    ];

    Object? lastError;
    for (final mode in attempts) {
      try {
        final ok = await launchUrl(uri, mode: mode);
        if (ok) return;
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('Could not launch Spotify authorization. Url=$uri Error=$lastError');
  }
  
  // Handle callback and get access token
  static Future<bool> handleCallback(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('spotify_access_token', _accessToken!);
        
        if (data['refresh_token'] != null) {
          await prefs.setString('spotify_refresh_token', data['refresh_token']);
        }
        
        final expiry = DateTime.now().add(Duration(seconds: data['expires_in'] ?? 3600));
        await prefs.setString('spotify_token_expiry', expiry.toIso8601String());
        
        print('Spotify connection successful');
        return true;
      } else {
        print('Spotify auth failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting Spotify token: $e');
    }
    return false;
  }
  
  // Get user's profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (!await isConnected()) return null;
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }
  
  // Get user's top tracks
  static Future<List<Map<String, dynamic>>> getTopTracks({int limit = 20, String timeRange = 'medium_term'}) async {
    if (!await isConnected()) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/tracks?limit=$limit&time_range=$timeRange'),
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
  static Future<List<Map<String, dynamic>>> getTopArtists({int limit = 10, String timeRange = 'medium_term'}) async {
    if (!await isConnected()) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/artists?limit=$limit&time_range=$timeRange'),
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
  
  // Get currently playing track
  static Future<Map<String, dynamic>?> getCurrentlyPlaying() async {
    if (!await isConnected()) return null;
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/currently-playing'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting currently playing: $e');
    }
    return null;
  }
  
  // Search for tracks
  static Future<List<Map<String, dynamic>>> searchTracks(String query, {int limit = 20}) async {
    if (!await isConnected()) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track&limit=$limit'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['tracks']['items']);
      }
    } catch (e) {
      print('Error searching tracks: $e');
    }
    return [];
  }
  
  // Get user's playlists
  static Future<List<Map<String, dynamic>>> getUserPlaylists({int limit = 20}) async {
    if (!await isConnected()) return [];
    
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists?limit=$limit'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['items']);
      }
    } catch (e) {
      print('Error getting playlists: $e');
    }
    return [];
  }
  
  // Refresh token
  static Future<bool> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('spotify_refresh_token');
    
    if (refreshToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        await prefs.setString('spotify_access_token', _accessToken!);
        final expiry = DateTime.now().add(Duration(seconds: data['expires_in'] ?? 3600));
        await prefs.setString('spotify_token_expiry', expiry.toIso8601String());
        
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }
  
  // Disconnect from Spotify
  static Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('spotify_access_token');
    await prefs.remove('spotify_refresh_token');
    await prefs.remove('spotify_token_expiry');
    _accessToken = null;
    print('Spotify disconnected');
  }
  
  // Helper method to format track for posting
  static Map<String, dynamic> formatTrackForPost(Map<String, dynamic> track) {
    final artists = List<Map<String, dynamic>>.from(track['artists'] ?? []);
    final album = track['album'] as Map<String, dynamic>? ?? {};
    final images = List<Map<String, dynamic>>.from(album['images'] ?? []);
    
    return {
      'title': track['name'] ?? 'Unknown Track',
      'artist': artists.isNotEmpty ? artists.map((a) => a['name']).join(', ') : 'Unknown Artist',
      'album': album['name'] ?? 'Unknown Album',
      'albumCover': images.isNotEmpty ? images.first['url'] : '',
      'duration': _formatDuration(track['duration_ms']),
      'spotifyId': track['id'],
      'spotifyUri': track['uri'],
      'previewUrl': track['preview_url'],
      'popularity': track['popularity'] ?? 0,
    };
  }
  
  // Format duration from ms to mm:ss
  static String _formatDuration(int? durationMs) {
    if (durationMs == null) return '0:00';
    
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
