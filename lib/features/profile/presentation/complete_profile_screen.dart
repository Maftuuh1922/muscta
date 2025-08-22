import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/user/user_service.dart';
import '../../../services/offline_user_service.dart';
import '../../../services/firebase_test.dart';
import '../../../services/auth_gate.dart';
import '../../../shared/widgets/spotify_connect_widget.dart';
import '../../../services/spotify/spotify_service.dart';
import '../../../services/deep_link/deep_link_handler.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _spotifyConnected = false;
  
  // Music preferences from Spotify
  List<String> _selectedGenres = [];
  List<String> _selectedTopArtists = [];
  
  final ImagePicker _imagePicker = ImagePicker();

  // Available music genres (same as edit profile)
  final List<String> _availableGenres = [
    'Rock', 'Pop', 'Hip Hop', 'Jazz', 'Classical', 'Electronic',
    'Country', 'R&B', 'Indie', 'Alternative', 'Metal', 'Folk',
    'Reggae', 'Blues', 'Punk', 'Funk', 'Soul', 'Disco'
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  _checkSpotifyEarly();
    // Listen for deep link spotify_connected event
    DeepLinkHandler.onEvent.listen((event) async {
      if (event == 'spotify_connected' && mounted) {
        setState(() => _spotifyConnected = true);
        await _loadGenresFromSpotify();
      }
    });
    
    // Test Firebase connections on debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      FirebaseTestService.testFirebaseConnections();
      FirebaseTestService.testImageUpload();
    }
  }

  Future<void> _checkSpotifyEarly() async {
    try {
      final connected = await SpotifyService.isConnected();
      if (!mounted) return;
      setState(() {
        _spotifyConnected = connected;
      });
      if (connected) {
        await _loadGenresFromSpotify();
      }
    } catch (_) {}
  }

  void _initializeUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fullNameController.text = user.displayName ?? '';
      _usernameController.text = user.displayName?.toLowerCase().replaceAll(' ', '_') ?? '';
    }
  }

  void _onSpotifyDataLoaded(List<String> topArtists, List<Map<String, dynamic>> topTracks) async {
    setState(() {
      _selectedTopArtists = topArtists;
      _spotifyConnected = true;
    });
    await _loadGenresFromSpotify();
  }

  Future<void> _loadGenresFromSpotify() async {
    try {
      final artists = await SpotifyService.getTopArtists(limit: 20);
      final Map<String, int> genreCount = {};
      for (final a in artists) {
        final gs = (a['genres'] as List?)?.cast<String>() ?? const <String>[];
        for (final g in gs) {
          genreCount[g.toLowerCase()] = (genreCount[g.toLowerCase()] ?? 0) + 1;
        }
      }
      if (genreCount.isEmpty) return;
      // Map Spotify genres to our available list (case-insensitive)
      final Map<String, int> mapped = {};
      for (final entry in genreCount.entries) {
        final match = _availableGenres.firstWhere(
          (ag) => ag.toLowerCase() == entry.key,
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          mapped[match] = (mapped[match] ?? 0) + entry.value;
        }
      }
      if (mapped.isEmpty) return;
      final sorted = mapped.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      setState(() {
        _selectedGenres = sorted.map((e) => e.key).take(5).toList();
      });
    } catch (e) {
      // Silent fail; user can still pick manually
    }
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else if (_selectedGenres.length < 5) {
        _selectedGenres.add(genre);
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      print('Starting profile completion for user: ${user.uid}');
      
      // Try online first, fallback to offline
      bool onlineSuccess = false;
      
      try {
        // Try online mode with short timeout
        await UserService().createOrUpdateUserProfile(
          userId: user.uid,
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          bio: _bioController.text.trim(),
          profileImage: _selectedImage,
          genres: _selectedGenres,
          topArtists: _selectedTopArtists,
        );
        onlineSuccess = true;
        print('✅ Online profile creation successful');
      } catch (onlineError) {
        print('❌ Online mode failed: $onlineError');
        print('🔄 Switching to offline mode...');
        
        // Fallback to offline mode
        await OfflineUserService.createOrUpdateUserProfileOffline(
          userId: user.uid,
          username: _usernameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          bio: _bioController.text.trim(),
          profileImage: _selectedImage,
          genres: _selectedGenres,
          topArtists: _selectedTopArtists,
        );
        print('✅ Offline profile creation successful');
      }

      print('Profile completion successful, navigating to main screen...');
      
      // Ensure local storage is saved properly
      if (!onlineSuccess) {
        // Double-check offline storage was successful
        await Future.delayed(const Duration(milliseconds: 200));
        final savedProfile = await OfflineUserService.getCurrentUserProfile();
        print('Saved profile verification: ${savedProfile != null ? "✅ Success" : "❌ Failed"}');
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(onlineSuccess 
              ? 'Profile completed successfully!' 
              : 'Profile saved locally - will sync when online!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Longer delay to ensure data is saved and AuthGate refreshes properly
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Clear AuthGate cache to force profile recheck
        AuthGate.clearProfileCache();
        
        // Set a flag that profile was just completed
        AuthGate.setProfileJustCompleted();
        
        // Navigate back to root (AuthGate)
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } catch (e) {
      print('Profile completion error: $e');
      if (mounted) {
        _showErrorSnackBar('Error completing profile: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildForm(),
                    const SizedBox(height: 32),
                    
                    // Music Preferences Section
                    _buildMusicPreferencesSection(),
                    const SizedBox(height: 32),
                    
                    // Spotify Connection Widget
                    SpotifyConnectWidget(
                      onDataLoaded: _onSpotifyDataLoaded,
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Complete Profile Button
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!_spotifyConnected)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Harus connect ke Spotify untuk lanjut',
                        style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                      ),
                    ),
                  _buildCompleteButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set up your music profile and preferences',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildProfilePicture(),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _usernameController,
            label: 'Username',
            hint: 'Choose a unique username',
            icon: Icons.alternate_email,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username is required';
              }
              if (value.trim().length < 3) {
                return 'Username must be at least 3 characters';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                return 'Username can only contain letters, numbers, and underscores';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _bioController,
            label: 'Bio',
            hint: 'Tell us about your music taste...',
            icon: Icons.music_note_outlined,
            maxLines: 3,
            validator: null,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
              ),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
            ),
            child: _selectedImage != null
                ? CircleAvatar(
                    radius: 58,
                    backgroundImage: FileImage(_selectedImage!),
                  )
                : FirebaseAuth.instance.currentUser?.photoURL != null
                    ? CircleAvatar(
                        radius: 58,
                        backgroundImage: _getImageProvider(FirebaseAuth.instance.currentUser!.photoURL!),
                        child: _getImageProvider(FirebaseAuth.instance.currentUser!.photoURL!) == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              )
                            : null,
                      )
                    : const Icon(
                        Icons.add_a_photo_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to add profile picture',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.mutedText),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
  onPressed: (_isLoading || !_spotifyConnected) ? null : _completeProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Setting up your profile...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Text(
                _spotifyConnected ? 'Complete Profile' : 'Connect Spotify terlebih dulu',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicPreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Music Preferences', Icons.music_note, AppColors.secondary),
          const Text(
            'Favorite Genres (Select up to 5)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableGenres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);
              return GestureDetector(
                onTap: () => _toggleGenre(genre),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Selected: ${_selectedGenres.length}/5',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  ImageProvider? _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }
    if (imageUrl.startsWith('file://')) {
      try {
        final file = File.fromUri(Uri.parse(imageUrl));
        if (file.existsSync()) return FileImage(file);
      } catch (_) {}
    }
    if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);
      if (file.existsSync()) return FileImage(file);
    }
    return null;
  }
}
