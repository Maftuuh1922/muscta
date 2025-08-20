import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _currentlyPlaying;

  // Mock data for posts based on Figma design
  final List<MusicPost> _posts = [
    MusicPost(
      id: '1',
      user: MusicUser(username: 'john_music', avatar: 'J', isVerified: true),
      music: MusicTrack(
        title: 'Bohemian Rhapsody',
        artist: 'Queen',
        albumCover: '',
        duration: '5:55',
      ),
      caption:
          'Still gives me chills every time! 🎸 This masterpiece never gets old. What\'s your favorite Queen song?',
      postImage:
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400&h=400&fit=crop',
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
      user: MusicUser(username: 'sarah_beats', avatar: 'S', isVerified: false),
      music: MusicTrack(
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        albumCover: '',
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
      user: MusicUser(username: 'rock_lover', avatar: 'R', isVerified: false),
      music: MusicTrack(
        title: 'Thunderstruck',
        artist: 'AC/DC',
        albumCover: '',
        duration: '4:52',
      ),
      caption:
          'Ready to rock! 🤘⚡ Just got my new guitar and this is the first song I had to play',
      postImage:
          'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=400&h=400&fit=crop',
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return _buildMusicPost(_posts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.3),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(
                Icons.music_note,
                color: AppColors.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
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
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.near_me_rounded,
              color: AppColors.secondaryPurple,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicPost(MusicPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          _buildPostHeader(post),
          const SizedBox(height: 12),

          // Music info
          _buildMusicInfo(post),
          const SizedBox(height: 12),

          // Caption
          if (post.caption.isNotEmpty) ...[
            _buildCaption(post),
            const SizedBox(height: 12),
          ],

          // Post image if available
          if (post.postImage != null) ...[
            _buildPostImage(post),
            const SizedBox(height: 12),
          ],

          // Interaction buttons
          _buildInteractionButtons(post),
          const SizedBox(height: 8),

          // Likes and comments count
          _buildEngagementInfo(post),
        ],
      ),
    );
  }

  Widget _buildPostHeader(MusicPost post) {
    return Row(
      children: [
        // User avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryPurple,
                AppColors.primaryPurple.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Text(
              post.user.avatar,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Username and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.user.username,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  if (post.user.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: AppColors.info),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    post.timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
              if (post.repostedBy != null)
                Text(
                  'Reposted by ${post.repostedBy}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
            ],
          ),
        ),

        // More menu
        const Icon(Icons.more_horiz, color: AppColors.mutedText, size: 20),
      ],
    );
  }

  Widget _buildMusicInfo(MusicPost post) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          // Album cover
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor, width: 0.5),
            ),
            child: const Icon(
              Icons.music_note,
              color: AppColors.primaryPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Music details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.music.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  post.music.artist,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  post.music.duration,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),

          // Play button
          GestureDetector(
            onTap: () => _handlePlayPause(post.id),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: post.isPlaying
                    ? AppColors.primaryPurple
                    : AppColors.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                post.isPlaying ? Icons.pause : Icons.play_arrow,
                color: post.isPlaying ? Colors.white : AppColors.primaryPurple,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaption(MusicPost post) {
    return Text(
      post.caption,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.primaryText,
        height: 1.4,
      ),
    );
  }

  Widget _buildPostImage(MusicPost post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          image: DecorationImage(
            image: NetworkImage(post.postImage!),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionButtons(MusicPost post) {
    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: () => _handleLike(post.id),
          child: Icon(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            color: post.isLiked ? AppColors.likeColor : AppColors.primaryText,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),

        // Comment button
        GestureDetector(
          onTap: () => _handleComment(post.id),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.primaryText,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),

        // Repost button
        GestureDetector(
          onTap: () => _handleRepost(post.id),
          child: const Icon(
            Icons.repeat,
            color: AppColors.primaryText,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),

        // Share/DM button
        GestureDetector(
          onTap: () => _handleShare(post.id),
          child: const Icon(
            Icons.near_me_rounded,
            color: AppColors.primaryText,
            size: 22,
          ),
        ),

        const Spacer(),

        // Bookmark button
        GestureDetector(
          onTap: () => _handleBookmark(post.id),
          child: Icon(
            post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: post.isBookmarked
                ? AppColors.primaryPurple
                : AppColors.primaryText,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementInfo(MusicPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.likes > 0)
          Text(
            '${_formatNumber(post.likes)} likes',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        const SizedBox(height: 4),
        if (post.comments > 0 || post.reposts > 0)
          Text(
            '${post.comments > 0 ? '${post.comments} comments' : ''}${post.comments > 0 && post.reposts > 0 ? ' • ' : ''}${post.reposts > 0 ? '${post.reposts} reposts' : ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
      ],
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
    // Navigate to comments
    // ignore: avoid_print
    print('Comment on post: $postId');
  }

  void _handleShare(String postId) {
    // Share functionality
    // ignore: avoid_print
    print('Share post: $postId');
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
        // Stop all other playing posts
        for (var post in _posts) {
          post.isPlaying = false;
        }
        _currentlyPlaying = postId;
        final post = _posts.firstWhere((p) => p.id == postId);
        post.isPlaying = true;
      }
    });
  }

  void _handleRepost(String postId) {
    setState(() {
      final post = _posts.firstWhere((p) => p.id == postId);
      post.reposts++;
    });
    // ignore: avoid_print
    print('Repost: $postId');
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

  MusicUser({
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

  MusicTrack({
    required this.title,
    required this.artist,
    required this.albumCover,
    required this.duration,
  });
}
