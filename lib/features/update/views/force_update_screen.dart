import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arini_plus_app/core/l10n/app_localizations.dart';
import 'package:arini_plus_app/core/services/providers/language_provider.dart';
import 'package:arini_plus_app/core/theme/app_colors.dart';
import 'package:arini_plus_app/core/theme/app_text_styles.dart';
import 'package:arini_plus_app/core/widgets/my_button.dart';
import 'package:arini_plus_app/features/update/services/update_service.dart';

class ForceUpdateScreen extends StatefulWidget {
  final AppVersion appVersion;

  const ForceUpdateScreen({super.key, required this.appVersion});

  @override
  State<ForceUpdateScreen> createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  bool _isLaunching = false;

  Future<void> _openStore() async {
    final url = widget.appVersion.storeUrl;
    if (url == null || url.isEmpty) return;

    setState(() => _isLaunching = true);

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('ForceUpdateScreen: failed to open store URL: $e');
    } finally {
      if (mounted) {
        setState(() => _isLaunching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        Icons.system_update_rounded,
                        size: 36.sp,
                        color: AppColors.primaryNormal,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      l.updateAvailableTitle,
                      style: getSemiBoldStyle(size: 18, color: AppColors.black10),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l.updateAvailableDescription,
                      style: getRegularStyle(size: 14, color: AppColors.font01),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    MyButton(
                      textButton: l.updateNow,
                      heightButton: 50,
                      textSize: 15,
                      borderRadius: 10,
                      isLoading: _isLaunching,
                      onTap: _openStore,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 16.w,
                child: GestureDetector(
                  onTap: () {
                    context.read<LanguageProvider>().changeLanguage();
                  },
                  child: Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        context.watch<LanguageProvider>().language == 'ar'
                            ? 'EN'
                            : 'ع',
                        style: getSemiBoldStyle(
                          size: 14,
                          color: AppColors.primaryNormal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
