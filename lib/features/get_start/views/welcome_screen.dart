import 'package:arini_plus_app/core/widgets/custom_height_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/helpers/nav_helper.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/my_button.dart';
import '../../auth/views/login_screen.dart';
import '../../auth/views/register_screen.dart';
import '../../home/views/main_home_screen.dart';
import '../../../core/services/cache/app_preferences.dart';
import '../../../core/enums/enums.dart';

class WelcomeScreen extends StatelessWidget with NavHelper {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 22.h),
            Center(child: Image.asset(AssetsApp.logoWelcome, width: 110.w)),
            Expanded(
              flex: 6,
              child: Image.asset(
                AssetsApp.carWelcomeImage,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: getSemiBoldStyle(
                        size: 24,
                        color: AppColors.black10,
                      ),
                      children: [
                        TextSpan(text: localizations.hire),
                        TextSpan(
                          text: localizations.yourCarEasily,
                          style: getBoldStyle(
                            size: 24,
                            color: AppColors.primaryNormal,
                          ),
                        ),
                        TextSpan(text: localizations.fromTrustedOffices),
                      ],
                    ),
                  ),
                  CustomHeightSpacer(height: 12.h),
                  Text(
                    localizations.marketTagline,
                    textAlign: TextAlign.center,
                    style: getRegularStyle(size: 14, color: AppColors.font01),
                  ),
                  CustomHeightSpacer(height: 24),
                  MyButton(
                    textButton: localizations.login,
                    icon: AppIcons.login,
                    onTap: () => jump(context, const LoginScreen(), false),
                  ),
                  CustomHeightSpacer(height: 16),
                  MyButton(
                    textButton: localizations.register,
                    icon: AppIcons.user,
                    onTap: () => jump(context, const RegisterScreen(), false),
                    bGColor: AppColors.primaryLight,
                    textColor: AppColors.primaryNormal,
                  ),
                  CustomHeightSpacer(height: 12),
                  GestureDetector(
                    onTap: () async {
                      await AppPreferences().setter(CacheKeys.guestMode, true);
                      if (context.mounted) {
                        jump(context, const MainHomeScreen(), true);
                      }
                    },
                    child: Text(
                      localizations.logInAsAVisitor,
                      style:
                          getMediumStyle(
                            size: 14.sp,
                            color: AppColors.secondaryNormal,
                          ).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.secondaryNormal,
                          ),
                    ),
                  ),
                  CustomHeightSpacer(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
