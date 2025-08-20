import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/post/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _musicTitleController = TextEditingController();
  final _musicArtistController = TextEditingController();
  final _musicDurationController = TextEditingController();
  final _albumCoverUrlController = TextEditingController();
  
  XFile? _selectedImage;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Set default values
    _musicDurationController.text = '3:45';
    _albumCoverUrlController.text = 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop';
  }

  @override
  void dispose() {
    _captionController.dispose();
    _musicTitleController.dispose();
    _musicArtistController.dispose();
    _musicDurationController.dispose();
    _albumCoverUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1080, imageQuality: 85);
    if (image != null) {
      setState(() { _selectedImage = image; });
    }
  }

  Future<void> _createPost() async {
    if (_musicTitleController.text.trim().isEmpty || _musicArtistController.text.trim().isEmpty) {
      setState(() { _error = 'Please enter music title and artist'; });
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await PostService().createPost(
        musicTitle: _musicTitleController.text.trim(),
        musicArtist: _musicArtistController.text.trim(),
        musicAlbumCover: _albumCoverUrlController.text.trim(),
        musicDuration: _musicDurationController.text.trim(),
        caption: _captionController.text.trim(),
        imageFile: _selectedImage,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text('Create Post', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppColors.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _createPost,
            child: _loading 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              : const Text('Share', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user?.photoURL != null 
                    ? NetworkImage(user!.photoURL!) 
                    : null,
                  child: user?.photoURL == null 
                    ? Text(user?.displayName?.substring(0, 1).toUpperCase() ?? 'U') 
                    : null,
                ),
                const SizedBox(width: 12),
                Text(
                  user?.displayName ?? 'Unknown User',
                  style: const TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Error message
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14)),
              ),
              const SizedBox(height: 16),
            ],
            
            // Caption
            const Text('Caption', style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Share your music thoughts...',
                hintStyle: const TextStyle(color: AppColors.mutedText),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Music Info
            const Text('Music Track', style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _musicTitleController,
                    style: const TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Song Title *',
                      labelStyle: const TextStyle(color: AppColors.mutedText),
                      hintText: 'Bohemian Rhapsody',
                      hintStyle: const TextStyle(color: AppColors.mutedText),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryPurple),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _musicArtistController,
                    style: const TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Artist *',
                      labelStyle: const TextStyle(color: AppColors.mutedText),
                      hintText: 'Queen',
                      hintStyle: const TextStyle(color: AppColors.mutedText),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryPurple),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _musicDurationController,
                    style: const TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Duration',
                      labelStyle: const TextStyle(color: AppColors.mutedText),
                      hintText: '3:45',
                      hintStyle: const TextStyle(color: AppColors.mutedText),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryPurple),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _albumCoverUrlController,
                    style: const TextStyle(color: AppColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Album Cover URL',
                      labelStyle: const TextStyle(color: AppColors.mutedText),
                      hintText: 'https://...',
                      hintStyle: const TextStyle(color: AppColors.mutedText),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryPurple),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Image picker
            const Text('Add Photo (Optional)', style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: _selectedImage != null ? 200 : 100,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: _selectedImage != null 
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() { _selectedImage = null; }),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, color: AppColors.mutedText, size: 32),
                        SizedBox(height: 8),
                        Text('Tap to add photo', style: TextStyle(color: AppColors.mutedText, fontSize: 14)),
                      ],
                    ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}