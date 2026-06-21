import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'my_button.dart';

class DataStateView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback? onRetry;
  final bool compact;

  const DataStateView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionText,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12.w : 28.w,
          vertical: compact ? 10.h : 28.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.info,
              size: compact ? 28.sp : 42.sp,
              color: AppColors.primaryNormal,
            ),
            SizedBox(height: compact ? 6.h : 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: getSemiBoldStyle(
                size: compact ? 13 : 16,
                color: AppColors.black10,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: getRegularStyle(
                size: compact ? 10 : 12,
                color: AppColors.font01,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 8.h : 14.h),
              SizedBox(
                width: compact ? 110.w : 180.w,
                child: MyButton(
                  textButton: actionText,
                  heightButton: compact ? 36 : 44,
                  textSize: compact ? 11 : 13,
                  borderRadius: 9,
                  onTap: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
