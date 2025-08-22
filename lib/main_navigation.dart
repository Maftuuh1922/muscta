import 'package:flutter/material.dart';
import 'dart:io';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/post/presentation/create_post_screen.dart';
import '../features/activity/presentation/activity_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../services/user/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CreatePostScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBarBackground,
          border: Border(
            top: BorderSide(color: AppColors.borderColor, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: 8, // Reduced from AppConstants.smallPadding
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, 'Home', Icons.home_outlined, Icons.home_rounded),
                _buildNavItem(1, 'Search', Icons.search_outlined, Icons.search_rounded),
                _buildPostButton(),
                _buildNavItem(3, 'Activity', Icons.favorite_border_rounded, Icons.favorite_rounded),
                _buildProfileNavItem(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData inactiveIcon,
    IconData activeIcon,
  ) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? AppColors.navBarActive : AppColors.navBarInactive,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _currentIndex == 2 ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: _currentIndex == 2 ? AppColors.primary : AppColors.navBarInactive,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.add_rounded,
            color: _currentIndex == 2 ? Colors.black : AppColors.navBarInactive,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    final isActive = _currentIndex == 4;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: UserService().currentUserStream(),
          builder: (context, snapshot) {
            final userData = snapshot.data;
            final avatarUrl = (userData?['photoURL'] as String?)
                ?? (userData?['profileImageUrl'] as String?)
                ?? FirebaseAuth.instance.currentUser?.photoURL;
            
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: isActive 
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.cardBackground,
                backgroundImage: _getImageProvider(avatarUrl),
                child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Icon(
                      isActive ? Icons.person_rounded : Icons.person_outline_rounded,
                      color: isActive ? AppColors.navBarActive : AppColors.navBarInactive,
                      size: 18,
                    )
                  : null,
              ),
            );
          },
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return NetworkImage(imageUrl);
    }

    // Support file:// URIs
    if (imageUrl.startsWith('file://')) {
      try {
        final file = File.fromUri(Uri.parse(imageUrl));
        if (file.existsSync()) return FileImage(file);
      } catch (_) {}
    }

    // Support absolute paths (e.g., /data/user/0/...)
    if (imageUrl.startsWith('/')) {
      final file = File(imageUrl);
      if (file.existsSync()) return FileImage(file);
    }

    // Fallback: no image
    return null;
  }
}
