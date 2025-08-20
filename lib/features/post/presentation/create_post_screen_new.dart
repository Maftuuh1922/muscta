import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _musicSearchController = TextEditingController();

  String? _selectedImage;
  MusicTrack? _selectedMusic;
  bool _allowComments = true;
  bool _showPlayCount = true;
  bool _showMusicSearch = false;
  String _musicQuery = '';

  // Mock music data
  final List<MusicTrack> _mockMusic = [
    MusicTrack(
      id: '1',
      title: 'Bohemian Rhapsody',
      artist: 'Queen',
      cover:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
      duration: '5:55',
    ),
    MusicTrack(
      id: '2',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      cover:
          'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=300&h=300&fit=crop',
      duration: '3:20',
    ),
    MusicTrack(
      id: '3',
      title: 'Good 4 U',
      artist: 'Olivia Rodrigo',
      cover:
          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=300&h=300&fit=crop',
      duration: '2:58',
    ),
  ];

  List<MusicTrack> get _filteredMusic {
    if (_musicQuery.isEmpty) return _mockMusic;
    return _mockMusic
        .where(
          (music) =>
              music.title.toLowerCase().contains(_musicQuery.toLowerCase()) ||
              music.artist.toLowerCase().contains(_musicQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _musicSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(),
            if (_showMusicSearch) _buildMusicSearchModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(),
                const SizedBox(height: 24),
                _buildCaptionInput(),
                const SizedBox(height: 24),
                if (_selectedImage != null) ...[
                  _buildSelectedImage(),
                  const SizedBox(height: 24),
                ],
                if (_selectedMusic != null) ...[
                  _buildSelectedMusic(),
                  const SizedBox(height: 24),
                ],
                _buildActionButtons(),
                const SizedBox(height: 24),
                _buildLocationInput(),
                const SizedBox(height: 24),
                _buildPostOptions(),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.close,
              size: 24,
              color: AppColors.primaryText,
            ),
          ),
          const Text(
            'New Post',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          ElevatedButton(
            onPressed: _captionController.text.trim().isNotEmpty
                ? _handlePost
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: AppColors.primaryText,
              disabledBackgroundColor: AppColors.mutedText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text(
              'Share',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
              width: 2,
            ),
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'your_username',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              'Share your music moment',
              style: TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptionInput() {
    return TextField(
      controller: _captionController,
      maxLines: null,
      minLines: 4,
      decoration: const InputDecoration(
        hintText: "What's playing? Share your thoughts about this track...",
        hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 16),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: const TextStyle(
        color: AppColors.primaryText,
        fontSize: 16,
        height: 1.5,
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildSelectedImage() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMusic() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mutedText.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              image: _selectedMusic!.cover != null
                  ? DecorationImage(
                      image: NetworkImage(_selectedMusic!.cover!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _selectedMusic!.cover == null
                ? const Icon(Icons.music_note, color: AppColors.primaryPurple)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMusic!.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedMusic!.artist,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedMusic = null),
            child: const Icon(
              Icons.close,
              color: AppColors.mutedText,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Photo',
            color: AppColors.primaryPurple,
            onTap: _handleCameraSelection,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.image,
            label: 'Gallery',
            color: AppColors.secondaryPurple,
            onTap: _handleGallerySelection,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.music_note,
            label: 'Music',
            color: AppColors.info,
            onTap: () => setState(() => _showMusicSearch = true),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryText,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.location_on_outlined,
              color: AppColors.mutedText,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Add Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: 'Where are you listening?',
            hintStyle: TextStyle(color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.searchBarBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(color: AppColors.primaryText),
        ),
      ],
    );
  }

  Widget _buildPostOptions() {
    return Column(
      children: [
        _buildOptionToggle(
          title: 'Allow comments',
          value: _allowComments,
          onChanged: (value) => setState(() => _allowComments = value),
        ),
        const SizedBox(height: 16),
        _buildOptionToggle(
          title: 'Show play count',
          value: _showPlayCount,
          onChanged: (value) => setState(() => _showPlayCount = value),
        ),
      ],
    );
  }

  Widget _buildOptionToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
        ),
        Container(
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            color: value
                ? AppColors.primaryPurple
                : AppColors.mutedText.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: value ? 20 : 2,
                top: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(onTap: () => onChanged(!value)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMusicSearchModal() {
    return Container(
      color: AppColors.primaryBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Music',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showMusicSearch = false),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.searchBarBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _musicSearchController,
                onChanged: (value) => setState(() => _musicQuery = value),
                decoration: const InputDecoration(
                  hintText: 'Search for songs or artists...',
                  hintStyle: TextStyle(color: AppColors.mutedText),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.mutedText,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: AppColors.primaryText),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredMusic.length,
              itemBuilder: (context, index) {
                final music = _filteredMusic[index];
                return GestureDetector(
                  onTap: () => _handleMusicSelect(music),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.mutedText.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            image: music.cover != null
                                ? DecorationImage(
                                    image: NetworkImage(music.cover!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: music.cover == null
                              ? const Icon(
                                  Icons.music_note,
                                  color: AppColors.primaryPurple,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                music.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                music.artist,
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          music.duration,
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleCameraSelection() {
    setState(() {
      _selectedImage =
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400&h=400&fit=crop';
    });
  }

  void _handleGallerySelection() {
    setState(() {
      _selectedImage =
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400&h=400&fit=crop';
    });
  }

  void _handleMusicSelect(MusicTrack music) {
    setState(() {
      _selectedMusic = music;
      _showMusicSearch = false;
      _musicQuery = '';
    });
    _musicSearchController.clear();
  }

  void _handlePost() {
    print('Posting: ${_captionController.text}');
    print('Image: $_selectedImage');
    print('Music: ${_selectedMusic?.title}');
    print('Location: ${_locationController.text}');

    // Reset form
    _captionController.clear();
    _locationController.clear();
    setState(() {
      _selectedImage = null;
      _selectedMusic = null;
    });

    Navigator.of(context).pop();
  }
}

// Data model
class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String? cover;
  final String duration;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.cover,
    required this.duration,
  });
}
