import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/assets_app.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AssetsApp.logoWelcome, width: 110.w),
                SizedBox(height: 24.h),
                Text(
                  l.officePending,
                  textAlign: TextAlign.center,
                  style: getSemiBoldStyle(size: 20, color: AppColors.black10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
