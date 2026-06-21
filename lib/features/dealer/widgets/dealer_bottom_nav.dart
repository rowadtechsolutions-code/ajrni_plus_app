import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../helpers/dealer_text.dart';

class DealerBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const DealerBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    final items = [
      (AppIcons.car, t.myCars),
      (AppIcons.whatsapp, t.requests),
      (Icons.insights_outlined, t.statistics),
      (AppIcons.profile, t.profile),
    ];
    return SafeArea(
      top: false,
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.border01.withValues(alpha: .7)),
          ),
        ),
        child: Row(
          children: List.generate(items.length, (itemIndex) {
            final selected = itemIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(itemIndex),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[itemIndex].$1,
                      size: 22.sp,
                      color: selected
                          ? AppColors.primaryNormal
                          : AppColors.hint,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      items[itemIndex].$2,
                      maxLines: 1,
                      style: getMediumStyle(
                        size: 10,
                        color: selected
                            ? AppColors.primaryNormal
                            : AppColors.font01,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
