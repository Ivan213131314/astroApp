import 'dart:io';

import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:fl_astro_circle/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DateTime? backPressTime;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        bool backStatus = onWillPop();
        if (backStatus) {
          exit(0);
        }
      },
      child: Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            color: scaffoldBgColor.withValues(alpha: 0.5),
            image: const DecorationImage(
              image: AssetImage("assets/auth/bgImage.png"),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scaffoldBgColor,
                  const Color(0xFF301B87).withValues(alpha: 0),
                ],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(fixPadding * 2.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  loginText(),
                  heightSpace,
                  heightSpace,
                  welcomeText(),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  googleSignInButton(),
                  heightSpace,
                  heightSpace,
                  Platform.isIOS ? appleSignInButton() : const SizedBox(),
                  Platform.isIOS ? heightSpace : const SizedBox(),
                  Platform.isIOS ? heightSpace : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  welcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'login.welcome_text'),
        style: medium14WhiteF4,
        textAlign: TextAlign.center,
      ),
    );
  }

  loginText() {
    return Text(
      getTranslation(context, 'login.login'),
      style: bold24White,
      textAlign: TextAlign.center,
    );
  }

  googleSignInButton() {
    return InkWell(
      onTap: _isLoading ? null : _handleGoogleSignIn,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.2, horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
          color: recBgColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: recBgColor.withValues(alpha: 0.25),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SpinKitThreeBounce(
                color: primaryColor,
                size: 20,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.g_mobiledata,
                        color: whiteColor,
                        size: 24,
                      );
                    },
                  ),
                  widthSpace,
                  Text(
                    getTranslation(context, 'login.sign_in_with_google'),
                    style: bold20White,
                  ),
                ],
              ),
      ),
    );
  }

  appleSignInButton() {
    return InkWell(
      onTap: _isLoading ? null : _handleAppleSignIn,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.2, horizontal: fixPadding * 2.0),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: whiteColor.withValues(alpha: 0.25),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.apple,
              color: black03Color,
              size: 24,
            ),
            widthSpace,
            Text(
              getTranslation(context, 'login.sign_in_with_apple'),
              style: bold20Black03,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && mounted) {
        Navigator.pushReplacementNamed(context, '/bottombar');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: redColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithApple();
      if (userCredential != null && mounted) {
        Navigator.pushReplacementNamed(context, '/bottombar');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: redColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  onWillPop() {
    DateTime now = DateTime.now();
    if (backPressTime == null ||
        now.difference(backPressTime!) >= const Duration(seconds: 2)) {
      backPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: whiteColor,
          content: Text(
            getTranslation(context, 'exit_app.exit_text'),
            style: bold15Black03,
          ),
        ),
      );
      return false;
    } else {
      return true;
    }
  }
}
