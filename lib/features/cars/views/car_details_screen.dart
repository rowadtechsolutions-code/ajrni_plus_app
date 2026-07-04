import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/services/whatsapp_booking_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../offices/views/office_details_screen.dart';
import 'package:provider/provider.dart';
import '../models/car_model.dart';

class CarDetailsScreen extends StatelessWidget {
  final CarModel car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = car.isFavorite || favorites.contains(car.id);
    final gallery = <String>{
      car.image,
      ...car.images,
    }.where((path) => path.isNotEmpty).toList();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(
                      title: l.carDetails,
                      showDivider: false,
                      horizontalPadding: 0,
                    ),
                    SizedBox(height: 12.h),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _openGallery(context, gallery, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9.r),
                            child: SizedBox(
                              height: 200.h,
                              width: double.infinity,
                              child: _carImage(car.image),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10.h,
                          left: 10.w,
                          child: GestureDetector(
                            onTap: () => _toggleFavorite(context),
                            child: CircleAvatar(
                              radius: 17.r,
                              backgroundColor: AppColors.primaryNormal,
                              child: Icon(
                                isFavorite
                                    ? AppIcons.heartBold
                                    : AppIcons.heart,
                                color: AppColors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50.h,
                          left: 10.w,
                          child: GestureDetector(
                            onTap: () => _share(),
                            child: CircleAvatar(
                              radius: 17.r,
                              backgroundColor: AppColors.white,
                              child: Icon(
                                AppIcons.share,
                                color: AppColors.primaryNormal,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (gallery.length > 1)
                      SizedBox(
                        height: 58.h,
                        child: Row(
                          children: List.generate(
                            gallery.length > 3 ? 3 : gallery.length,
                            (index) => Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  end: index == 2 ? 0 : 8.w,
                                ),
                                child: GestureDetector(
                                  onTap: () =>
                                      _openGallery(context, gallery, index),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6.r),
                                    child: _carImage(gallery[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _carName(l),
                                style: getMediumStyle(
                                  size: 14,
                                  color: AppColors.black10,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    AppIcons.location,
                                    size: 14.sp,
                                    color: AppColors.hint,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _location(l),
                                    style: getRegularStyle(
                                      size: 11,
                                      color: AppColors.font01,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Text(
                                    _price(l),
                                    style: getSemiBoldStyle(
                                      size: 15,
                                      color: AppColors.primaryNormal,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    car.rentalType.startsWith('month') ||
                                            car.rentalType.contains('شهري') ||
                                            car.rentalType.contains('month')
                                        ? '/ ${l.perMonth}'
                                        : '/ ${l.perDay}',
                                    style: getRegularStyle(
                                      size: 11,
                                      color: AppColors.font01,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _statusBadge(l),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.border01.withValues(alpha: .8),
                        ),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.specifications,
                            style: getMediumStyle(
                              size: 12,
                              color: AppColors.font01,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8.h,
                            crossAxisSpacing: 8.w,
                            childAspectRatio: 2.35,
                            children: [
                              _Spec(
                                AppIcons.calendar,
                                l.year,
                                car.year?.toString() ?? '-',
                              ),
                              _Spec(
                                AppIcons.car,
                                l.model,
                                car.model.isEmpty ? '-' : car.model,
                              ),
                              _Spec(
                                AppIcons.fuel,
                                l.fuel,
                                car.fuel.isEmpty ? '-' : car.fuel,
                              ),
                              _Spec(
                                AppIcons.transmission,
                                l.transmission,
                                car.transmission.isEmpty
                                    ? '-'
                                    : car.transmission,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      l.offices,
                      style: getRegularStyle(size: 11, color: AppColors.font01),
                    ),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: car.office == null
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OfficeDetailsScreen(office: car.office),
                              ),
                            ),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border01),
                          borderRadius: BorderRadius.circular(9.r),
                        ),
                        child: Row(
                          children: [
                            ClipOval(
                              child: SizedBox.square(
                                dimension: 40.r,
                                child: AppNetworkImage(
                                  url: car.office?.image ?? '',
                                  memoryCacheWidth: 120,
                                  diskCacheWidth: 240,
                                  fallback: ColoredBox(
                                    color: AppColors.primaryLight,
                                    child: Icon(
                                      AppIcons.officeBold,
                                      color: AppColors.primaryNormal,
                                      size: 21.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 9.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    car.office?.officeName.isNotEmpty == true
                                        ? car.office!.officeName
                                        : l.officeName,
                                    style: getMediumStyle(
                                      size: 13,
                                      color: AppColors.black10,
                                    ),
                                  ),
                                  Text(
                                    _location(l),
                                    style: getRegularStyle(
                                      size: 10,
                                      color: AppColors.font01,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: MyButton(
                textButton: l.bookNow,
                icon: AppIcons.car,
                heightButton: 48,
                textSize: 14,
                borderRadius: 9,
                onTap: () => _book(context),
              ),
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

  Future<void> _share() async {
    final office = car.office;
    final location = [
      office?.city ?? '',
      office?.country ?? '',
    ].where((value) => value.isNotEmpty).join(' - ');
    await Share.share(
      [
        _carName(null),
        if (car.dailyPrice != null) '${car.dailyPrice} ${car.currency}',
        if (office?.officeName.isNotEmpty == true) office!.officeName,
        if (location.isNotEmpty) location,
        'https://www.ajrniplus.com/cars/${car.id}',
      ].join('\n'),
    );
  }

  String _carName(AppLocalizations? l) {
    if (car.name.isNotEmpty) return car.name;
    final value = [
      car.brand,
      car.model,
      car.year,
    ].where((item) => item?.toString().isNotEmpty == true).join(' ');
    return value.isNotEmpty ? value : (l?.carName ?? '');
  }

  String _location(AppLocalizations l) {
    final office = car.office;
    if (office == null) return l.locationValue;
    final value = [
      office.city,
      office.country,
    ].where((item) => item.isNotEmpty).join(' - ');
    return value.isEmpty ? l.locationValue : value;
  }

  String _price(AppLocalizations l) {
    return car.dailyPrice == null
        ? l.dailyPrice
        : '${car.dailyPrice} ${car.currency}';
  }

  void _openGallery(
    BuildContext context,
    List<String> gallery,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _FullScreenGallery(images: gallery, initialIndex: initialIndex),
      ),
    );
  }

  Widget _carImage(String path) {
    if (path.startsWith('http')) {
      return AppNetworkImage(
        url: path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        memoryCacheWidth: 1080,
        diskCacheWidth: 1600,
        fallback: Image.asset(AssetsApp.hyundaiAvante, fit: BoxFit.cover),
      );
    }
    return Image.asset(
      path.isEmpty ? AssetsApp.hyundaiAvante : path,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
  }

  Widget _statusBadge(AppLocalizations l) {
    final (String text, Color color) = switch (car.status) {
      'maintenance' => (l.maintenance, AppColors.error),
      'rented' => (l.rented, AppColors.warning),
      'reserved' => (l.reserved, AppColors.warning),
      _ => (l.available, AppColors.success),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Text(
        text,
        style: getMediumStyle(size: 10, color: AppColors.white),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _Spec(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.font01),
          SizedBox(height: 2.h),
          Text(
            title,
            style: getRegularStyle(size: 11, color: AppColors.font01),
          ),
          Text(
            value,
            style: getMediumStyle(size: 12, color: AppColors.primaryNormal),
          ),
        ],
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onVerticalDragEnd: (_) => Navigator.pop(context),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (_, i) => InteractiveViewer(
            maxScale: 4,
            child: Center(child: _buildImage(widget.images[i])),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return AppNetworkImage(
        url: path,
        fit: BoxFit.contain,
        fallback: Image.asset(AssetsApp.hyundaiAvante, fit: BoxFit.contain),
      );
    }
    return Image.asset(
      path.isEmpty ? AssetsApp.hyundaiAvante : path,
      fit: BoxFit.contain,
    );
  }
}
