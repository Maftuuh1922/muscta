import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/user/user_service.dart';
import '../../../shared/widgets/placeholder_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final String? displayName;
  final String? username;
  final String? bio;
  final String? website;
  final String? profileImageUrl;
  final List<String>? genres;

  const EditProfileScreen({
    super.key,
    this.displayName,
    this.username,
    this.bio,
    this.website,
    this.profileImageUrl,
    this.genres,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  
  bool _saving = false;
  bool _isUploading = false;
  bool _hasChanges = false;
  String? _error;
  File? _selectedImage;
  late List<String> _selectedGenres;
  
  // Privacy settings
  bool _privateAccount = false;
  bool _showOnlineStatus = true;
  bool _allowTagging = true;
  bool _showMusicActivity = true;

  final ImagePicker _imagePicker = ImagePicker();

  // Available music genres
  final List<String> _availableGenres = [
    'Rock', 'Pop', 'Hip Hop', 'Jazz', 'Classical', 'Electronic',
    'Country', 'R&B', 'Indie', 'Alternative', 'Metal', 'Folk',
    'Reggae', 'Blues', 'Punk', 'Funk', 'Soul', 'Disco'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.displayName ?? '');
    _usernameController = TextEditingController(text: widget.username ?? '');
    _bioController = TextEditingController(text: widget.bio ?? '');
    _websiteController = TextEditingController(text: widget.website ?? '');
    _selectedGenres = List.from(widget.genres ?? []);
    
    // Add listeners to detect changes
    _nameController.addListener(_onTextChanged);
    _usernameController.addListener(_onTextChanged);
    _bioController.addListener(_onTextChanged);
    _websiteController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
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
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else if (_selectedGenres.length < 5) {
        _selectedGenres.add(genre);
      }
      _hasChanges = true;
    });
  }

  void _togglePrivacySetting(String setting, bool value) {
    setState(() {
      switch (setting) {
        case 'privateAccount':
          _privateAccount = value;
          break;
        case 'showOnlineStatus':
          _showOnlineStatus = value;
          break;
        case 'allowTagging':
          _allowTagging = value;
          break;
        case 'showMusicActivity':
          _showMusicActivity = value;
          break;
      }
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    if (!_hasChanges) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    final rawUsername = _usernameController.text.trim();
    final normalized = rawUsername.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    
    if (normalized.isEmpty) {
      setState(() {
        _saving = false;
        _error = 'Username cannot be empty';
      });
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await UserService().createOrUpdateUserProfile(
          userId: user.uid,
          username: normalized,
          fullName: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          profileImage: _selectedImage,
          genres: _selectedGenres,
        );
        
        // Also update basic profile info
        await UserService().updateProfile(
          displayName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
          username: normalized,
          bio: _bioController.text.trim(),
          website: _websiteController.text.trim(),
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.mutedText.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
        ),
        if (label == 'Username')
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Username can only contain letters, numbers, and underscores',
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required String settingKey,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (newValue) => _togglePrivacySetting(settingKey, newValue),
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _hasChanges && !_saving ? _save : null,
              style: TextButton.styleFrom(
                backgroundColor: _hasChanges 
                    ? AppColors.primary 
                    : AppColors.mutedText.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: _hasChanges ? Colors.white : AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message
            if (_error != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),

            // Profile Photo Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderColor)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 4,
                            ),
                          ),
                          child: _selectedImage != null
                              ? CircleAvatar(
                                  radius: 48,
                                  backgroundImage: FileImage(_selectedImage!),
                                )
                              : ProfilePlaceholder(
                                  size: 96,
                                  imageUrl: widget.profileImageUrl,
                                ),
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Change Profile Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG, PNG up to 10MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),

            // Basic Information Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Basic Information', Icons.person, AppColors.primary),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Name',
                    hint: 'Enter your name',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Enter your username',
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Bio',
                    hint: 'Tell people about yourself...',
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _websiteController,
                    label: 'Website',
                    hint: 'Enter your website URL',
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
            ),

            // Music Preferences Section
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              padding: const EdgeInsets.all(24),
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
            ),

            // Privacy Settings Section
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Privacy Settings', Icons.lock, AppColors.accent),
                  _buildPrivacyToggle(
                    title: 'Private Account',
                    subtitle: 'When your account is private, only followers can see your posts',
                    value: _privateAccount,
                    settingKey: 'privateAccount',
                  ),
                  const SizedBox(height: 12),
                  _buildPrivacyToggle(
                    title: 'Show Online Status',
                    subtitle: 'Let others see when you\'re active',
                    value: _showOnlineStatus,
                    settingKey: 'showOnlineStatus',
                  ),
                  const SizedBox(height: 12),
                  _buildPrivacyToggle(
                    title: 'Allow Tagging',
                    subtitle: 'Let others tag you in their posts',
                    value: _allowTagging,
                    settingKey: 'allowTagging',
                  ),
                  const SizedBox(height: 12),
                  _buildPrivacyToggle(
                    title: 'Show Music Activity',
                    subtitle: 'Share your listening activity with followers',
                    value: _showMusicActivity,
                    settingKey: 'showMusicActivity',
                  ),
                ],
              ),
            ),

            // Action Buttons Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Show disable account dialog
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Temporarily Disable Account',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Download data functionality
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.mutedText),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Download Your Data',
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }
}
