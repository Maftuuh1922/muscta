import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoPlayEnabled = true;
  bool _highQualityAudio = false;
  bool _shareListeningActivity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          _buildProfileSection(),
          const SizedBox(height: 24),
          _buildMusicPlatformsSection(),
          const SizedBox(height: 24),
          _buildPreferencesSection(),
          const SizedBox(height: 24),
          _buildPrivacySection(),
          const SizedBox(height: 24),
          _buildSupportSection(),
          const SizedBox(height: 24),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      title: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.primaryText,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'Profile',
      children: [
        _buildSettingsTile(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profile',
          subtitle: 'Update your profile information',
          onTap: () => _navigateToEditProfile(),
        ),
        _buildSettingsTile(
          icon: Icons.music_note_rounded,
          title: 'Music Preferences',
          subtitle: 'Set your favorite genres and artists',
          onTap: () => _navigateToMusicPreferences(),
        ),
        _buildSettingsTile(
          icon: Icons.visibility_rounded,
          title: 'Profile Visibility',
          subtitle: 'Control who can see your profile',
          onTap: () => _navigateToProfileVisibility(),
        ),
      ],
    );
  }

  Widget _buildMusicPlatformsSection() {
    return _buildSection(
      title: 'Connected Platforms',
      children: [
        _buildPlatformTile(
          'Spotify',
          'Connect your Spotify account',
          'spotify_logo',
          true,
          () => _toggleSpotifyConnection(),
        ),
        _buildPlatformTile(
          'Apple Music',
          'Connect your Apple Music account',
          'apple_music_logo',
          false,
          () => _toggleAppleMusicConnection(),
        ),
        _buildPlatformTile(
          'YouTube Music',
          'Connect your YouTube Music account',
          'youtube_music_logo',
          false,
          () => _toggleYouTubeMusicConnection(),
        ),
        _buildPlatformTile(
          'SoundCloud',
          'Connect your SoundCloud account',
          'soundcloud_logo',
          true,
          () => _toggleSoundCloudConnection(),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'App Preferences',
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_rounded,
          title: 'Push Notifications',
          subtitle: 'Get notified about new music and activity',
          value: _notificationsEnabled,
          onChanged: (value) => setState(() => _notificationsEnabled = value),
        ),
        _buildSwitchTile(
          icon: Icons.dark_mode_rounded,
          title: 'Dark Mode',
          subtitle: 'Use dark theme',
          value: _darkModeEnabled,
          onChanged: (value) => setState(() => _darkModeEnabled = value),
        ),
        _buildSwitchTile(
          icon: Icons.play_arrow_rounded,
          title: 'Auto-Play',
          subtitle: 'Automatically play music in posts',
          value: _autoPlayEnabled,
          onChanged: (value) => setState(() => _autoPlayEnabled = value),
        ),
        _buildSwitchTile(
          icon: Icons.high_quality_rounded,
          title: 'High Quality Audio',
          subtitle: 'Stream music in higher quality',
          value: _highQualityAudio,
          onChanged: (value) => setState(() => _highQualityAudio = value),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Privacy & Security',
      children: [
        _buildSwitchTile(
          icon: Icons.share_rounded,
          title: 'Share Listening Activity',
          subtitle: 'Let others see what you\'re listening to',
          value: _shareListeningActivity,
          onChanged: (value) => setState(() => _shareListeningActivity = value),
        ),
        _buildSettingsTile(
          icon: Icons.block_rounded,
          title: 'Blocked Users',
          subtitle: 'Manage blocked accounts',
          onTap: () => _navigateToBlockedUsers(),
        ),
        _buildSettingsTile(
          icon: Icons.security_rounded,
          title: 'Privacy Settings',
          subtitle: 'Control your data and privacy',
          onTap: () => _navigateToPrivacySettings(),
        ),
        _buildSettingsTile(
          icon: Icons.download_rounded,
          title: 'Download Your Data',
          subtitle: 'Get a copy of your data',
          onTap: () => _downloadUserData(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'Support & About',
      children: [
        _buildSettingsTile(
          icon: Icons.help_outline_rounded,
          title: 'Help Center',
          subtitle: 'Get help and support',
          onTap: () => _navigateToHelpCenter(),
        ),
        _buildSettingsTile(
          icon: Icons.bug_report_rounded,
          title: 'Report a Problem',
          subtitle: 'Let us know about issues',
          onTap: () => _reportProblem(),
        ),
        _buildSettingsTile(
          icon: Icons.info_outline_rounded,
          title: 'About',
          subtitle: 'App version and legal information',
          onTap: () => _showAboutDialog(),
        ),
        _buildSettingsTile(
          icon: Icons.star_outline_rounded,
          title: 'Rate App',
          subtitle: 'Rate us on the App Store',
          onTap: () => _rateApp(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryPurple,
      ),
    );
  }

  Widget _buildPlatformTile(
    String platform,
    String subtitle,
    String logoAsset,
    bool isConnected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.music_note_rounded,
          color: AppColors.primaryPurple,
          size: 20,
        ),
      ),
      title: Text(
        platform,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      subtitle: Text(
        isConnected ? 'Connected' : subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isConnected ? AppColors.success : AppColors.secondaryText,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isConnected ? AppColors.success : AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          isConnected ? 'Connected' : 'Connect',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: _showSignOutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withOpacity(0.1),
          foregroundColor: AppColors.error,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.error.withOpacity(0.3)),
          ),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    // Navigate to edit profile screen
  }

  void _navigateToMusicPreferences() {
    // Navigate to music preferences screen
  }

  void _navigateToProfileVisibility() {
    // Navigate to profile visibility settings
  }

  void _toggleSpotifyConnection() {
    // Handle Spotify connection toggle
    _showConnectionDialog('Spotify');
  }

  void _toggleAppleMusicConnection() {
    // Handle Apple Music connection toggle
    _showConnectionDialog('Apple Music');
  }

  void _toggleYouTubeMusicConnection() {
    // Handle YouTube Music connection toggle
    _showConnectionDialog('YouTube Music');
  }

  void _toggleSoundCloudConnection() {
    // Handle SoundCloud connection toggle
    _showConnectionDialog('SoundCloud');
  }

  void _navigateToBlockedUsers() {
    // Navigate to blocked users screen
  }

  void _navigateToPrivacySettings() {
    // Navigate to privacy settings screen
  }

  void _downloadUserData() {
    // Handle data download request
    _showInfoDialog(
      'Data Download',
      'Your data download request has been received. You will receive an email with your data within 48 hours.',
    );
  }

  void _navigateToHelpCenter() {
    // Navigate to help center
  }

  void _reportProblem() {
    // Show problem reporting dialog
    _showReportDialog();
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'About Muscta',
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A social music platform that connects music lovers around the world.',
              style: TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2024 Muscta. All rights reserved.',
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // Handle app rating
    _showInfoDialog(
      'Rate App',
      'Thank you for your interest in rating our app! This feature will redirect you to the App Store.',
    );
  }

  void _showConnectionDialog(String platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Connect to $platform',
          style: const TextStyle(color: AppColors.primaryText),
        ),
        content: Text(
          'This will redirect you to $platform to authorize the connection.',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle connection logic
            },
            child: const Text(
              'Connect',
              style: TextStyle(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          title,
          style: const TextStyle(color: AppColors.primaryText),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Report a Problem',
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please describe the issue you\'re experiencing:',
              style: TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: AppColors.primaryText),
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Describe the problem...',
                hintStyle: const TextStyle(color: AppColors.mutedText),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showInfoDialog(
                'Report Sent',
                'Thank you for your feedback. We\'ll look into this issue.',
              );
            },
            child: const Text(
              'Send Report',
              style: TextStyle(color: AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.primaryText),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle sign out logic
              _showInfoDialog(
                'Signed Out',
                'You have been successfully signed out.',
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
