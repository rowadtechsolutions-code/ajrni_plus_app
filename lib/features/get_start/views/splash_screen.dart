import 'package:arini_plus_app/core/widgets/custom_height_spacer.dart';
import 'package:arini_plus_app/features/get_start/views/welcome_screen.dart';
import 'package:arini_plus_app/services/fcm_token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/assets_app.dart';
import '../../../../core/helpers/nav_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../core/enums/enums.dart';
import '../../../core/services/cache/app_preferences.dart';
import '../../../core/services/providers/language_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../dealer/views/dealer_dashboard_screen.dart';
import '../../home/views/main_home_screen.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> initialization;

  const SplashScreen({super.key, required this.initialization});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with NavHelper {
  bool _splashImageReady = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_splashImageReady) return;
    _splashImageReady = true;
    precacheImage(const AssetImage(AssetsApp.splashScreen), context)
        .whenComplete(WidgetsBinding.instance.allowFirstFrame);
  }

  Future<void> init() async {
    final minimumDisplayTime = Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    await widget.initialization;
    if (!mounted) return;

    context.read<LanguageProvider>().loadSavedLanguage();

    final session = await AuthService().restoreSession();
    final guestMode =
        AppPreferences().getter(CacheKeys.guestMode) as bool? ?? false;
    if (!mounted) return;
    Provider.of<AuthProvider>(context, listen: false).setSession(session);
    FcmTokenService().syncCurrentDeviceToken();

    await minimumDisplayTime;

    if (!mounted) return;

    jump(
      context,
      session == null
          ? guestMode
                ? const MainHomeScreen()
                : const WelcomeScreen()
          : session.type == AccountType.office
          ? const DealerDashboardScreen()
          : const MainHomeScreen(),
      true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetsApp.splashScreen, fit: BoxFit.cover),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
                CustomHeightSpacer(height: 16),
                Text(
                  'Version 1.0.0+2',
                  style: getMediumStyle(size: 13.sp, color: AppColors.white),
                ),
                CustomHeightSpacer(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
