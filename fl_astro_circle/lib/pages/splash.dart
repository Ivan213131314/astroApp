import 'dart:async';

import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      checkAppStatus();
    });
    super.initState();
  }

  Future<void> checkAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;
    
    if (!mounted) return;
    
    // Проверяем, залогинен ли пользователь
    final currentUser = _authService.currentUser;
    
    if (currentUser != null) {
      // Если пользователь залогинен, идём на главную страницу
      Navigator.pushReplacementNamed(context, '/bottombar');
    } else if (hasCompletedOnboarding) {
      // Если onboarding пройден но пользователь не залогинен, идём на экран выбора авторизации
      Navigator.pushReplacementNamed(context, '/authChoice');
    } else {
      // Если не пройден onboarding, показываем его
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splash/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/splash/logo.png",
                height: size.height * 0.2,
                width: size.height * 0.2,
              ),
              const Text(
                "Astro Circle",
                style: bold30Text,
              )
            ],
          ),
        ),
      ),
    );
  }
}
