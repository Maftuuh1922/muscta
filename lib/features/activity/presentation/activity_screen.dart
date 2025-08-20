import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data matching the React sample
  final List<ActivityEntry> _youActivities = [
    ActivityEntry(
      id: '1',
      type: ActivityType.like,
      user: ActivityUser(
        username: 'sarah_beats',
        avatar:
            'https://images.unsplash.com/photo-1494790108755-2616b332c6c3?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'liked your post',
      post: ActivityPost(
        image:
            'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=100&h=100&fit=crop',
      ),
      timestamp: '2m ago',
      isNew: true,
    ),
    ActivityEntry(
      id: '2',
      type: ActivityType.comment,
      user: ActivityUser(
        username: 'jazz_master',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'commented on your post',
      comment: 'Great taste in music! 🎵',
      post: ActivityPost(
        image:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop',
      ),
      timestamp: '5m ago',
      isNew: true,
    ),
    ActivityEntry(
      id: '3',
      type: ActivityType.follow,
      user: ActivityUser(
        username: 'rock_lover',
        avatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'started following you',
      timestamp: '1h ago',
      isNew: false,
      isFollowing: false,
    ),
    ActivityEntry(
      id: '4',
      type: ActivityType.musicRecommendation,
      user: ActivityUser(
        username: 'indie_alice',
        avatar:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'recommended a song for you',
      music: ActivityMusic(
        title: 'Midnight City',
        artist: 'M83',
        cover:
            'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=100&h=100&fit=crop',
      ),
      timestamp: '2h ago',
      isNew: false,
    ),
    ActivityEntry(
      id: '5',
      type: ActivityType.like,
      user: ActivityUser(
        username: 'electronic_beats',
        avatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'and 12 others liked your post',
      post: ActivityPost(
        image:
            'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=100&h=100&fit=crop',
      ),
      timestamp: '3h ago',
      isNew: false,
    ),
  ];

  final List<ActivityEntry> _followingActivities = [
    ActivityEntry(
      id: 'f1',
      type: ActivityType.like,
      user: ActivityUser(
        username: 'sarah_beats',
        avatar:
            'https://images.unsplash.com/photo-1494790108755-2616b332c6c3?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'liked a post by @jazz_master',
      post: ActivityPost(
        image:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop',
      ),
      timestamp: '30m ago',
    ),
    ActivityEntry(
      id: 'f2',
      type: ActivityType.follow,
      user: ActivityUser(
        username: 'rock_lover',
        avatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'started following @indie_alice',
      timestamp: '1h ago',
    ),
    ActivityEntry(
      id: 'f3',
      type: ActivityType.musicRecommendation,
      user: ActivityUser(
        username: 'jazz_master',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
      action: 'shared a new playlist',
      music: ActivityMusic(
        title: 'Late Night Jazz',
        cover:
            'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=100&h=100&fit=crop',
      ),
      timestamp: '2h ago',
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
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFollowingList(),
                _buildYouList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor, width: 0.4),
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorPadding: const EdgeInsets.all(3),
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryPurple.withOpacity(0.18),
                AppColors.secondaryPurple.withOpacity(0.18),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.30),
              width: 0.7,
            ),
          ),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          labelColor: AppColors.primaryText,
          unselectedLabelColor: AppColors.mutedText,
          splashBorderRadius: BorderRadius.circular(14),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'You'),
          ],
        ),
      ),
    );
  }

  Widget _buildYouList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: _youActivities.length,
      itemBuilder: (context, index) {
        return _buildActivityTile(_youActivities[index]);
      },
    );
  }

  Widget _buildFollowingList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: _followingActivities.length,
      itemBuilder: (context, index) {
        return _buildActivityTile(_followingActivities[index]);
      },
    );
  }

  Widget _buildActivityTile(ActivityEntry a) {
    final bool isNew = a.isNew == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isNew
            ? AppColors.primaryPurple.withOpacity(0.06)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isNew
              ? AppColors.primaryPurple.withOpacity(0.22)
              : AppColors.borderColor,
          width: 0.7,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with overlay type icon
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.borderColor,
                backgroundImage: a.user.avatar != null && a.user.avatar!.isNotEmpty
                    ? NetworkImage(a.user.avatar!)
                    : null,
                child: (a.user.avatar == null || a.user.avatar!.isEmpty)
                    ? Text(
                        a.user.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderColor, width: 0.5),
                  ),
                  child: Center(child: _typeIcon(a.type)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '@${a.user.username} ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: a.action,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (a.comment != null && a.comment!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                '"${a.comment}"',
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          if (a.timestamp != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                a.timestamp!,
                                style: const TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Right content: follow button, post thumb, music
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (a.type == ActivityType.follow && a.isFollowing != null)
                          _followButton(a),
                        if (a.post != null) ...[
                          const SizedBox(width: 6),
                          _postThumb(a.post!),
                        ],
                        if (a.music != null) ...[
                          const SizedBox(width: 6),
                          _musicThumb(a.music!),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _followButton(ActivityEntry a) {
    final bool following = a.isFollowing ?? false;
    return GestureDetector(
      onTap: () {
        setState(() {
          a.isFollowing = !following;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: following ? Colors.transparent : AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: following ? AppColors.primaryPurple : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          following ? 'Following' : 'Follow',
          style: TextStyle(
            color: following ? AppColors.primaryPurple : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _postThumb(ActivityPost post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        post.image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _musicThumb(ActivityMusic music) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            music.cover,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderColor, width: 0.6),
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _typeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.like:
        return const Icon(Icons.favorite_rounded, size: 12, color: Color(0xFFEF4444));
      case ActivityType.comment:
        return const Icon(Icons.textsms_rounded, size: 12, color: AppColors.primaryPurple);
      case ActivityType.follow:
        return const Icon(Icons.person_add_rounded, size: 12, color: AppColors.success);
      case ActivityType.musicRecommendation:
        return const Icon(Icons.music_note_rounded, size: 12, color: AppColors.secondaryPurple);
    }
  }
}

// Models for Activity screen
class ActivityUser {
  final String username;
  final String? avatar;
  const ActivityUser({required this.username, this.avatar});
}

class ActivityPost {
  final String image;
  const ActivityPost({required this.image});
}

class ActivityMusic {
  final String title;
  final String? artist;
  final String cover;
  const ActivityMusic({required this.title, this.artist, required this.cover});
}

enum ActivityType { like, comment, follow, musicRecommendation }

class ActivityEntry {
  final String id;
  final ActivityType type;
  final ActivityUser user;
  final String action;
  final String? timestamp;
  final String? comment;
  final ActivityPost? post;
  final ActivityMusic? music;
  bool? isFollowing; // only for follow type
  bool? isNew;

  ActivityEntry({
    required this.id,
    required this.type,
    required this.user,
    required this.action,
    this.timestamp,
    this.comment,
    this.post,
    this.music,
    this.isFollowing,
    this.isNew,
  });
}
