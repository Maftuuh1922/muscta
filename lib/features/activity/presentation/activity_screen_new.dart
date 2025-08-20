import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock activity data matching Figma design
  final List<ActivityItem> _followingActivities = [
    ActivityItem(
      id: '1',
      username: 'john_music',
      timestamp: '2h',
      avatar: 'J',
      hasMusic: true,
      musicTitle: 'Bohemian Rhapsody',
      musicArtist: 'Queen',
      hasPost: true,
      postCaption:
          'Still gives me chills every time! 😍 The atmosphere was electric. What\'s your favorite Queen song?',
      likes: '2,847 likes',
      commentsCount: '43 reposts',
      isVerified: true,
      hasMoreMenu: true,
    ),
    ActivityItem(
      id: '2',
      username: 'm_risk_curator',
      timestamp: '4h',
      avatar: 'M',
      action: 'reposted',
      isAction: true,
    ),
    ActivityItem(
      id: '3',
      username: 'sarah_beats',
      timestamp: '1d',
      avatar: 'S',
      hasMusic: true,
      musicTitle: 'Chill Vibes Playlist',
      musicArtist: 'Various Artists',
    ),
  ];

  final List<ActivityItem> _yourActivities = [
    ActivityItem(
      id: '4',
      username: 'You liked',
      timestamp: '1h',
      avatar: '♥',
      hasMusic: true,
      musicTitle: 'Jazz Standards',
      musicArtist: 'Miles Davis',
    ),
    ActivityItem(
      id: '5',
      username: 'You followed',
      timestamp: '2h',
      avatar: '+',
      targetUser: 'indie_alice',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildFollowingTab(), _buildYouTab()],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      title: const Text(
        'Activity',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.primaryBackground,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primaryPurple,
        labelColor: AppColors.primaryPurple,
        unselectedLabelColor: AppColors.mutedText,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Following'),
          Tab(text: 'You'),
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    return ListView.builder(
      itemCount: _followingActivities.length,
      itemBuilder: (context, index) {
        return _buildActivityItem(_followingActivities[index]);
      },
    );
  }

  Widget _buildYouTab() {
    return ListView.builder(
      itemCount: _yourActivities.length,
      itemBuilder: (context, index) {
        return _buildActivityItem(_yourActivities[index]);
      },
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Row(
            children: [
              _buildUserAvatar(activity),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          activity.username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        if (activity.isVerified == true) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.info,
                          ),
                        ],
                        const SizedBox(width: 4),
                        Text(
                          activity.timestamp,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const Spacer(),
                        if (activity.hasMoreMenu == true)
                          const Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: AppColors.mutedText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Music content if available
          if (activity.hasMusic) ...[
            const SizedBox(height: 12),
            _buildMusicContent(activity),
          ],

          // Post content if available
          if (activity.hasPost) ...[
            const SizedBox(height: 12),
            _buildPostContent(activity),
          ],

          // Action indicator for reposts
          if (activity.isAction == true) ...[
            const SizedBox(height: 8),
            Text(
              activity.action ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ActivityItem activity) {
    // Special case for action indicators
    if (activity.avatar == '♥' || activity.avatar == '+') {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Center(
          child: Text(
            activity.avatar,
            style: TextStyle(
              color: activity.avatar == '♥'
                  ? AppColors.likeColor
                  : AppColors.primaryPurple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
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
          activity.avatar,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMusicContent(ActivityItem activity) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.musicTitle ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (activity.musicArtist != null)
                Text(
                  activity.musicArtist!,
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
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: AppColors.primaryPurple,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(ActivityItem activity) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=400&h=300&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          // Bottom content
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action buttons
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.repeat, color: Colors.white, size: 20),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Likes count
                if (activity.likes != null)
                  Text(
                    activity.likes!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                // Caption
                if (activity.postCaption != null)
                  Text(
                    activity.postCaption!,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                // Comments count
                if (activity.commentsCount != null)
                  Text(
                    activity.commentsCount!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem {
  final String id;
  final String username;
  final String timestamp;
  final String avatar;
  final bool? isVerified;
  final bool hasMusic;
  final String? musicTitle;
  final String? musicArtist;
  final bool hasPost;
  final String? postCaption;
  final String? likes;
  final String? commentsCount;
  final bool? hasMoreMenu;
  final bool isAction;
  final String? action;
  final String? targetUser;

  ActivityItem({
    required this.id,
    required this.username,
    required this.timestamp,
    required this.avatar,
    this.isVerified,
    this.hasMusic = false,
    this.musicTitle,
    this.musicArtist,
    this.hasPost = false,
    this.postCaption,
    this.likes,
    this.commentsCount,
    this.hasMoreMenu,
    this.isAction = false,
    this.action,
    this.targetUser,
  });
}
