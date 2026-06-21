import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'custom_height_spacer.dart';
import 'custom_svg.dart';

class NoData extends StatelessWidget {
  final String title;
  final String suTitle;
  final String image;
  final double widthOfImage;
  final double heightOfImage;

  const NoData({
    super.key,
    required this.title,
    required this.suTitle,
    required this.image,
    this.widthOfImage = 280,
    this.heightOfImage = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomSvg(path: image, width: widthOfImage.w, height: heightOfImage.h),
        CustomHeightSpacer(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: getBoldStyle(size: 16, color: AppColors.font02),
        ),
        CustomHeightSpacer(height: 8),
        Text(
          suTitle,
          textAlign: TextAlign.center,
          style: getRegularStyle(size: 14, color: AppColors.font01),
        ),
      ],
    );
  }
}
