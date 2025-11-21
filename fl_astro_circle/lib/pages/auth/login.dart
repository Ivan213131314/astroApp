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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  backButton(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        loginText(),
                  heightSpace,
                  heightSpace,
                  welcomeText(),
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  heightSpace,
                  emailField(),
                  heightSpace,
                  heightSpace,
                  passwordField(),
                  heightSpace,
                  heightSpace,
                  loginButton(),
                  heightSpace,
                  heightSpace,
                  orDivider(),
                  heightSpace,
                  heightSpace,
                  googleSignInButton(),
                  heightSpace,
                  heightSpace,
                        Platform.isIOS ? appleSignInButton() : const SizedBox(),
                        Platform.isIOS ? heightSpace : const SizedBox(),
                        Platform.isIOS ? heightSpace : const SizedBox(),
                        dontHaveAccountText(),
                        heightSpace,
                      ],
                    ),
                  ),
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

  emailField() {
    return Container(
      decoration: BoxDecoration(
        color: recBgColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: recBgColor.withValues(alpha: 0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: TextField(
        controller: _emailController,
        style: medium15WhiteF4,
        keyboardType: TextInputType.emailAddress,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: getTranslation(context, 'register.enter_email'),
          hintStyle: medium15Grey,
          contentPadding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.4,
            horizontal: fixPadding * 2.0,
          ),
          prefixIcon: const Icon(
            Icons.mail_outline,
            size: 20,
            color: whiteColor,
          ),
        ),
      ),
    );
  }

  passwordField() {
    return Container(
      decoration: BoxDecoration(
        color: recBgColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: recBgColor.withValues(alpha: 0.25),
            blurRadius: 6,
          )
        ],
      ),
      child: TextField(
        controller: _passwordController,
        style: medium15WhiteF4,
        obscureText: _obscurePassword,
        cursorColor: primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: getTranslation(context, 'login.enter_password'),
          hintStyle: medium15Grey,
          contentPadding: const EdgeInsets.symmetric(
            vertical: fixPadding * 1.4,
            horizontal: fixPadding * 2.0,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 20,
            color: whiteColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: whiteColor,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  loginButton() {
    return InkWell(
      onTap: _isLoading ? null : _handleEmailLogin,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.2,
          horizontal: fixPadding * 2.0,
        ),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 6,
            )
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SpinKitThreeBounce(
                color: whiteColor,
                size: 20,
              )
            : Text(
                getTranslation(context, 'login.login'),
                style: bold20White,
              ),
      ),
    );
  }

  orDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: whiteColor.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding),
          child: Text(
            getTranslation(context, 'register.or'),
            style: medium14WhiteF4,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: whiteColor.withValues(alpha: 0.3),
          ),
        ),
      ],
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

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getTranslation(context, 'login.fill_all_fields')),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getTranslation(context, 'login.password_min_length')),
          backgroundColor: redColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null && mounted) {
        await _authService.reloadUser();
        Navigator.pushReplacementNamed(context, '/bottombar');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('user-not-found')) {
          errorMessage = getTranslation(context, 'login.user_not_found');
        } else if (errorMessage.contains('wrong-password')) {
          errorMessage = getTranslation(context, 'login.wrong_password');
        } else if (errorMessage.contains('invalid-email')) {
          errorMessage = getTranslation(context, 'login.invalid_email');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  dontHaveAccountText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(
            color: whiteColor.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text(
            'Register',
            style: TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        height: 35,
        width: 35,
        margin: const EdgeInsets.only(
            left: fixPadding * 2.0,
            right: fixPadding * 2,
            top: fixPadding * 2,
            bottom: fixPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: recBgColor,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: whiteColor,
          size: 22,
        ),
      ),
    );
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
