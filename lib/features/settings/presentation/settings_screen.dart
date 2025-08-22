import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/user/user_service.dart';
import '../../profile/presentation/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local settings state; persisted via SharedPreferences through OfflineUserService's local storage
  Map<String, dynamic> _settings = {
    'notifications': {
      'likes': true,
      'comments': true,
      'follows': true,
      'musicRecommendations': false,
      'trendingAlerts': true,
    },
    'privacy': {
      'privateAccount': false,
      'showOnlineStatus': true,
      'allowTagging': true,
    },
    'music': {
      'autoPlay': true,
      'highQuality': false,
      'downloadOverWiFi': true,
      'showLyrics': true,
    },
    'appearance': {
      'darkMode': true,
      'colorTheme': 'teal',
    },
    'connections': {
      'spotify': true,
      'appleMusic': false,
      'youtubeMusic': true,
    }
  };

  bool _loading = true;
  Map<String, dynamic>? _localProfile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Load profile (for header) and settings (if previously saved)
    try {
  // For header, we can still read a locally saved profile (if any)
  final profile = await LocalStorageService.getUserProfile();
  final stored = await LocalStorageService.getSettings();
      if (stored != null) {
        // Merge with defaults to avoid missing keys
        _settings = _deepMerge(Map<String, dynamic>.from(_settings), stored);
      }
      setState(() {
        _localProfile = profile;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  Map<String, dynamic> _deepMerge(Map<String, dynamic> base, Map<String, dynamic> other) {
    other.forEach((key, value) {
      if (value is Map && base[key] is Map) {
        base[key] = _deepMerge(Map<String, dynamic>.from(base[key]), Map<String, dynamic>.from(value));
      } else {
        base[key] = value;
      }
    });
    return base;
  }

  Future<void> _saveSettings() async {
    await LocalStorageService.saveSettings(_settings);
  }

  void _handleSettingChange(String category, String key, dynamic value) {
    setState(() {
      final cat = Map<String, dynamic>.from(_settings[category] as Map);
      cat[key] = value;
      _settings[category] = cat;
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _buildProfileHeader(),
                _sectionTitle('Account'),
                _card(
                  children: [
                    _tile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () async {
                        final name = (_localProfile?['displayName'] as String?) ?? '';
                        final username = (_localProfile?['username'] as String?) ?? '';
                        final bio = (_localProfile?['bio'] as String?) ?? '';
                        final website = (_localProfile?['website'] as String?) ?? '';
                        final profileImageUrl = (_localProfile?['profileImageUrl'] as String?) ?? '';
                        final genres = (_localProfile?['genres'] as List?)?.cast<String>();
                        
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                              displayName: name,
                              username: username,
                              bio: bio,
                              website: website,
                              profileImageUrl: profileImageUrl,
                              genres: genres,
                            ),
                          ),
                        );
                      },
                    ),
                    _divider(),
                    _tile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacy & Security',
                      onTap: () => _snack('Privacy & Security coming soon'),
                    ),
                    _divider(),
                    _tile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () => _snack('Notifications coming soon'),
                    ),
                  ],
                ),

                _sectionTitle('Music'),
                _card(
                  children: [
                    _tile(
                      icon: Icons.music_note_outlined,
                      title: 'Music Preferences',
                      onTap: () => _snack('Music Preferences coming soon'),
                    ),
                    _divider(),
                    _tile(
                      icon: Icons.graphic_eq_rounded,
                      title: 'Audio Quality',
                      onTap: () => _snack('Audio Quality coming soon'),
                    ),
                    _divider(),
                    _tile(
                      icon: Icons.download_outlined,
                      title: 'Downloads',
                      onTap: () => _snack('Downloads coming soon'),
                    ),
                  ],
                ),

                _sectionTitle('Appearance'),
                _card(
                  children: [
                    _tile(
                      icon: Icons.palette_outlined,
                      title: 'Theme & Colors',
                      onTap: () => _snack('Theme picker coming soon'),
                    ),
                    _divider(),
                    _switchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      value: (_settings['appearance'] as Map)['darkMode'] as bool,
                      onChanged: (v) => _handleSettingChange('appearance', 'darkMode', v),
                    ),
                  ],
                ),

                _sectionTitle('Support'),
                _card(
                  children: [
                    _tile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      onTap: () => _snack('Help Center coming soon'),
                    ),
                    _divider(),
                    _tile(
                      icon: Icons.shield_outlined,
                      title: 'Report a Problem',
                      onTap: () => _snack('Report issue coming soon'),
                    ),
                  ],
                ),

                _sectionTitle('Connected Accounts'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _connectionCard(
                        name: 'Spotify',
                        connected: ((_settings['connections'] as Map)['spotify'] as bool),
                        color: const Color(0xFF1DB954),
                        onPressed: () {
                          final v = !((_settings['connections'] as Map)['spotify'] as bool);
                          _handleSettingChange('connections', 'spotify', v);
                        },
                      ),
                      const SizedBox(height: 10),
                      _connectionCard(
                        name: 'Apple Music',
                        connected: ((_settings['connections'] as Map)['appleMusic'] as bool),
                        color: Colors.grey,
                        onPressed: () {
                          final v = !((_settings['connections'] as Map)['appleMusic'] as bool);
                          _handleSettingChange('connections', 'appleMusic', v);
                        },
                      ),
                      const SizedBox(height: 10),
                      _connectionCard(
                        name: 'YouTube Music',
                        connected: ((_settings['connections'] as Map)['youtubeMusic'] as bool),
                        color: const Color(0xFFFF3D00),
                        onPressed: () {
                          final v = !((_settings['connections'] as Map)['youtubeMusic'] as bool);
                          _handleSettingChange('connections', 'youtubeMusic', v);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _card(
                    children: [
                      ListTile(
                        onTap: _confirmLogout,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        title: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const Text('MusicSocial v1.0.0', style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 16,
                        children: const [
                          Text('Terms of Service', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                          Text('Privacy Policy', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 0.5),
        ),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: UserService().currentUserStream(),
          builder: (context, snapshot) {
            final userData = snapshot.data;
            final name = userData?['displayName'] as String? ?? 
                         userData?['fullName'] as String? ?? 
                         FirebaseAuth.instance.currentUser?.displayName ?? 
                         'Your Name';
            final username = userData?['username'] as String? ?? 'your_username';
            final photo = userData?['photoURL'] as String? ?? '';

            return Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.borderColor,
                  backgroundImage: _getImageProvider(photo),
                  child: photo.isEmpty ? const Icon(Icons.person, color: AppColors.mutedText) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
                      Text('@$username', style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                displayName: name,
                                username: username,
                                bio: userData?['bio'] as String? ?? '',
                                website: userData?['website'] as String? ?? '',
                                profileImageUrl: photo,
                                genres: (userData?['genres'] as List?)?.cast<String>(),
                              ),
                            ),
                          );
                        },
                        child: const Text('View Profile', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      );

  Widget _card({required List<Widget> children}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 0.5),
          ),
          child: Column(children: children),
        ),
      );

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) => ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.mutedText),
        title: Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w500)),
        subtitle: subtitle == null ? null : Text(subtitle, style: const TextStyle(color: AppColors.mutedText)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText, size: 18),
      );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => ListTile(
        leading: Icon(icon, color: AppColors.mutedText),
        title: Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryPurple,
        ),
      );

  Widget _divider() => const Divider(height: 1, color: AppColors.borderColor);

  Widget _connectionCard({
    required String name,
    required bool connected,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
                Text(connected ? 'Connected' : 'Not connected', style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: connected ? Colors.redAccent : Colors.white,
              backgroundColor: connected ? Colors.transparent : AppColors.primaryPurple,
              side: connected ? const BorderSide(color: Colors.redAccent) : BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(connected ? 'Disconnect' : 'Connect'),
          )
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Log out of MusicSocial?', style: TextStyle(color: AppColors.primaryText)),
        content: const Text(
          "You'll need to log back in to access your account and continue discovering music.",
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.redAccent),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        // Clear local storage
        await LocalStorageService.clearUserProfile();
        
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();
        
        // Navigate to login screen and clear all routes
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/', // This goes to AuthGate which will redirect to LoginScreen
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  ImageProvider? _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }

    // Support file:// URIs
    if (imageUrl.startsWith('file://')) {
      try {
        final file = File.fromUri(Uri.parse(imageUrl));
        if (file.existsSync()) return FileImage(file);
      } catch (_) {}
    }

    // Support absolute filesystem paths
    if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);
      if (file.existsSync()) return FileImage(file);
    }

    return null;
  }
}

