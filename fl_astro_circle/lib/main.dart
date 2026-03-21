import 'package:fl_astro_circle/localization/localization.dart';
import 'package:fl_astro_circle/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:fl_astro_circle/pages/screens.dart';
import 'localization/localization_const.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_astro_circle/config/debug_config.dart';
import 'package:fl_astro_circle/services/superwall_diagnostics_delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Загружаем переменные окружения
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp();
  
  // Включаем Firestore persistence для мгновенной загрузки из кэша
  // distinct() в стримах предотвратит показ старых данных других пользователей
  FirebaseFirestore.instance.settings = 
      const Settings(persistenceEnabled: true);
  
  // Инициализация Superwall
  final superwallOptions = SuperwallOptions();
  if (DebugConfig.enableSuperwallDiagnostics) {
    // superwallkit_flutter 2.4.4 does not expose a public testMode/testModeAlways
    // flag in SuperwallOptions, so in debug builds we enable the maximum
    // diagnostics surface the Flutter wrapper provides.
    superwallOptions.logging.level = LogLevel.debug;
    superwallOptions.logging.scopes = {LogScope.all};
  }
  Superwall.configure(
    'pk_zZA_dWvZ0yUQUDpWQsBVO',
    options: superwallOptions,
  );

  if (DebugConfig.enableSuperwallDiagnostics) {
    DebugConfig.log(
      'Superwall debug diagnostics enabled. '
      'Explicit testModeAlways is not exposed by superwallkit_flutter 2.4.4.',
    );
    Superwall.shared.setDelegate(const SuperwallDiagnosticsDelegate());
  }
  
  // Установить начальный статус подписки (неподписан)
  // Это нужно чтобы Superwall не ждал таймаута
  await Superwall.shared.setSubscriptionStatus(SubscriptionStatusInactive());
  
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
          child: const WelcomeOnboardingScreen(),
          type: PageTransitionType.fade,
        );
      case '/onboardingGoals':
        return PageTransition(
          child: const GoalsScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingGoalsInfo':
        return PageTransition(
          child: const GoalsInfoScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingMainReason':
        return PageTransition(
          child: const MainReasonScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingGoalTogether':
        return PageTransition(
          child: const GoalTogetherScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingBirthChartIntro':
        return PageTransition(
          child: const BirthChartIntroScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingDateOfBirth':
        return PageTransition(
          child: const DateOfBirthScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingTimeOfBirth':
        return PageTransition(
          child: const TimeOfBirthScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingPlaceOfBirth':
        return PageTransition(
          child: const PlaceOfBirthScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingHoroscopesQuestion':
        return PageTransition(
          child: const HoroscopesQuestionScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingGender':
        return PageTransition(
          child: const GenderScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingName':
        return PageTransition(
          child: const NameScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingBirthChartQuestion':
        return PageTransition(
          child: const BirthChartQuestionScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingRelationshipStatus':
        return PageTransition(
          child: const RelationshipStatusScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingInterests':
        return PageTransition(
          child: const InterestsScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingCompatibilityQuestion':
        return PageTransition(
          child: const CompatibilityQuestionScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingPremium':
        return PageTransition(
          child: const PremiumScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/onboardingAlmostThere':
        return PageTransition(
          child: const AlmostThereScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/termsOfService':
        return PageTransition(
          child: const TermsOfServiceScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/privacyPolicy':
        return PageTransition(
          child: const PrivacyPolicyScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/subscriptionTerms':
        return PageTransition(
          child: const SubscriptionTermsScreen(),
          type: PageTransitionType.rightToLeft,
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
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['selectedIndex'] as int? ?? 0;
        return PageTransition(
          child: BottomBar(initialIndex: initialIndex),
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
          settings: settings,
        );
      case '/horoscopeDeepDetail':
        return PageTransition(
          child: const HoroscopeDeepDetailScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
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
      case '/numerologyLoading':
        return PageTransition(
          child: const NumerologyLoadingWrapper(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/numerologyResult':
        return PageTransition(
          child: const NumerologyResultWrapper(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/numerologyDeepDetail':
        return PageTransition(
          child: const NumerologyDeepDetailScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/compatibility':
        return PageTransition(
          child: const CompatibilityScreen(showBackButton: true),
          type: PageTransitionType.rightToLeft,
        );
      case '/compatibilityBirthDate':
        return PageTransition(
          child: const CompatibilityBirthDateScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/compatibilityDetail':
        return PageTransition(
          child: const CompatibilityDetailScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/compatibilityDeepDetail':
        return PageTransition(
          child: const CompatibilityDeepDetailScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/plamReader':
        return PageTransition(
          child: const PlamReaderScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/plamReaderLoading':
        return PageTransition(
          child: const PlamReaderLoadingScreen(),
          type: PageTransitionType.fade,
          settings: settings,
        );
      case '/plamReaderDetail':
        return PageTransition(
          child: const PlamReaderDetailScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
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
          settings: settings,
        );
      case '/natalChartDeepDetail':
        return PageTransition(
          child: const NatalChartDeepDetailScreen(),
          type: PageTransitionType.rightToLeft,
          settings: settings,
        );
      case '/message':
        return PageTransition(
          child: const MessageScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/universeMessage':
        return PageTransition(
          child: const UniverseMessageScreen(),
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
      case '/astrologerChat':
        return PageTransition(
          child: const AstrologerChatScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case '/universeSign':
        return PageTransition(
          child: const UniverseSignScreen(),
          type: PageTransitionType.rightToLeft,
        );
      default:
        return null;
    }
  }
}
