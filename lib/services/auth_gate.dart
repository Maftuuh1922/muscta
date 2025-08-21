import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_navigation.dart';
import '../core/constants/app_colors.dart';
import 'login/login_screen.dart';
import 'user/user_service.dart';
import 'offline_user_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static _AuthGateState? _currentState;

  @override
  State<AuthGate> createState() => _AuthGateState();

  static void clearProfileCache() {
    _currentState?.clearCache();
  }

  static void setProfileJustCompleted() {
    _currentState?.setProfileCompleted();
  }
}

class _AuthGateState extends State<AuthGate> {
  bool _profileJustCompleted = false;
  String? _lastCheckedUserId;
  bool? _lastCheckResult;

  @override
  void initState() {
    super.initState();
    AuthGate._currentState = this;
  }

  @override
  void dispose() {
    AuthGate._currentState = null;
    super.dispose();
  }

  // Check profile completion using both online and offline methods
  Future<bool> _checkProfileComplete(String userId) async {
    // Cache result for same user to avoid repeated checks
    if (_lastCheckedUserId == userId && _lastCheckResult != null && !_profileJustCompleted) {
      print('Using cached profile check result: $_lastCheckResult');
      return _lastCheckResult!;
    }

    // If profile was just completed, return true immediately
    if (_profileJustCompleted) {
      print('Profile just completed, skipping check');
      _lastCheckedUserId = userId;
      _lastCheckResult = true;
      return true;
    }

    print('Checking profile completion for user: $userId');

    try {
      // Try online first with timeout
      final result = await UserService().isProfileComplete(userId).timeout(
        const Duration(seconds: 5),
        onTimeout: () async {
          // Fallback to offline check
          print('Online check timeout, using offline check');
          return await OfflineUserService.isProfileCompleteOffline(userId);
        },
      );

      print('Profile completion check result: $result');
      _lastCheckedUserId = userId;
      _lastCheckResult = result;
      return result;
    } catch (e) {
      print('Error checking profile online, using offline: $e');
      final result = await OfflineUserService.isProfileCompleteOffline(userId);
      print('Offline profile completion check result: $result');
      _lastCheckedUserId = userId;
      _lastCheckResult = result;
      return result;
    }
  }

  void clearCache() {
    setState(() {
      _lastCheckResult = null;
      _profileJustCompleted = true;
    });
  }

  void setProfileCompleted() {
    setState(() {
      _profileJustCompleted = true;
      _lastCheckResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBackground,
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          // Reset cache if user changed
          if (_lastCheckedUserId != user.uid) {
            _lastCheckResult = null;
            _profileJustCompleted = false;
          }

          // Check if profile is complete
          return FutureBuilder<bool>(
            future: _checkProfileComplete(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: AppColors.primaryBackground,
                  body: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                );
              }

              final isProfileComplete = profileSnapshot.data ?? false;
              
              if (!isProfileComplete) {
                // Profile not complete, navigate to complete profile screen
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed('/complete-profile');
                });
                return const Scaffold(
                  backgroundColor: AppColors.primaryBackground,
                  body: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                );
              }

              // Profile is complete, ensure Firestore user document exists
              return FutureBuilder(
                future: UserService().upsertCurrentUser(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      backgroundColor: AppColors.primaryBackground,
                      body: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)),
                    );
                  }
                  return const MainNavigationScreen();
                },
              );
            },
          );
        }
        return const LoginScreen();
      },
    );
  }
}
