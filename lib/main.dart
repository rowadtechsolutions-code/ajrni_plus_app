import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/services/cache/app_preferences.dart';
import 'core/services/providers/language_provider.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/connectivity_listener.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cars/providers/cars_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/offices/providers/offices_provider.dart';
import 'features/get_start/views/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize cache
  await AppPreferences().initCache;

  /// Initialize supabase
  await Supabase.initialize(
    url: ApiConstants.baseUrl,
    publishableKey: ApiConstants.apiKey,
  );

  ///  listen for password recovery link
  // Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  //   final event = data.event;
  //
  //   if (event == AuthChangeEvent.passwordRecovery) {
  //     navigatorKey.currentState?.pushNamed('/create-new-password');
  //   }
  // });

  /// Initialize system ui (Instagram-style edge-to-edge)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const MyApp());

  ConnectivityController.init(navigatorKey);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => LanguageProvider()),
            ChangeNotifierProvider(create: (context) => AuthProvider()),
            ChangeNotifierProvider(create: (context) => CarsProvider()),
            ChangeNotifierProvider(create: (context) => FavoritesProvider()),
            ChangeNotifierProvider(create: (context) => HomeProvider()),
            ChangeNotifierProvider(create: (context) => OfficesProvider()),
            // ChangeNotifierProvider(create: (context) => UsersProvider()),
          ],
          child: const MyMaterialApp(),
        );
      },
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, lang, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(
            fontFamily: 'ibmPlexSansArabic',
            primaryColor: AppColors.primaryNormal,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryNormal,
              primary: AppColors.primaryNormal,
              secondary: AppColors.secondaryNormal,
              surface: Colors.white,
            ),
            splashColor: Colors.transparent,
            scaffoldBackgroundColor: AppColors.background,
            highlightColor: Colors.transparent,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontFamily: 'ibmPlexSansArabic',
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              iconTheme: IconThemeData(color: AppColors.navy),
            ),
          ),

          debugShowCheckedModeBanner: false,
          // routes: {
          //   '/create-new-password': (context) =>
          //   const CreateNewPasswordScreen(),
          // },
          home: const SplashScreen(),
          locale: Locale(lang.language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('ar'), Locale('en')],
        );
      },
    );
  }
}
