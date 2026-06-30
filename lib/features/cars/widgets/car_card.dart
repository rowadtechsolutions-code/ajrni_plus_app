import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/helpers/nav_helper.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/services/whatsapp_booking_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../models/car_model.dart';
import '../views/car_details_screen.dart';

class CarCard extends StatelessWidget with NavHelper {
  final CarModel car;
  final bool compact;
  final bool selectedFavorite;

  const CarCard({
    super.key,
    required this.car,
    this.compact = false,
    this.selectedFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite =
        selectedFavorite || car.isFavorite || favorites.contains(car.id);
    return GestureDetector(
      onTap: () => jump(context, CarDetailsScreen(car: car), false),
      child: Container(
        width: compact ? 260.w : double.infinity,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: AppColors.border01),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9.r),
                  child: SizedBox(
                    width: double.infinity,
                    height: compact ? 136.h : 142.h,
                    child: _carImage(),
                  ),
                ),
                Positioned(top: 9.h, right: 9.w, child: _badge(car.status, l)),
                Positioned(
                  top: 9.h,
                  left: 9.w,
                  child: GestureDetector(
                    onTap: car.id.isEmpty
                        ? null
                        : () => _toggleFavorite(context),
                    child: CircleAvatar(
                      radius: 16.r,
                      backgroundColor: AppColors.surfaceBlue,
                      child: Icon(
                        isFavorite ? AppIcons.heartBold : AppIcons.heart,
                        size: 18.sp,
                        color: AppColors.primaryNormal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 9.h),
            Text(
              car.name.isNotEmpty
                  ? car.name
                  : [car.brand, car.model, car.year]
                        .where((value) => value?.toString().isNotEmpty == true)
                        .join(' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getMediumStyle(size: 15, color: AppColors.black10),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(AppIcons.location, size: 15.sp, color: AppColors.hint),
                SizedBox(width: 4.w),
                Text(
                  _location(l),
                  style: getRegularStyle(size: 11, color: AppColors.font01),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  _price(l),
                  style: getSemiBoldStyle(
                    size: 16,
                    color: AppColors.primaryNormal,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '/ ${l.perDay}',
                  style: getRegularStyle(size: 12, color: AppColors.font01),
                ),
                const Spacer(),
                SizedBox(
                  width: compact ? 120.w : 128.w,
                  child: MyButton(
                    heightButton: 44,
                    textSize: 13,
                    borderRadius: 9,
                    textButton: l.bookNow,
                    icon: AppIcons.car,
                    onTap: () => _book(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _book(BuildContext context) async {
    final phone = context.read<AuthProvider>().session?.user?.phoneNumber ?? '';
    try {
      await WhatsAppBookingService.book(car: car, customerPhone: phone);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    if (!context.read<AuthProvider>().isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginToContinue),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    try {
      await context.read<FavoritesProvider>().toggle(car.id);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _location(AppLocalizations l) {
    final office = car.office;
    if (office == null) return l.locationValue;
    return [
      office.city,
      office.country,
    ].where((value) => value.trim().isNotEmpty).join(' - ');
  }

  String _price(AppLocalizations l) {
    if (car.dailyPrice == null) return l.dailyPrice;
    return '${car.dailyPrice} ${car.currency}';
  }

  Widget _carImage() {
    if (car.image.startsWith('http')) {
      return AppNetworkImage(
        url: car.image,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        memoryCacheWidth: 760,
        diskCacheWidth: 1200,
        fallback: Image.asset(AssetsApp.hyundaiAvante, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      car.image,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }

  Widget _badge(String status, AppLocalizations l) {
    final (String text, Color color) = switch (status) {
      'maintenance' => (l.maintenance, AppColors.error),
      'reserved' => (l.reserved, AppColors.warning),
      _ => (l.available, AppColors.success),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: getMediumStyle(size: 11, color: AppColors.white),
      ),
    );
  }
}
