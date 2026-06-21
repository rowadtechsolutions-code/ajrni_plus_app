import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'my_button.dart';

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
  bool destructive = false,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: getSemiBoldStyle(size: 18, color: AppColors.black10),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: getRegularStyle(size: 13, color: AppColors.font01),
          ),
          actionsPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
          actions: [
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    textButton: cancelText,
                    heightButton: 44,
                    textSize: 13,
                    isSecondary: true,
                    onTap: () => Navigator.pop(context, false),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: MyButton(
                    textButton: confirmText,
                    heightButton: 44,
                    textSize: 13,
                    bGColor: destructive
                        ? AppColors.error
                        : AppColors.primaryNormal,
                    onTap: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ) ??
      false;
}
