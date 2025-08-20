import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main_navigation.dart';
import '../core/constants/app_colors.dart';
import '../features/profile/presentation/complete_profile_screen.dart';
import 'login/login_screen.dart';
import 'user/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
            future: UserService().isProfileComplete(user.uid),
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
