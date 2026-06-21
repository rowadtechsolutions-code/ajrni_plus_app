import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_height_spacer.dart';

class AuthHeaderSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String logoAsset;

  const AuthHeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.logoAsset,
  });

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: 0,
      end: 0,
      top: 126.h,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 76.h,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Image.asset(logoAsset, width: 140.w),
              ),
            ),
            Text(title, style: getSemiBoldStyle(size: 18, color: Colors.white)),
            CustomHeightSpacer(height: 12),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getRegularStyle(
                size: 13,
                color: Colors.white.withValues(alpha: .72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
