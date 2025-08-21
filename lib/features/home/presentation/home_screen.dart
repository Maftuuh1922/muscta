import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/post/post_service.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../post/presentation/create_post_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String? _currentlyPlaying;
  late AnimationController _marqueeController;

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
          if (result == true) {
            // Post created successfully, refresh UI if needed
            setState(() {});
          }
        },
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: PostService().getTimelinePosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryPurple),
                  );
                }

                if (snapshot.hasError) {
                  // Show demo posts if Firestore is not available
                  final demoData = _getDemoData();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: demoData.length,
                    itemBuilder: (context, index) {
                      final postData = demoData[index];
                      return _buildPostCard(postData);
                    },
                  );
                }

                final posts = snapshot.data ?? [];
                
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.music_note_outlined, color: AppColors.mutedText, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'No posts yet',
                          style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Be the first to share your music!',
                          style: TextStyle(color: AppColors.mutedText, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                            );
                            if (result == true) {
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Create Post'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final postData = posts[index];
                    return _buildPostCard(postData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: top + 8, bottom: 12),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note_rounded, color: AppColors.primaryPurple, size: 20),
          const SizedBox(width: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'MUSCTA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderColor, width: 0.6),
              ),
              child: const Icon(
                Icons.textsms_rounded,
                color: AppColors.secondaryPurple,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> postData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(postData),
            const SizedBox(height: 12),
            _buildMusicInfo(postData),
            if (postData['imageUrl'] != null && postData['imageUrl'].isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPostImage(postData),
            ],
            const SizedBox(height: 12),
            _buildInteractionButtons(postData),
            const SizedBox(height: 8),
            _buildEngagementInfo(postData),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> postData) {
    final userData = postData['userData'] as Map<String, dynamic>? ?? {};
    final createdAt = postData['createdAt'] as DateTime?;
    final timeAgo = createdAt != null ? _getTimeAgo(createdAt) : 'now';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  userData['profileImageUrl'] as String? ?? 
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face'
                ),
                radius: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          userData['username'] as String? ?? 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (userData['isVerified'] == true) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1DA1F2), Color(0xFF0D8BF0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1DA1F2).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF8E8E93),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicInfo(Map<String, dynamic> postData) {
    final postId = postData['id'] as String;
    final isPlaying = _currentlyPlaying == postId;
    final albumCoverUrl = postData['albumCoverUrl'] as String? ?? 
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2C2C2E),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Album cover with play button overlay
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isPlaying ? [
                      BoxShadow(
                        color: const Color(0xFF30D158).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 45,
                      height: 45,
                      child: Image.network(
                        albumCoverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.cardBackground,
                            child: const Icon(Icons.music_note, color: AppColors.mutedText),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    onTap: () => _handlePlayPause(postId),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isPlaying ? AppColors.success : const Color(0xFF8E8E93),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1C1C1E),
                          width: 2,
                        ),
                        boxShadow: isPlaying ? [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ] : [],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 14,
                          key: ValueKey(isPlaying),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postData['musicTitle'] as String? ?? 'Unknown Track',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    postData['musicArtist'] as String? ?? 'Unknown Artist',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Duration
            Text(
              _formatDuration(postData['musicDuration'] as String?),
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            // Animated equalizer
            AnimatedEqualizer(isActive: isPlaying, height: 20, width: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImage(Map<String, dynamic> postData) {
    final imageUrl = postData['imageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.cardBackground,
                child: const Center(
                  child: Icon(Icons.broken_image, color: AppColors.mutedText, size: 48),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButtons(Map<String, dynamic> postData) {
    final postId = postData['id'] as String;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final likes = (postData['likes'] as List<dynamic>?) ?? [];
    final isLiked = currentUserId != null && likes.contains(currentUserId);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: () => _handleLike(postId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLiked 
                  ? AppColors.error.withOpacity(0.15)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isLiked 
                  ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1)
                  : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isLiked ? AppColors.error : Colors.white,
                  size: 22,
                  key: ValueKey(isLiked),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Comment button
          GestureDetector(
            onTap: () => _handleComment(postId),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Share button
          GestureDetector(
            onTap: () => _handleShare(postId),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          // More options
          GestureDetector(
            onTap: () => _showMoreOptions(postData),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementInfo(Map<String, dynamic> postData) {
    final likes = (postData['likes'] as List<dynamic>?) ?? [];
    final likesCount = likes.length;
    final caption = postData['caption'] as String? ?? '';
    final userData = postData['userData'] as Map<String, dynamic>? ?? {};
    final username = userData['username'] as String? ?? 'Unknown User';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_formatNumber(likesCount)} likes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildCaptionLine(username, caption),
          ],
        ],
      ),
    );
  }

  Widget _buildCaptionLine(String username, String caption) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$username ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: caption,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String _formatDuration(String? duration) {
    if (duration == null || duration.isEmpty) return '0:00';
    return duration;
  }

  void _handleLike(String postId) async {
    try {
      await PostService().toggleLike(postId);
      // The StreamBuilder will automatically update the UI
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error liking post: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleComment(String postId) {
    debugPrint('Comment on post: $postId');
    // TODO: Navigate to comments screen
  }

  void _handleShare(String postId) {
    debugPrint('Share post: $postId');
    // TODO: Implement share functionality
  }

  void _showMoreOptions(Map<String, dynamic> postData) {
    debugPrint('Show more options for post: ${postData['id']}');
    // TODO: Show bottom sheet with more options
  }

  void _handlePlayPause(String postId) {
    setState(() {
      if (_currentlyPlaying == postId) {
        _currentlyPlaying = null;
      } else {
        _currentlyPlaying = postId;
      }
    });
  }

  List<Map<String, dynamic>> _getDemoData() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'demo_user';
    final now = DateTime.now();
    
    return [
      {
        'id': 'demo_1',
        'userId': 'user_1',
        'musicTitle': 'Bohemian Rhapsody',
        'musicArtist': 'Queen',
        'musicDuration': '5:55',
        'albumCoverUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
        'imageUrl': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&h=800&fit=crop',
        'caption': 'Still gives me chills every time! 🎸 This masterpiece never gets old.',
        'likes': ['user_2', 'user_3', 'user_4'],
        'createdAt': now.subtract(const Duration(hours: 2)),
        'userData': {
          'username': 'john_music',
          'profileImageUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
          'isVerified': true,
        }
      },
      {
        'id': 'demo_2',
        'userId': 'user_2',
        'musicTitle': 'Blinding Lights',
        'musicArtist': 'The Weeknd',
        'musicDuration': '3:20',
        'albumCoverUrl': 'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=300&h=300&fit=crop',
        'imageUrl': '',
        'caption': 'Perfect vibes for tonight\'s drive 🌃✨ #synthwave #nightdrive',
        'likes': [currentUserId, 'user_3'],
        'createdAt': now.subtract(const Duration(hours: 4)),
        'userData': {
          'username': 'sarah_beats',
          'profileImageUrl': 'https://images.unsplash.com/photo-1494790108755-2616b332c6c3?w=100&h=100&fit=crop&crop=face',
          'isVerified': false,
        }
      },
      {
        'id': 'demo_3',
        'userId': 'user_3',
        'musicTitle': 'Thunderstruck',
        'musicArtist': 'AC/DC',
        'musicDuration': '4:52',
        'albumCoverUrl': 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
        'imageUrl': 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=800&h=800&fit=crop',
        'caption': 'Ready to rock! 🤘⚡ Just got my new guitar and this is the first song I had to play',
        'likes': ['user_1'],
        'createdAt': now.subtract(const Duration(hours: 6)),
        'userData': {
          'username': 'rock_lover',
          'profileImageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
          'isVerified': false,
        }
      },
    ];
  }
}

class AnimatedEqualizer extends StatefulWidget {
  final bool isActive;
  final double height;
  final double width;
  const AnimatedEqualizer({super.key, required this.isActive, this.height = 16, this.width = 20});

  @override
  State<AnimatedEqualizer> createState() => _AnimatedEqualizerState();
}

class _AnimatedEqualizerState extends State<AnimatedEqualizer>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isActive) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(AnimatedEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _controller.repeat();
    _pulseController.repeat();
  }

  void _stopAnimations() {
    _controller.stop();
    _pulseController.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const barCount = 4;
    const spacing = 2.0;
    final barWidth = (widget.width - spacing * (barCount - 1)) / barCount;

    const colors = [
      AppColors.chart1, // Teal
      AppColors.chart2, // Orange  
      AppColors.chart3, // Purple
      AppColors.chart4, // Merah
    ];

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _pulseController]),
        builder: (context, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(barCount, (i) {
              // Multiple wave frequencies for more dynamic movement
              final t1 = ((_controller.value + i * 0.15) % 1.0);
              final t2 = ((_controller.value + i * 0.25 + 0.5) % 1.0);
              final pulse = ((_pulseController.value + i * 0.1) % 1.0);
              
              final minH = widget.height * 0.2;
              final maxH = widget.height * 0.95;
              final active = widget.isActive;
              
              // Combine multiple sine waves for more realistic movement
              final wave1 = math.sin(2 * math.pi * t1 * (2 + i * 0.5));
              final wave2 = math.sin(2 * math.pi * t2 * (1.5 + i * 0.3)) * 0.6;
              final pulseWave = math.sin(2 * math.pi * pulse * (0.8 + i * 0.2)) * 0.4;
              
              final combined = (wave1 + wave2 + pulseWave) / 3;
              final normalizedHeight = (combined + 1) / 2; // Normalize to 0-1
              
              final h = active
                  ? minH + (maxH - minH) * normalizedHeight
                  : minH;
              
              // Add some randomness for more natural feel
              final randomOffset = active 
                  ? math.sin(_controller.value * 2 * math.pi + i * 1.7) * 0.1
                  : 0.0;
              final finalHeight = h + (randomOffset * widget.height * 0.1);
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                width: barWidth,
                height: math.max(finalHeight, minH),
                margin: EdgeInsets.only(right: i < barCount - 1 ? spacing : 0),
                decoration: BoxDecoration(
                  color: active ? colors[i] : const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: active ? [
                    BoxShadow(
                      color: colors[i].withOpacity(0.4 + normalizedHeight * 0.3),
                      blurRadius: 4 + normalizedHeight * 2,
                      offset: const Offset(0, 1),
                    ),
                  ] : null,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}