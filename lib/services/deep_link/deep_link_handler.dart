import 'dart:async';
import 'package:flutter/services.dart';
import '../spotify/spotify_service.dart';

class DeepLinkHandler {
  static const MethodChannel _channel = MethodChannel('deep_link_handler');
  static bool _isInitialized = false;
  static final StreamController<String> _eventController = StreamController<String>.broadcast();

  static Stream<String> get onEvent => _eventController.stream;

  static void initialize() {
    if (_isInitialized) return;
    
    _channel.setMethodCallHandler(_handleDeepLink);
    _isInitialized = true;
  }

  static Future<void> _handleDeepLink(MethodCall call) async {
    switch (call.method) {
      case 'handleDeepLink':
        final String url = call.arguments as String;
        await handleUrl(url);
        break;
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  static Future<void> handleUrl(String url) async {
    try {
      print('Deep link received: $url');
      
      if (url.startsWith('muscta://callback')) {
        // Parse Spotify OAuth callback
        final uri = Uri.parse(url);
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];
        
        if (error != null) {
          print('Spotify OAuth error: $error');
          return;
        }
        
        if (code != null) {
          print('Spotify OAuth success, handling callback...');
          final ok = await SpotifyService.handleCallback(code);
          if (ok) {
            // Notify listeners that Spotify connection is established
            _eventController.add('spotify_connected');
          }
        }
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }
  }
}
