import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_navigation.dart';
import '../core/constants/app_colors.dart';
import '../features/profile/presentation/complete_profile_screen.dart';
import 'login/login_screen.dart';
import 'user/user_service.dart';
import 'offline_user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Check profile completion using both online and offline methods
  Future<bool> _checkProfileComplete(String userId) async {
    try {
      // Try online first with timeout
      return await UserService().isProfileComplete(userId).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Fallback to offline check
          print('Online check timeout, using offline check');
          return OfflineUserService.isProfileCompleteOffline(userId);
        },
      );
    } catch (e) {
      print('Error checking profile online, using offline: $e');
      return await OfflineUserService.isProfileCompleteOffline(userId);
    }
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
                // Profile not complete, show complete profile screen
                return const CompleteProfileScreen();
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
