import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';

class ContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const ContentScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: title),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.r),
                child: Text(
                  content,
                  textAlign: TextAlign.start,
                  style: getRegularStyle(
                    size: 14,
                    color: AppColors.font02,
                  ).copyWith(height: 1.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
