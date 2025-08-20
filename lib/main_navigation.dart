import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/post/presentation/create_post_screen.dart';
import '../features/activity/presentation/activity_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

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
              vertical: AppConstants.smallPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, 'Home', Icons.home_outlined, Icons.home_rounded),
                _buildNavItem(1, 'Search', Icons.search_outlined, Icons.search_rounded),
                _buildPostButton(),
                _buildNavItem(3, 'Activity', Icons.favorite_border_rounded, Icons.favorite_rounded),
                _buildNavItem(4, 'Profile', Icons.person_outline_rounded, Icons.person_rounded),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.navBarActive : AppColors.navBarInactive,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.navBarActive : AppColors.navBarInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _currentIndex == 2 ? AppColors.primaryPurple : Colors.transparent,
                border: Border.all(
                  color: _currentIndex == 2 ? AppColors.primaryPurple : AppColors.navBarInactive,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add_rounded,
                color: _currentIndex == 2 ? AppColors.primaryText : AppColors.navBarInactive,
                size: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Post',
              style: TextStyle(
                fontSize: 10,
                fontWeight: _currentIndex == 2 ? FontWeight.w600 : FontWeight.normal,
                color: _currentIndex == 2 ? AppColors.navBarActive : AppColors.navBarInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
