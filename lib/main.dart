import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/post/presentation/create_post_screen.dart';
import 'features/activity/presentation/activity_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.primaryBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MusctaApp());
}

class MusctaApp extends StatelessWidget {
  const MusctaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreatePostScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBarBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.search_outlined, Icons.search_rounded, 'Search'),
              _buildCenterAddButton(),
              _buildNavItem(3, Icons.favorite_border_rounded, Icons.favorite_rounded, 'Activity'),
              _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutBack,
          scale: isSelected ? 1.15 : 1.0,
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppColors.navBarActive : AppColors.navBarInactive,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    final bool isSelected = _currentIndex == 2;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 2;
        });
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        scale: isSelected ? 1.1 : 1.0,
        child: Container
          (
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F), // dark square like preview
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.navBarActive : AppColors.borderColor,
              width: isSelected ? 1.2 : 0.6,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
