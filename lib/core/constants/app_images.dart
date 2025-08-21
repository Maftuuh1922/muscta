class AppImages {
  // Placeholder images - tidak menggunakan network image untuk menghindari error
  static const String defaultProfileImage = '';
  
  // User profile placeholders - kosongkan untuk gunakan fallback
  static const List<String> profilePlaceholders = [
    '',
    '',
    '',
    '',
    '',
    '',
  ];
  
  // Music/Album cover placeholders - kosongkan untuk gunakan fallback
  static const List<String> albumPlaceholders = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
  ];
  
  // Get random profile placeholder - return empty untuk fallback ke Icon
  static String getRandomProfilePlaceholder() {
    return '';
  }
  
  // Get random album placeholder - return empty untuk fallback ke Icon
  static String getRandomAlbumPlaceholder() {
    return '';
  }
}

// Fallback untuk ketika semua gagal - gunakan Icon dan Colors
class LocalPlaceholders {
  static const String profileIcon = '👤';
  static const String musicIcon = '🎵';
  static const String albumIcon = '🎧';
  static const String defaultColor = 'E91E63';
}
