import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../chat/presentation/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String? _currentlyPlaying;
  late AnimationController _marqueeController;

  final List<MusicPost> _posts = [
    MusicPost(
      id: '1',
      user: MusicUser(
        username: 'john_music',
        avatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
        isVerified: true,
      ),
      music: MusicTrack(
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        albumCover:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
        duration: '5:55',
      ),
      caption:
          'john_music: Still gives me chills every time! 🎸 This masterpiece never gets old. What\'s your favorite Queen song?',
      postImage:
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&h=800&fit=crop',
      likes: 2847,
      comments: 156,
      reposts: 43,
      timestamp: '2h',
      isLiked: false,
      isBookmarked: false,
      isPlaying: false,
    ),
    MusicPost(
      id: '2',
      user: MusicUser(
        username: 'sarah_beats',
        avatar:
            'https://images.unsplash.com/photo-1494790108755-2616b332c6c3?w=100&h=100&fit=crop&crop=face',
        isVerified: false,
      ),
      music: MusicTrack(
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        albumCover:
            'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=300&h=300&fit=crop',
        duration: '3:20',
      ),
      caption: 'Perfect vibes for tonight\'s drive 🌃✨ #synthwave #nightdrive',
      postImage: null,
      likes: 1432,
      comments: 89,
      reposts: 67,
      timestamp: '4h',
      isLiked: true,
      isBookmarked: true,
      isPlaying: false,
      repostedBy: 'music_curator',
    ),
    MusicPost(
      id: '3',
      user: MusicUser(
        username: 'rock_lover',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
        isVerified: false,
      ),
      music: MusicTrack(
        title: 'Thunderstruck',
        artist: 'AC/DC',
        albumCover:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
        duration: '4:52',
      ),
      caption:
          'Ready to rock! 🤘⚡ Just got my new guitar and this is the first song I had to play',
      postImage:
          'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=800&h=800&fit=crop',
      likes: 956,
      comments: 43,
      reposts: 21,
      timestamp: '6h',
      isLiked: false,
      isBookmarked: false,
      isPlaying: false,
    ),
  ];

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
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return _buildPostCard(_posts[index]);
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

  Widget _buildPostCard(MusicPost post) {
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
            _buildPostHeader(post),
            const SizedBox(height: 12),
            _buildMusicInfo(post),
            if (post.postImage != null) ...[
              const SizedBox(height: 12),
              _buildPostImage(post),
            ],
            const SizedBox(height: 12),
            _buildInteractionButtons(post),
            const SizedBox(height: 8),
            _buildEngagementInfo(post),
            if (post.repostedBy != null) ...[
              const SizedBox(height: 6),
              _buildRepostInfo(post),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(MusicPost post) {
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
                backgroundImage: NetworkImage(post.user.avatar),
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
                          post.user.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (post.user.isVerified) ...[
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
                  post.timestamp,
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

  Widget _buildMusicInfo(MusicPost post) {
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
                    boxShadow: post.isPlaying ? [
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
                    child: Container(
                      width: 45,
                      height: 45,
                      child: Image.network(
                        post.music.albumCover,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    onTap: () => _handlePlayPause(post.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: post.isPlaying ? const Color(0xFF30D158) : const Color(0xFF8E8E93),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1C1C1E),
                          width: 2,
                        ),
                        boxShadow: post.isPlaying ? [
                          BoxShadow(
                            color: const Color(0xFF30D158).withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ] : [],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          post.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 14,
                          key: ValueKey(post.isPlaying),
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
                    post.music.title,
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
                    post.music.artist,
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
              post.music.duration,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            // Animated equalizer
            AnimatedEqualizer(isActive: post.isPlaying, height: 20, width: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImage(MusicPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(post.postImage!, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildInteractionButtons(MusicPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: () => _handleLike(post.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: post.isLiked 
                  ? const Color(0xFFFF3B30).withOpacity(0.15)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: post.isLiked 
                  ? Border.all(color: const Color(0xFFFF3B30).withOpacity(0.3), width: 1)
                  : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: post.isLiked ? const Color(0xFFFF3B30) : Colors.white,
                  size: 22,
                  key: ValueKey(post.isLiked),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Comment button
          GestureDetector(
            onTap: () => _handleComment(post.id),
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
            onTap: () => _handleShare(post.id),
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
          const SizedBox(width: 16),
          // Repost button
          GestureDetector(
            onTap: () => _handleRepost(post.id),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.repeat_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          // Bookmark button
          GestureDetector(
            onTap: () => _handleBookmark(post.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: post.isBookmarked 
                  ? const Color(0xFFFFD60A).withOpacity(0.15)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: post.isBookmarked 
                  ? Border.all(color: const Color(0xFFFFD60A).withOpacity(0.3), width: 1)
                  : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  post.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: post.isBookmarked ? const Color(0xFFFFD60A) : Colors.white,
                  size: 22,
                  key: ValueKey(post.isBookmarked),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementInfo(MusicPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_formatNumber(post.likes)} likes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${post.reposts} reposts',
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildCaptionLine(post),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _handleComment(post.id),
            child: Text(
              'View all ${post.comments} comments',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionLine(MusicPost post) {
    final username = post.user.username;
    final text = post.caption;

    if (text.startsWith('$username:')) {
      final rest = text.substring(username.length + 1).trim();
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
              text: rest,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
    );
  }

  Widget _buildRepostInfo(MusicPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF8E8E93).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.repeat_rounded,
              color: Color(0xFF8E8E93),
              size: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${post.repostedBy} reposted',
            style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
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

  void _handleLike(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.isLiked = !post.isLiked;
      if (post.isLiked) {
        post.likes++;
      } else {
        post.likes--;
      }
    });
  }

  void _handleComment(String postId) {
    debugPrint('Comment on post: $postId');
  }

  void _handleShare(String postId) {
    debugPrint('Share post: $postId');
  }

  void _handleRepost(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.reposts++;
    });
  }

  void _handleBookmark(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.isBookmarked = !post.isBookmarked;
    });
  }

  void _handlePlayPause(String postId) {
    setState(() {
      if (_currentlyPlaying == postId) {
        _currentlyPlaying = null;
        final post = _posts.firstWhere((p) => p.id == postId);
        post.isPlaying = false;
      } else {
        for (var p in _posts) {
          p.isPlaying = false;
        }
        _currentlyPlaying = postId;
        final post = _posts.firstWhere((p) => p.id == postId);
        post.isPlaying = true;
      }
    });
  }
}

// Data models
class MusicPost {
  final String id;
  final MusicUser user;
  final MusicTrack music;
  final String caption;
  final String? postImage;
  int likes;
  final int comments;
  int reposts;
  final String timestamp;
  bool isLiked;
  bool isBookmarked;
  bool isPlaying;
  final String? repostedBy;

  MusicPost({
    required this.id,
    required this.user,
    required this.music,
    required this.caption,
    this.postImage,
    required this.likes,
    required this.comments,
    required this.reposts,
    required this.timestamp,
    required this.isLiked,
    required this.isBookmarked,
    required this.isPlaying,
    this.repostedBy,
  });
}

class MusicUser {
  final String username;
  final String avatar;
  final bool isVerified;

  const MusicUser({
    required this.username,
    required this.avatar,
    required this.isVerified,
  });
}

class MusicTrack {
  final String title;
  final String artist;
  final String albumCover;
  final String duration;

  const MusicTrack({
    required this.title,
    required this.artist,
    required this.albumCover,
    required this.duration,
  });
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
      Color(0xFF30D158), // Green
      Color(0xFF32D74B), // Light Green  
      Color(0xFFFF9F0A), // Orange
      Color(0xFFBF5AF2), // Purple
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