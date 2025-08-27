import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class MusicPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final VoidCallback onPlay;

  const MusicPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBookmark,
    required this.onPlay,
  });

  @override
  State<MusicPostCard> createState() => _MusicPostCardState();
}

class _MusicPostCardState extends State<MusicPostCard>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showLikeAnimation = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!(widget.post['likedBy'] as List<String>? ?? []).contains(getCurrentUserId())) {
      widget.onLike();
      setState(() {
        _showLikeAnimation = true;
      });
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse().then((_) {
          setState(() {
            _showLikeAnimation = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          const SizedBox(height: 12),
          _buildPostImage(),
          const SizedBox(height: 12),
          _buildPostActions(),
          const SizedBox(height: 8),
          _buildPostStats(),
          if (widget.post.caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPostCaption(),
          ],
          _buildMusicInfo(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryPurple,
            backgroundImage: NetworkImage(widget.post.user.avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.user.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  widget.post.timestamp,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Container(
        width: double.infinity,
        height: 400,
        color: AppColors.surfaceBackground,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.album_rounded,
                  size: 80,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            if (_showLikeAnimation)
              Center(
                child: AnimatedBuilder(
                  animation: _likeAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _likeAnimation.value,
                      child: Opacity(
                        opacity: 1.0 - _likeAnimation.value,
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 80,
                          color: AppColors.likeColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onLike,
            child: Icon(
              widget.post.isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: widget.post.isLiked
                  ? AppColors.likeColor
                  : AppColors.primaryText,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: widget.onComment,
            child: const Icon(
              Icons.textsms_rounded,
              color: AppColors.primaryText,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: widget.onShare,
            child: const Icon(
              Icons.textsms_rounded,
              color: AppColors.primaryText,
              size: 24,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onBookmark,
            child: Icon(
              widget.post.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: widget.post.isBookmarked
                  ? AppColors.primaryPurple
                  : AppColors.primaryText,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.likes > 0)
            Text(
              '${widget.post.likes} likes',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          if (widget.post.comments > 0)
            GestureDetector(
              onTap: widget.onComment,
              child: Text(
                'View all ${widget.post.comments} comments',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mutedText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: RichText(text: TextSpan(children: _buildCaptionSpans())),
    );
  }

  List<TextSpan> _buildCaptionSpans() {
    final List<TextSpan> spans = [];
    final words = widget.post.caption.split(' ');

    spans.add(
      TextSpan(
        text: '${widget.post.user.username} ',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
    );

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      if (word.startsWith('#')) {
        spans.add(
          TextSpan(
            text: word,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryPurple,
            ),
          ),
        );
      } else if (word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: word,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primaryPurple,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: word,
            style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
          ),
        );
      }

      if (i < words.length - 1) {
        spans.add(
          const TextSpan(
            text: ' ',
            style: TextStyle(fontSize: 14, color: AppColors.primaryText),
          ),
        );
      }
    }

    return spans;
  }

  Widget _buildMusicInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onPlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.music.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.post.music.artist,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Waveform visualization
          SizedBox(
            width: 80,
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(12, (index) {
                final heights = [
                  0.3,
                  0.7,
                  0.4,
                  0.9,
                  0.6,
                  0.2,
                  0.8,
                  0.5,
                  0.9,
                  0.3,
                  0.6,
                  0.4,
                ];
                return Container(
                  width: 2,
                  height: 32 * heights[index],
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
