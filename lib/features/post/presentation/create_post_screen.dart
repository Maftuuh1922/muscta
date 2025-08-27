import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
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
  double _clipStart = 0.0;
  bool _addAiLabel = false;
  
  // Gallery related variables
  List<AssetEntity> _mediaList = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;
  String _selectedPostType = 'POSTINGAN';
  bool _multiSelect = false;
  List<AssetEntity> _selectedAssets = [];
  
  // Additional Instagram-like features
  bool _enableComments = true;
  bool _showLikeCount = true;
  String? _selectedLocation;
  List<String> _taggedUsers = [];
  String _audience = 'Pengikut';

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadGallery() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      // Tampilkan dialog ke user untuk mengaktifkan permission di settings
      PhotoManager.openSetting();
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
    );
    
    if (albums.isNotEmpty) {
      final recentAlbum = albums.first;
      final media = await recentAlbum.getAssetListPaged(
        page: 0,
        size: 100,
      );
      
      setState(() {
        _albums = albums;
        _selectedAlbum = recentAlbum;
        _mediaList = media;
      });
    }
  }

  Future<void> _selectImage(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      setState(() {
        _selectedImage = XFile(file.path);
        _currentPage = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
        clipStartMs: (_clipStart * 1000).toInt(),
        clipDurationMs: 30000,
      );

      if (mounted) {
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
      Navigator.of(context).pop();
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (_currentPage > 0) _buildProgressIndicator(),
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
                  _buildGalleryPage(),
                  _buildEditPage(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentPage > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(
              _currentPage == 1 ? Icons.close : (_currentPage > 1 ? Icons.arrow_back : Icons.close),
              color: Colors.white,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              _currentPage == 0
                  ? 'Postingan baru'
                  : _currentPage == 1
                  ? ''
                  : 'Postingan baru',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_currentPage == 0)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _multiSelect = !_multiSelect;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white54),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _multiSelect ? Icons.check_box : Icons.crop_square,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PILIH BEBERAPA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Open camera
                    _openCamera();
                  },
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            )
          else if (_currentPage == 1)
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
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGalleryPage() {
    return Column(
      children: [
        // Album selector
        if (_selectedAlbum != null)
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showAlbumPicker,
                    child: Row(
                      children: [
                        Text(
                          _selectedAlbum!.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Image Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: _mediaList.length,
            itemBuilder: (context, index) {
              final asset = _mediaList[index];
              final isSelected = _selectedAssets.contains(asset);
              
              return GestureDetector(
                onTap: () {
                  if (_multiSelect) {
                    setState(() {
                      if (isSelected) {
                        _selectedAssets.remove(asset);
                      } else {
                        _selectedAssets.add(asset);
                      }
                    });
                  } else {
                    _selectImage(asset);
                  }
                },
                child: Stack(
                  children: [
                    // Image
                    AssetEntityImage(
                      asset,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      isOriginal: false,
                    ),
                    
                    // Video indicator
                    if (asset.type == AssetType.video)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    
                    // Selection indicator
                    if (_multiSelect)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                    
                    // Selection overlay
                    if (_multiSelect && isSelected)
                      Container(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Bottom tab bar
        Container(
          height: 80,
          color: Colors.black,
          child: Column(
            children: [
              Container(
                height: 1,
                color: Colors.grey[800],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomTab('POSTINGAN', _selectedPostType == 'POSTINGAN'),
                    _buildBottomTab('CERITA', _selectedPostType == 'CERITA'),
                    _buildBottomTab('REEL', _selectedPostType == 'REEL'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPostType = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _showAlbumPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Pilih Album',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    final album = _albums[index];
                    return ListTile(
                      leading: FutureBuilder<List<AssetEntity>>(
                        future: album.getAssetListRange(start: 0, end: 1),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AssetEntityImage(
                                snapshot.data!.first,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[800],
                            child: Icon(Icons.image, color: Colors.grey[600]),
                          );
                        },
                      ),
                      title: Text(
                        album.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: FutureBuilder<int>(
                        future: album.assetCountAsync,
                        builder: (context, snapshot) {
                          return Text(
                            '${snapshot.data ?? 0}',
                            style: TextStyle(color: Colors.grey[400]),
                          );
                        },
                      ),
                      onTap: () async {
                        final media = await album.getAssetListPaged(
                          page: 0,
                          size: 100,
                        );
                        setState(() {
                          _selectedAlbum = album;
                          _mediaList = media;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1350,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _currentPage = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          3,
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
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        
        if (_selectedMusic != null)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSelectedMusicCard(),
                const SizedBox(height: 8),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.yellow, Colors.purple],
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(10, (index) => Container(
                      width: 4,
                      height: 10 + (index % 5 * 6),
                      color: Colors.white,
                    )),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('0', style: TextStyle(color: AppColors.primaryText)),
                    Expanded(
                      child: Slider(
                        value: _clipStart,
                        min: 0,
                        max: (_selectedMusic!.durationMs / 1000) - 30,
                        onChanged: (value) {
                          setState(() {
                            _clipStart = value;
                          });
                        },
                        activeColor: Colors.pink,
                        inactiveColor: Colors.grey,
                        thumbColor: Colors.white,
                      ),
                    ),
                    Icon(Icons.stop_circle, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            border: Border(top: BorderSide(color: AppColors.borderColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabButton('Audio', Icons.music_note, () async {
                final selection = await showMusicPicker(context);
                if (selection != null) {
                  setState(() {
                    _selectedMusic = selection;
                  });
                }
              }),
              _buildTabButton('Teks', Icons.text_fields, () {}),
              _buildTabButton('Overlay', Icons.layers, () {}),
              _buildTabButton('Filter', Icons.filter, () {}),
              _buildTabButton('Edit', Icons.edit, () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryText),
          Text(
            label,
            style: TextStyle(color: AppColors.primaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
          
          if (_selectedMusic != null) ...[
            _buildSelectedMusicCard(),
            const SizedBox(height: 16),
          ],
          
          _buildOptionTile(
            icon: Icons.person_outline,
            title: 'Tandai orang',
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.location_on_outlined,
            title: 'Tambahkan lokasi',
            subtitle: _selectedLocation ?? '',
            onTap: () {},
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(Icons.label_outline, color: AppColors.primaryText),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambahkan Label AI',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Kami mewajibkan Anda melabeli konten realistis tertentu yang dibuat dengan AI. Pelajari selengkapnya',
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _addAiLabel,
                  onChanged: (value) {
                    setState(() {
                      _addAiLabel = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          
          const Divider(color: AppColors.borderColor),
          
          _buildOptionTile(
            icon: Icons.visibility_outlined,
            title: 'Pemirsa',
            subtitle: _audience,
            onTap: () {},
          ),
          
          _buildOptionTile(
            icon: Icons.share_outlined,
            title: 'Juga bagikan ke...',
            subtitle: 'Nonaktif',
            badge: 'BARU',
            onTap: () {},
          ),
          
          _buildOptionTile(
            icon: Icons.more_horiz,
            title: 'Opsi lainnya',
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Bagikan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    String? badge,
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
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 14,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
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
}

String _formatMs(int ms) {
  final d = Duration(milliseconds: ms);
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}