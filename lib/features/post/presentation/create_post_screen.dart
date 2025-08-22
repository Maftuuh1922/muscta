import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/post/post_service.dart';
import '../widgets/music_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _pageController = PageController();
  
  XFile? _selectedImage;
  bool _loading = false;
  String? _error;
  MusicSelection? _selectedMusic;
  int _currentPage = 0;
  
  // Additional Instagram-like features
  bool _enableComments = true;
  bool _showLikeCount = true;
  String? _selectedLocation;
  List<String> _taggedUsers = [];

  @override
  void initState() {
    super.initState();
    // Auto-open image picker on screen load for Instagram-like flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage();
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    // Show bottom sheet for image source selection
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ImageSourceSheet(),
    );
    
    if (source == null) {
      if (mounted && _selectedImage == null) {
        Navigator.pop(context);
      }
      return;
    }
    
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1350,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _currentPage = 1; // Move to edit page
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_selectedImage == null && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _createPost() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await PostService().createPost(
        musicTitle: _selectedMusic?.title,
        musicArtist: _selectedMusic?.artist,
        musicAlbumCover: _selectedMusic?.albumCover,
        musicDuration: _selectedMusic != null 
            ? _formatMs(_selectedMusic!.durationMs)
            : null,
        caption: _captionController.text.trim(),
        imageFile: _selectedImage,
        spotifyId: _selectedMusic?.spotifyId,
        previewUrl: _selectedMusic?.previewUrl,
        clipStartMs: _selectedMusic?.clipStartMs,
        clipDurationMs: _selectedMusic?.clipDurationMs,
      );
      
      // TODO: Simpan data tambahan ke database terpisah jika diperlukan
      // Contoh: location, taggedUsers, commentsEnabled, likesVisible
      // Bisa disimpan di collection/table terpisah atau update PostService

      if (mounted) {
        // Show success animation before closing
        _showSuccessAnimation();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'Dibagikan!',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pop(true); // Close screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),
            
            // Progress Indicator
            if (_currentPage > 0) _buildProgressIndicator(),
            
            // Main Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Page 0: Image Selection (auto-triggered)
                  Container(),
                  
                  // Page 1: Edit & Filters
                  _buildEditPage(),
                  
                  // Page 2: Caption & Details
                  _buildDetailsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_currentPage > 1) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              _currentPage > 1 ? Icons.arrow_back : Icons.close,
              color: AppColors.primaryText,
            ),
          ),
          Expanded(
            child: Text(
              _currentPage == 0
                  ? 'Postingan Baru'
                  : _currentPage == 1
                  ? 'Edit'
                  : 'Bagikan',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_currentPage == 1)
            TextButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Selanjutnya',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            )
          else if (_currentPage == 2)
            TextButton(
              onPressed: _loading ? null : _createPost,
              child: _loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      'Bagikan',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          2,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < _currentPage
                    ? AppColors.primary
                    : AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditPage() {
    if (_selectedImage == null) return Container();
    
    return Column(
      children: [
        // Image Preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        
        // Music Selection
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_selectedMusic != null) ...[
                _buildSelectedMusicCard(),
                const SizedBox(height: 12),
              ],
              
              // Add Music Button
              GestureDetector(
                onTap: () async {
                  final selection = await showMusicPicker(context);
                  if (selection != null) {
                    setState(() {
                      _selectedMusic = selection;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedMusic == null
                              ? 'Tambahkan musik'
                              : 'Ganti musik',
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.mutedText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPage() {
    final user = FirebaseAuth.instance.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Preview Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Thumbnail
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                
                // Caption Field
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: 4,
                    style: TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      hintText: 'Tulis keterangan...',
                      hintStyle: TextStyle(color: AppColors.mutedText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Music Info
          if (_selectedMusic != null) ...[
            _buildSelectedMusicCard(),
            const SizedBox(height: 16),
          ],
          
          // Instagram-like Options
          _buildOptionTile(
            icon: Icons.person_outline,
            title: 'Tandai orang',
            onTap: () {
              // Implement tag people functionality
            },
          ),
          _buildOptionTile(
            icon: Icons.location_on_outlined,
            title: 'Tambahkan lokasi',
            subtitle: _selectedLocation,
            onTap: () {
              // Implement location picker
            },
          ),
          
          const Divider(color: AppColors.borderColor),
          
          // Advanced Settings
          _buildSwitchTile(
            title: 'Sembunyikan jumlah suka',
            value: !_showLikeCount,
            onChanged: (value) {
              setState(() {
                _showLikeCount = !value;
              });
            },
          ),
          _buildSwitchTile(
            title: 'Matikan komentar',
            value: !_enableComments,
            onChanged: (value) {
              setState(() {
                _enableComments = !value;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Also Share To Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juga bagikan ke',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSocialButton('Facebook', Icons.facebook),
                    const SizedBox(width: 12),
                    _buildSocialButton('Twitter', Icons.share),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMusicCard() {
    if (_selectedMusic == null) return Container();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _selectedMusic!.albumCover.isNotEmpty
                ? Image.network(
                    _selectedMusic!.albumCover,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: AppColors.borderColor,
                    child: Icon(
                      Icons.music_note,
                      color: AppColors.mutedText,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMusic!.title,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _selectedMusic!.artist,
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.mutedText,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _selectedMusic = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryText),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.mutedText, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.camera_alt, color: AppColors.primaryText),
            title: Text(
              'Kamera',
              style: TextStyle(color: AppColors.primaryText),
            ),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: AppColors.primaryText),
            title: Text(
              'Galeri',
              style: TextStyle(color: AppColors.primaryText),
            ),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

String _formatMs(int ms) {
  final d = Duration(milliseconds: ms);
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}