import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'features/profile/presentation/complete_profile_screen.dart';
import 'main_navigation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp();
  } else {
    // TODO: tampilkan fallback UI atau pesan "Jalankan di Android"
  }

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
      home: const AuthGate(),
      routes: {
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/main': (context) => const MainNavigationScreen(),
      },
    );
  }
}
