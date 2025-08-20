import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/user/user_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _demoProfile = ProfileData(
    username: 'your_username',
    name: 'Your Name',
    avatar:
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop&crop=face',
    bio:
        'Music enthusiast 🎵 | Rock & Indie lover 🎸 | Always discovering new sounds ✨',
    website: 'yourmusic.com',
    posts: 127,
    followers: 2847,
    following: 892,
    genres: const ['Rock', 'Indie', 'Alternative', 'Pop Punk'],
    topArtists: const ['Queen', 'Arctic Monkeys', 'The Strokes', 'Radiohead'],
    isVerified: true,
  );

  final List<ProfilePost> _posts = const [
    ProfilePost(
      id: 1,
      image:
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=300&h=300&fit=crop',
      likes: 243,
      type: 'image',
    ),
    ProfilePost(
      id: 2,
      image:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
      likes: 567,
      type: 'music',
    ),
    ProfilePost(
      id: 3,
      image:
          'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=300&h=300&fit=crop',
      likes: 189,
      type: 'image',
    ),
    ProfilePost(
      id: 4,
      image:
          'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=300&h=300&fit=crop',
      likes: 432,
      type: 'music',
    ),
    ProfilePost(
      id: 5,
      image:
          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=300&h=300&fit=crop',
      likes: 678,
      type: 'image',
    ),
    ProfilePost(
      id: 6,
      image:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
      likes: 324,
      type: 'music',
    ),
  ];

  final List<ProfilePlaylist> _playlists = const [
    ProfilePlaylist(
      id: 1,
      name: 'Road Trip Vibes',
      cover:
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=300&h=300&fit=crop',
      trackCount: 45,
      isPublic: true,
    ),
    ProfilePlaylist(
      id: 2,
      name: 'Late Night Jazz',
      cover:
          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=300&h=300&fit=crop',
      trackCount: 32,
      isPublic: false,
    ),
    ProfilePlaylist(
      id: 3,
      name: 'Workout Energy',
      cover:
          'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=300&h=300&fit=crop',
      trackCount: 28,
      isPublic: true,
    ),
    ProfilePlaylist(
      id: 4,
      name: 'Sunday Morning',
      cover:
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop',
      trackCount: 21,
      isPublic: true,
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
    return StreamBuilder<Map<String, dynamic>?>(
      stream: UserService().currentUserStream(),
      builder: (context, snap) {
        final data = snap.data;
        final profile = ProfileData(
          username: (data?['username'] as String?) ?? _demoProfile.username,
          name: (data?['displayName'] as String?) ?? _demoProfile.name,
          avatar: (data?['photoURL'] as String?) ?? _demoProfile.avatar,
          bio: (data?['bio'] as String?) ?? _demoProfile.bio,
          website: (data?['website'] as String?) ?? _demoProfile.website,
          posts: (data?['posts'] as int?) ?? _demoProfile.posts,
          followers: (data?['followers'] as int?) ?? _demoProfile.followers,
          following: (data?['following'] as int?) ?? _demoProfile.following,
          genres: (data?['genres'] as List?)?.cast<String>() ?? _demoProfile.genres,
          topArtists: (data?['topArtists'] as List?)?.cast<String>() ?? _demoProfile.topArtists,
          isVerified: (data?['verified'] as bool?) ?? _demoProfile.isVerified,
        );

        return Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            title: Text(
              '@${profile.username}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.primaryText,
                  size: 22,
                ),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      _buildProfileHeader(profile),
                      _buildTabBar(),
                      SizedBox(
                        height: 520,
                        child: TabBarView(
                          controller: _tabController,
                          children: [_buildPostsGrid(), _buildPlaylistsList()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ProfileData profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        width: 4,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(profile.avatar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (profile.isVerified)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBackground,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('posts', profile.posts.toString()),
                        _buildStat('followers', profile.followers.toString()),
                        _buildStat('following', profile.following.toString()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final changed = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                    displayName: profile.name,
                                    username: profile.username,
                                    bio: profile.bio,
                                    website: profile.website,
                                  ),
                                ),
                              );
                              if (changed == true && mounted) {
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              foregroundColor: AppColors.primaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryText,
                            side: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Share'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bio & website
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.bio,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText,
                ),
              ),
              if (profile.website != null && profile.website!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '🔗 ${profile.website}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Music Profile card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.music_note_rounded,
                      color: AppColors.primaryPurple,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Music Profile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Favorite Genres',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: profile.genres
                                .map((g) => _genreBadge(g))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top Artists',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...profile.topArtists
                              .take(3)
                              .map(
                                (a) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    a,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
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

  Widget _genreBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
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
          Tab(icon: Icon(Icons.grid_on_rounded, size: 18), text: 'Posts'),
          Tab(
            icon: Icon(Icons.queue_music_rounded, size: 18),
            text: 'Playlists',
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Stack(
          children: [
            // image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                post.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // overlay center on tap/hover (mobile we'll keep subtle bottom badge)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 12,
                      color: AppColors.likeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.likes.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (post.type == 'music') ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.music_note_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaylistsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final p = _playlists[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 0.5),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  p.cover,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        if (!p.isPublic)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.borderColor,
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'Private',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.trackCount} tracks',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: _playlists.length,
    );
  }
}

class ProfileData {
  final String username;
  final String name;
  final String avatar;
  final String bio;
  final String? website;
  final int posts;
  final int followers;
  final int following;
  final List<String> genres;
  final List<String> topArtists;
  final bool isVerified;

  ProfileData({
    required this.username,
    required this.name,
    required this.avatar,
    required this.bio,
    required this.website,
    required this.posts,
    required this.followers,
    required this.following,
    required this.genres,
    required this.topArtists,
    required this.isVerified,
  });
}

class ProfilePost {
  final int id;
  final String image;
  final int likes;
  final String type; // 'image' | 'music'

  const ProfilePost({
    required this.id,
    required this.image,
    required this.likes,
    required this.type,
  });
}

class ProfilePlaylist {
  final int id;
  final String name;
  final String cover;
  final int trackCount;
  final bool isPublic;

  const ProfilePlaylist({
    required this.id,
    required this.name,
    required this.cover,
    required this.trackCount,
    required this.isPublic,
  });
}
