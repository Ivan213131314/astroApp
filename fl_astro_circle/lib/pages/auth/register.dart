import 'package:fl_astro_circle/localization/localization_const.dart';
import 'package:fl_astro_circle/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../theme/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    return Scaffold(
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
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: fixPadding * 2.0),
                    children: [
                      registerTitle(),
                      heightSpace,
                      welcomeText(),
                      heightSpace,
                      heightSpace,
                      heightSpace,
                      emailField(),
                      heightSpace,
                      heightSpace,
                      passwordField(),
                      heightSpace,
                      heightSpace,
                      registerButton(),
                      heightSpace,
                      heightSpace,
                      orDivider(),
                      heightSpace,
                      heightSpace,
                      googleSignInButton(),
                      heightSpace,
                      heightSpace,
                      alreadyHaveAccountText(),
                      heightSpace,
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  registerButton() {
    return InkWell(
      onTap: _isLoading ? null : _handleEmailRegister,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: fixPadding * 1.2,
          horizontal: fixPadding * 2.0,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: primaryColor,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 6,
              )
            ]),
        alignment: Alignment.center,
        child: _isLoading
            ? const SpinKitThreeBounce(
                color: whiteColor,
                size: 20,
              )
            : Text(
                getTranslation(context, 'register.register'),
                style: bold20White,
              ),
      ),
    );
  }

  Future<void> _handleEmailRegister() async {
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
      final userCredential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getTranslation(context, 'login.verification_email_sent')),
            backgroundColor: primaryColor,
            duration: const Duration(seconds: 3),
          ),
        );

        await _authService.reloadUser();
        
        if (!_authService.isEmailVerified()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(getTranslation(context, 'login.please_verify_email')),
              backgroundColor: primaryColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }

        Navigator.pushReplacementNamed(context, '/bottombar');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('email-already-in-use')) {
          errorMessage = getTranslation(context, 'login.email_already_in_use');
        } else if (errorMessage.contains('weak-password')) {
          errorMessage = getTranslation(context, 'login.weak_password');
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

  emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'register.email_address'),
          style: medium14WhiteF4,
        ),
        heightSpace,
        Container(
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
              enabled: true,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: fixPadding * 1.4, horizontal: fixPadding * 2.0),
              prefixIcon: const Icon(
                Icons.mail_outline,
                size: 20,
                color: whiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'register.password'),
          style: medium14WhiteF4,
        ),
        heightSpace,
        Container(
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
              enabled: true,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: fixPadding * 1.4, horizontal: fixPadding * 2.0),
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
        ),
      ],
    );
  }

  welcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Text(
        getTranslation(context, 'register.welcome_text'),
        style: bold14GreyD4,
        textAlign: TextAlign.center,
      ),
    );
  }

  registerTitle() {
    return Text(
      getTranslation(context, 'register.register'),
      style: bold24WhiteF4,
      textAlign: TextAlign.center,
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
                    getTranslation(context, 'register.sign_in_with_google'),
                    style: bold20White,
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

  alreadyHaveAccountText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: whiteColor.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text(
            'Login',
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
}
