class AppConstants {
  // App Info
  static const String appName = 'MUSCTA';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Music Social Media App like Instagram for music lovers';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double borderRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 8.0;
  
  // Music Constants
  static const int musicPreviewDuration = 30; // seconds
  static const int maxPlaylistTracks = 100;
  static const int maxPostImages = 10;
  
  // Social Constants
  static const int maxCommentLength = 500;
  static const int maxPostCaptionLength = 2200;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;
  
  // Chat Constants
  static const int maxGroupMembers = 50;
  static const int maxMessageLength = 1000;
  static const int maxVoiceMessageDuration = 120; // seconds
  
  // API Constants
  static const String baseUrl = 'https://api.muscta.com';
  static const String spotifyBaseUrl = 'https://api.spotify.com/v1';
  static const String appleMusicBaseUrl = 'https://api.music.apple.com/v1';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String followsCollection = 'follows';
  static const String likesCollection = 'likes';
  static const String notificationsCollection = 'notifications';
  static const String playlistsCollection = 'playlists';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';
  static const String chatImagesPath = 'chat_images';
  static const String audioFilesPath = 'audio_files';
  
  // Shared Preferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String musicQualityKey = 'music_quality';
  static const String notificationsEnabledKey = 'notifications_enabled';
  
  // Music Platform IDs
  static const String spotifyClientId = 'your_spotify_client_id';
  static const String appleMusicDeveloperToken = 'your_apple_music_token';
  static const String youtubeMusicApiKey = 'your_youtube_music_api_key';
  
  // Error Messages
  static const String networkError = 'No internet connection. Please check your network and try again.';
  static const String serverError = 'Something went wrong. Please try again later.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String permissionError = 'Permission denied. Please allow access in settings.';
  
  // Success Messages
  static const String postCreatedSuccess = 'Post created successfully!';
  static const String profileUpdatedSuccess = 'Profile updated successfully!';
  static const String passwordChangedSuccess = 'Password changed successfully!';
  
  // Music Genres
  static const List<String> musicGenres = [
    'Pop',
    'Rock',
    'Hip-Hop',
    'Jazz',
    'Classical',
    'Electronic',
    'Country',
    'R&B',
    'Alternative',
    'Indie',
    'Folk',
    'Blues',
    'Reggae',
    'Metal',
    'Funk',
    'Soul',
    'Disco',
    'House',
    'Techno',
    'Dubstep',
  ];
  
  // Popular Hashtags
  static const List<String> popularHashtags = [
    '#newmusic',
    '#indie',
    '#rock',
    '#pop',
    '#jazz',
    '#electronic',
    '#hiphop',
    '#alternative',
    '#classical',
    '#folk',
    '#metal',
    '#rnb',
    '#country',
    '#blues',
    '#reggae',
    '#nowplaying',
    '#musiclover',
    '#songwriter',
    '#producer',
    '#musician',
  ];
}

class AppImages {
  static const String _imagesPath = 'assets/images';
  
  static const String logo = '$_imagesPath/logo.png';
  static const String logoIcon = '$_imagesPath/logo_icon.png';
  static const String placeholder = '$_imagesPath/placeholder.png';
  static const String avatarPlaceholder = '$_imagesPath/avatar_placeholder.png';
  static const String albumPlaceholder = '$_imagesPath/album_placeholder.png';
  static const String musicWave = '$_imagesPath/music_wave.png';
  static const String onboardingMusic = '$_imagesPath/onboarding_music.png';
  static const String onboardingSocial = '$_imagesPath/onboarding_social.png';
  static const String onboardingDiscover = '$_imagesPath/onboarding_discover.png';
}

class AppIcons {
  static const String _iconsPath = 'assets/icons';
  
  // Bottom Navigation Icons
  static const String homeIcon = '$_iconsPath/home.svg';
  static const String searchIcon = '$_iconsPath/search.svg';
  static const String postIcon = '$_iconsPath/post.svg';
  static const String activityIcon = '$_iconsPath/activity.svg';
  static const String profileIcon = '$_iconsPath/profile.svg';
  
  // Music Icons
  static const String playIcon = '$_iconsPath/play.svg';
  static const String pauseIcon = '$_iconsPath/pause.svg';
  static const String nextIcon = '$_iconsPath/next.svg';
  static const String previousIcon = '$_iconsPath/previous.svg';
  static const String shuffleIcon = '$_iconsPath/shuffle.svg';
  static const String repeatIcon = '$_iconsPath/repeat.svg';
  static const String volumeIcon = '$_iconsPath/volume.svg';
  static const String musicNoteIcon = '$_iconsPath/music_note.svg';
  static const String waveformIcon = '$_iconsPath/waveform.svg';
  
  // Social Icons
  static const String likeIcon = '$_iconsPath/like.svg';
  static const String commentIcon = '$_iconsPath/comment.svg';
  static const String shareIcon = '$_iconsPath/share.svg';
  static const String bookmarkIcon = '$_iconsPath/bookmark.svg';
  static const String followIcon = '$_iconsPath/follow.svg';
  static const String repostIcon = '$_iconsPath/repost.svg';
  
  // General Icons
  static const String settingsIcon = '$_iconsPath/settings.svg';
  static const String editIcon = '$_iconsPath/edit.svg';
  static const String deleteIcon = '$_iconsPath/delete.svg';
  static const String cameraIcon = '$_iconsPath/camera.svg';
  static const String galleryIcon = '$_iconsPath/gallery.svg';
  static const String locationIcon = '$_iconsPath/location.svg';
  static const String notificationIcon = '$_iconsPath/notification.svg';
  static const String menuIcon = '$_iconsPath/menu.svg';
  static const String closeIcon = '$_iconsPath/close.svg';
  
  // Platform Icons
  static const String spotifyIcon = '$_iconsPath/spotify.svg';
  static const String appleMusicIcon = '$_iconsPath/apple_music.svg';
  static const String youtubeMusicIcon = '$_iconsPath/youtube_music.svg';
  static const String soundcloudIcon = '$_iconsPath/soundcloud.svg';
}

class AppAnimations {
  static const String _animationsPath = 'assets/animations';
  
  static const String loading = '$_animationsPath/loading.json';
  static const String musicLoading = '$_animationsPath/music_loading.json';
  static const String likeAnimation = '$_animationsPath/like_animation.json';
  static const String waveform = '$_animationsPath/waveform.json';
  static const String musicVisualizer = '$_animationsPath/music_visualizer.json';
  static const String emptyState = '$_animationsPath/empty_state.json';
  static const String error = '$_animationsPath/error.json';
  static const String success = '$_animationsPath/success.json';
}
