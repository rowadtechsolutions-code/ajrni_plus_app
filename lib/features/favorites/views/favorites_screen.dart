import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/views/login_screen.dart';
import '../../cars/widgets/car_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final favorites = context.watch<FavoritesProvider>().cars;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 18.h),
            child: Text(
              l.favorites,
              style: getMediumStyle(size: 15, color: AppColors.font02),
            ),
          ),
          Expanded(
            child: !auth.isLoggedIn
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(28.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.heart,
                            size: 54.sp,
                            color: AppColors.secondaryNormal,
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'أنت تستخدم التطبيق كزائر',
                            textAlign: TextAlign.center,
                            style: getSemiBoldStyle(
                              size: 16,
                              color: AppColors.black10,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'سجّل الدخول للوصول إلى سياراتك المفضلة',
                            textAlign: TextAlign.center,
                            style: getRegularStyle(
                              size: 13,
                              color: AppColors.font01,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            ),
                            icon: const Icon(AppIcons.login),
                            label: Text(l.login),
                          ),
                        ],
                      ),
                    ),
                  )
                : favorites.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(28.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.heart,
                            size: 54.sp,
                            color: AppColors.secondaryNormal,
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'لا توجد سيارات مفضلة حالياً',
                            textAlign: TextAlign.center,
                            style: getSemiBoldStyle(
                              size: 16,
                              color: AppColors.black10,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'ابدأ بإضافة السيارات التي تعجبك للوصول إليها بسرعة لاحقاً',
                            textAlign: TextAlign.center,
                            style: getRegularStyle(
                              size: 13,
                              color: AppColors.font01,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (_, index) =>
                        CarCard(car: favorites[index], selectedFavorite: true),
                  ),
          ),
        ],
      ),
    );
  }
}
