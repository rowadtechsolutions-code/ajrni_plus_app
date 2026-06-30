import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/api_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/services/cache/app_preferences.dart';
import 'core/services/providers/language_provider.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/connectivity_listener.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/notifications/providers/notifications_provider.dart';
import 'services/fcm_token_service.dart';
import 'features/cars/providers/cars_provider.dart';
import 'features/favorites/providers/favorites_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/offices/providers/offices_provider.dart';
import 'features/get_start/views/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.deferFirstFrame();

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

  final initialization = _initializeServices();
  runApp(MyApp(initialization: initialization));

  unawaited(
    initialization.then((_) => ConnectivityController.init(navigatorKey)),
  );
}

Future<void> _initializeServices() async {
  await Firebase.initializeApp();
  await AppPreferences().initCache;
  await Supabase.initialize(
    url: ApiConstants.baseUrl,
    publishableKey: ApiConstants.apiKey,
  );

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await FcmTokenService().init();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
  await localNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (response) {
      debugPrint('=========== NOTIFICATION TAPPED ===========');
      debugPrint('Payload: ${response.payload}');
      debugPrint('===========================================');
    },
  );

  const androidChannel = AndroidNotificationChannel(
    'ajrni_high_importance_channel',
    'Ajrni Plus Notifications',
    description: 'Notifications for Ajrni Plus',
    importance: Importance.max,
    playSound: true,
  );
  final androidPlugin = localNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(androidChannel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'ajrni_high_importance_channel',
            'Ajrni Plus Notifications',
            channelDescription: 'Notifications for Ajrni Plus',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  });

  await androidPlugin?.requestNotificationsPermission();
}

class MyApp extends StatelessWidget {
  final Future<void> initialization;

  const MyApp({super.key, required this.initialization});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => LanguageProvider()),
            ChangeNotifierProvider(create: (context) => AuthProvider()),
            ChangeNotifierProvider(create: (context) => NotificationsProvider()),
            ChangeNotifierProvider(create: (context) => CarsProvider()),
            ChangeNotifierProvider(create: (context) => FavoritesProvider()),
            ChangeNotifierProvider(create: (context) => HomeProvider()),
            ChangeNotifierProvider(create: (context) => OfficesProvider()),
            // ChangeNotifierProvider(create: (context) => UsersProvider()),
          ],
          child: MyMaterialApp(initialization: initialization),
        );
      },
    );
  }
}

class MyMaterialApp extends StatelessWidget {
  final Future<void> initialization;

  const MyMaterialApp({super.key, required this.initialization});

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
          home: SplashScreen(initialization: initialization),
          locale: Locale(lang.language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('ar'), Locale('en')],
        );
      },
    );
  }
}
