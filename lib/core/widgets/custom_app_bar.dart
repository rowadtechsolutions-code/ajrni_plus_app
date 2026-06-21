import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final bool isBack;
  final bool showDivider;
  final double horizontalPadding;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isBack = true,
    this.showDivider = true,
    this.horizontalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58.h,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.w,
        vertical: 9.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: AppColors.border01.withValues(alpha: .65),
                  width: 1.w,
                ),
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 0,
            child: Visibility(
              visible: isBack,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: isBack ? () => Navigator.pop(context) : null,
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    AppIcons.arrowForward,
                    size: 19.sp,
                    color: AppColors.font01,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: isBack ? 52.w : 0,
            left: 0,
            child: Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getMediumStyle(size: 13, color: AppColors.font02),
            ),
          ),
        ],
      ),
    );
  }
}
