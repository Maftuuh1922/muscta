import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data matching Figma design
  final List<TrendingMusic> _trendingMusic = [
    TrendingMusic(
      id: '1',
      title: 'Heat Waves',
      artist: 'Glass Animals',
      plays: '2.1M',
      change: '+15%',
      cover: AppImages.albumPlaceholders[0],
    ),
    TrendingMusic(
      id: '2',
      title: 'As It Was',
      artist: 'Harry Styles',
      plays: '1.8M',
      change: '+8%',
      cover: AppImages.albumPlaceholders[1],
    ),
    TrendingMusic(
      id: '3',
      title: 'Bad Habit',
      artist: 'Steve Lacy',
      plays: '1.5M',
      change: '+23%',
      cover: AppImages.albumPlaceholders[2],
    ),
  ];

  final List<PopularHashtag> _popularHashtags = [
    PopularHashtag(tag: 'newmusic', posts: '2.1M'),
    PopularHashtag(tag: 'indie', posts: '856K'),
    PopularHashtag(tag: 'rock', posts: '743K'),
    PopularHashtag(tag: 'pop', posts: '1.2M'),
    PopularHashtag(tag: 'jazz', posts: '425K'),
    PopularHashtag(tag: 'electronic', posts: '567K'),
  ];

  final List<SuggestedUser> _suggestedUsers = [
    SuggestedUser(
      id: '1',
      username: 'indie_alice',
      name: 'Alice Johnson',
      avatar: AppImages.profilePlaceholders[0],
      followers: '12.5K',
      isFollowing: false,
      bio: 'Indie rock enthusiast 🎸',
    ),
    SuggestedUser(
      id: '2',
      username: 'jazz_master',
      name: 'Marcus Williams',
      avatar: AppImages.profilePlaceholders[1],
      followers: '8.2K',
      isFollowing: false,
      bio: 'Jazz pianist & composer 🎹',
    ),
    SuggestedUser(
      id: '3',
      username: 'electronic_beats',
      name: 'Sophia Chen',
      avatar: AppImages.profilePlaceholders[2],
      followers: '15.7K',
      isFollowing: true,
      bio: 'Electronic music producer ⚡',
    ),
  ];

  final List<ExploreGridItem> _exploreGrid = [
    ExploreGridItem(
      id: '1',
      image: AppImages.albumPlaceholders[3],
      likes: '2.1K',
    ),
    ExploreGridItem(
      id: '2',
      image: AppImages.albumPlaceholders[4],
      likes: '1.8K',
    ),
    ExploreGridItem(
      id: '3',
      image: AppImages.albumPlaceholders[5],
      likes: '3.2K',
    ),
    ExploreGridItem(
      id: '4',
      image: AppImages.albumPlaceholders[6],
      likes: '987',
    ),
    ExploreGridItem(
      id: '5',
      image: AppImages.albumPlaceholders[7],
      likes: '1.5K',
    ),
    ExploreGridItem(
      id: '6',
      image: AppImages.albumPlaceholders[8],
      likes: '756',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleFollow(String userId) {
    setState(() {
      final userIndex = _suggestedUsers.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        _suggestedUsers[userIndex] = _suggestedUsers[userIndex].copyWith(
          isFollowing: !_suggestedUsers[userIndex].isFollowing,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.searchBarBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.3),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              hintText: 'Search songs, artists, users...',
              hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.mutedText,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: _searchQuery.isEmpty
            ? _buildExploreContent()
            : _buildSearchResults(),
      ),
    );
  }

  Widget _buildExploreContent() {
    return Column(
      children: [
        _buildTrendingMusic(),
        _buildPopularHashtags(),
        _buildSuggestedUsers(),
        _buildExploreGrid(),
      ],
    );
  }

  Widget _buildTrendingMusic() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: AppColors.primaryPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Trending Music',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_trendingMusic.length, (index) {
            final track = _trendingMusic[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPurple.withValues(alpha: 0.2),
                          AppColors.secondaryPurple.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.mutedText.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      image: track.cover != null
                          ? DecorationImage(
                              image: NetworkImage(track.cover!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: track.cover == null
                        ? const Icon(
                            Icons.music_note_rounded,
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
                          track.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.artist,
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        track.plays,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.change,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPopularHashtags() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_rounded, color: AppColors.secondaryPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Popular Hashtags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _popularHashtags.length,
            itemBuilder: (context, index) {
              final hashtag = _popularHashtags[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          size: 16,
                          color: AppColors.secondaryPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#${hashtag.tag}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hashtag.posts} posts',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUsers() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_rounded, color: AppColors.secondaryPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Suggested for You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_suggestedUsers.length, (index) {
            final user = _suggestedUsers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      image: user.avatar != null
                          ? DecorationImage(
                              image: NetworkImage(user.avatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user.avatar == null
                        ? Center(
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          user.bio,
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${user.followers} followers',
                          style: const TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleFollow(user.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isFollowing
                          ? Colors.transparent
                          : AppColors.primaryPurple,
                      foregroundColor: user.isFollowing
                          ? AppColors.primaryPurple
                          : AppColors.primaryText,
                      side: user.isFollowing
                          ? const BorderSide(color: AppColors.primaryPurple)
                          : null,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      user.isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExploreGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                color: AppColors.secondaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Explore Music Posts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: _exploreGrid.length,
            itemBuilder: (context, index) {
              final item = _exploreGrid[index];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.mutedText.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      image: item.image != null
                          ? DecorationImage(
                              image: NetworkImage(item.image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.image == null
                        ? const Center(
                            child: Icon(
                              Icons.music_note_rounded,
                              color: AppColors.primaryPurple,
                              size: 32,
                            ),
                          )
                        : null,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.likes,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Search results for "$_searchQuery" will appear here',
          style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Data Models
class TrendingMusic {
  final String id;
  final String title;
  final String artist;
  final String plays;
  final String change;
  final String? cover;

  TrendingMusic({
    required this.id,
    required this.title,
    required this.artist,
    required this.plays,
    required this.change,
    this.cover,
  });
}

class PopularHashtag {
  final String tag;
  final String posts;

  PopularHashtag({required this.tag, required this.posts});
}

class SuggestedUser {
  final String id;
  final String username;
  final String name;
  final String? avatar;
  final String followers;
  final bool isFollowing;
  final String bio;

  SuggestedUser({
    required this.id,
    required this.username,
    required this.name,
    this.avatar,
    required this.followers,
    required this.isFollowing,
    required this.bio,
  });

  SuggestedUser copyWith({
    String? id,
    String? username,
    String? name,
    String? avatar,
    String? followers,
    bool? isFollowing,
    String? bio,
  }) {
    return SuggestedUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      followers: followers ?? this.followers,
      isFollowing: isFollowing ?? this.isFollowing,
      bio: bio ?? this.bio,
    );
  }
}

class ExploreGridItem {
  final String id;
  final String? image;
  final String likes;

  ExploreGridItem({required this.id, this.image, required this.likes});
}
