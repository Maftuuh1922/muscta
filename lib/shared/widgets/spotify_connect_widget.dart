import 'package:flutter/material.dart';
import '../../../services/spotify/spotify_service.dart';

class SpotifyConnectWidget extends StatefulWidget {
  final Function(List<String> topArtists, List<Map<String, dynamic>> topTracks)? onDataLoaded;
  
  const SpotifyConnectWidget({
    super.key,
    this.onDataLoaded,
  });

  @override
  State<SpotifyConnectWidget> createState() => _SpotifyConnectWidgetState();
}

class _SpotifyConnectWidgetState extends State<SpotifyConnectWidget> {
  bool _isSpotifyConnected = false;
  bool _isConnecting = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _topTracks = [];
  List<Map<String, dynamic>> _topArtists = [];
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _checkSpotifyConnection();
  }

  Future<void> _checkSpotifyConnection() async {
    setState(() {
      _isLoading = true;
    });
    
    final connected = await SpotifyService.isConnected();
    
    if (connected) {
      await _loadSpotifyData();
    }
    
    setState(() {
      _isSpotifyConnected = connected;
      _isLoading = false;
    });
  }

  Future<void> _loadSpotifyData() async {
    try {
      final [profile, tracks, artists] = await Future.wait([
        SpotifyService.getUserProfile(),
        SpotifyService.getTopTracks(limit: 10),
        SpotifyService.getTopArtists(limit: 10),
      ]);

      setState(() {
        _userProfile = profile as Map<String, dynamic>?;
        _topTracks = tracks as List<Map<String, dynamic>>;
        _topArtists = artists as List<Map<String, dynamic>>;
      });

      // Callback to parent with data
      if (widget.onDataLoaded != null && _topArtists.isNotEmpty) {
        final artistNames = _topArtists.map((artist) => artist['name'].toString()).toList();
        widget.onDataLoaded!(artistNames, _topTracks);
      }
    } catch (e) {
      print('Error loading Spotify data: $e');
    }
  }

  Future<void> _connectSpotify() async {
    setState(() {
      _isConnecting = true;
    });
    
    try {
      await SpotifyService.connectSpotify();
      // The connection will be handled by deep linking
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to Spotify: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() {
      _isConnecting = false;
    });
  }

  Future<void> _disconnect() async {
    await SpotifyService.disconnect();
    setState(() {
      _isSpotifyConnected = false;
      _topTracks.clear();
      _topArtists.clear();
      _userProfile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF1ed760)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading 
        ? _buildLoadingState()
        : _isSpotifyConnected 
          ? _buildConnectedState() 
          : _buildDisconnectedState(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect to Spotify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Import your music taste automatically',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '🎵 Get your top artists & tracks\n🎯 Personalized music recommendations\n📱 Easy music posting',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isConnecting ? null : _connectSpotify,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1DB954),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: _isConnecting 
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF1DB954)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Connecting...'),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Connect to Spotify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connected to Spotify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_userProfile != null)
                      Text(
                        'Welcome, ${_userProfile!['display_name'] ?? 'User'}!',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _disconnect,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Disconnect',
              ),
            ],
          ),
          
          if (_topTracks.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Your Top Tracks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _topTracks.length > 5 ? 5 : _topTracks.length,
                itemBuilder: (context, index) {
                  final track = _topTracks[index];
                  final album = track['album'] as Map<String, dynamic>? ?? {};
                  final images = List<Map<String, dynamic>>.from(album['images'] ?? []);
                  final imageUrl = images.isNotEmpty ? images.first['url'] : null;
                  
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withOpacity(0.2),
                            image: imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: imageUrl == null
                              ? const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          track['name'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          if (_topArtists.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Your Top Artists',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _topArtists.take(6).map((artist) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    artist['name'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
