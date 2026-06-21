import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'custom_svg.dart';

class RowInfoProfile extends StatelessWidget {
  final String title;
  final String icon;

  const RowInfoProfile({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomSvg(path: icon),
        SizedBox(width: 4.w),
        Text(title, style: getRegularStyle(size: 14, color: AppColors.font01)),
      ],
    );
  }
}
