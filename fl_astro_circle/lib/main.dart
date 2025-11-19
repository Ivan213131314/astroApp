import 'package:fl_astro_circle/localization/localization.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:fl_astro_circle/pages/screens.dart';
import 'localization/localization_const.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Astro Circle',
        theme: ThemeData(
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: scaffoldBgColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            brightness: Brightness.dark,
          ),
          primaryColor: primaryColor,
          appBarTheme: const AppBarTheme(
            surfaceTintColor: Colors.transparent,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            surfaceTintColor: Colors.transparent,
          ),
          inputDecorationTheme: InputDecorationTheme(
            prefixIconColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? primaryColor
                  : greyColor,
            ),
          ),
        ),
        home: const SplashScreen(),
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('id'),
          Locale('zh'),
          Locale('ar'),
        ],
        localizationsDelegates: [
          Localization.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocale) {
          for (var locale in supportedLocale) {
            if (locale.languageCode != deviceLocale?.languageCode) {
              return deviceLocale;
            }
          }
          return supportedLocale.first;
        },
        onGenerateRoute: routes,
      ),
    );
  }

  Route<dynamic>? routes(settings) {
    switch (settings.name) {
      case '/':
        return PageTransition(
          child: const SplashScreen(),
          type: PageTransitionType.fade,
        );
      case '/onboarding':
        return PageTransition(
          child: const OnboardingScreen(),
          type: PageTransitionType.fade,
        );
      case '/authChoice':
        return PageTransition(
          child: const AuthChoiceScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/login':
        return PageTransition(
          child: const LoginScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/register':
        return PageTransition(
          child: const RegisterScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/bottombar':
        return PageTransition(
          child: const BottomBar(),
          type: PageTransitionType.rightToLeft,
        );
      case '/home':
        return PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/search':
        return PageTransition(
          child: const SearchScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/horoscope':
        return PageTransition(
          child: const HoroscopeScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/horoscopeDetail':
        return PageTransition(
          child: const HoroscopeDetailScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/astrologers':
        return PageTransition(
          child: const AstrologersScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/astrologersDetail':
        return PageTransition(
          child: const AstrologerDetailScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/review':
        return PageTransition(
          child: const ReviewScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/chat':
        return PageTransition(
          child: const ChatScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/call':
        return PageTransition(
          child: const CallScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/videocall':
        return PageTransition(
          child: const VideoCallScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/numorology':
        return PageTransition(
          child: const NumorologyScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/numorologyDetail':
        return PageTransition(
          child: const NumorologyDetailScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/compatibility':
        return PageTransition(
          child: const CompatibilityScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/compatibilityDetail':
        return PageTransition(
          child: const CompatibilityDetailScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/plamReader':
        return PageTransition(
          child: const PlamReaderScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/plamReaderDetail':
        return PageTransition(
          child: const PlamReaderDetailScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/natalchart':
        return PageTransition(
          child: const NatalChartScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/natalchartDetail':
        return PageTransition(
          child: const NatalChartDetailScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/message':
        return PageTransition(
          child: const MessageScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/notification':
        return PageTransition(
          child: const NotificationScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/profile':
        return PageTransition(
          child: const ProfileScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/editProfile':
        return PageTransition(
          child: const EditProfileScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/language':
        return PageTransition(
          child: const LanguageScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/aboutUs':
        return PageTransition(
          child: const AboutUsScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/subscribe':
        return PageTransition(
          child: const SubscribeScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/paymentMethod':
        return PageTransition(
          child: const PaymentMethodScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/mastercard':
        return PageTransition(
          child: const MasterCardScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/success':
        return PageTransition(
          child: const SuccessScreen(),
          type: PageTransitionType.rightToLeft,
        );
      default:
        return null;
    }
  }
}
