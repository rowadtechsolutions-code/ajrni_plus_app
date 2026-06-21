import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = [
      (AppIcons.home, AppIcons.homeBold, l.home),
      (AppIcons.car, AppIcons.carBold, l.cars),
      (AppIcons.office, AppIcons.officeBold, l.offices),
      (AppIcons.heart, AppIcons.heartBold, l.favorites),
      (AppIcons.profile, AppIcons.profile, l.myAccount),
    ];
    return SafeArea(
      top: false,
      child: Container(
        height: 68.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.border01.withValues(alpha: .7)),
          ),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final selected = selectedIndex == index;
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? items[index].$2 : items[index].$1,
                      size: 21.sp,
                      color: selected
                          ? AppColors.primaryNormal
                          : AppColors.hint,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      items[index].$3,
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
