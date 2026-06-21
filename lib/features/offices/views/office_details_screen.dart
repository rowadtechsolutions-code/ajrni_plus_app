import 'package:arini_plus_app/core/widgets/custom_height_spacer.dart';
import 'package:arini_plus_app/core/widgets/custom_width_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/services/contact_launcher_service.dart';
import '../../cars/models/car_model.dart';
import '../../cars/services/car_service.dart';
import '../../cars/widgets/car_card.dart';
import '../models/office_model.dart';

class OfficeDetailsScreen extends StatefulWidget {
  final OfficeModel? office;

  const OfficeDetailsScreen({super.key, this.office});

  @override
  State<OfficeDetailsScreen> createState() => _OfficeDetailsScreenState();
}

class _OfficeDetailsScreenState extends State<OfficeDetailsScreen> {
  late Future<List<CarModel>> _carsFuture;

  OfficeModel? get office => widget.office;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  void _loadCars() {
    _carsFuture = office == null || office!.id.isEmpty
        ? Future.value(const [])
        : CarService().getCarsByOffice(office!.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                title: l.officeDetails,
                showDivider: false,
                horizontalPadding: 0,
              ),
              SizedBox(height: 12.h),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9.r),
                    child: SizedBox(
                      height: 150.h,
                      width: double.infinity,
                      child: _coverImage(),
                    ),
                  ),
                  Positioned(
                    right: 18.w,
                    bottom: -24.h,
                    child: CircleAvatar(
                      radius: 29.r,
                      backgroundColor: AppColors.white,
                      child: ClipOval(
                        child: SizedBox.square(
                          dimension: 48.r,
                          child: AppNetworkImage(
                            url: office?.image ?? '',
                            memoryCacheWidth: 160,
                            diskCacheWidth: 320,
                            fallback: ColoredBox(
                              color: AppColors.surfaceBlue,
                              child: Icon(
                                AppIcons.officeBold,
                                color: AppColors.primaryNormal,
                                size: 25.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              CustomHeightSpacer(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          office?.officeName ?? l.officeName,
                          textAlign: TextAlign.start,
                          style: getBoldStyle(
                            size: 16,
                            color: AppColors.black10,
                          ),
                        ),
                        Text(
                          office?.bio.isNotEmpty == true
                              ? office!.bio
                              : l.officeDescription,
                          textAlign: TextAlign.right,
                          style: getRegularStyle(
                            size: 12,
                            color: AppColors.font01,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              CustomHeightSpacer(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  office == null
                      ? l.locationValue
                      : '${office!.city} - ${office!.country}',
                  style: getMediumStyle(
                    size: 10,
                    color: AppColors.primaryNormal,
                  ),
                ),
              ),
              CustomHeightSpacer(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      textButton: l.whatsapp,
                      icon: AppIcons.whatsapp,
                      bGColor: AppColors.success.withValues(alpha: .14),
                      textColor: AppColors.success,
                      borderColor: AppColors.success,
                      heightButton: 42,
                      textSize: 13,
                      borderRadius: 9,
                      onTap: () => _contact(whatsapp: true),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: MyButton(
                      textButton: l.call,
                      icon: AppIcons.call,
                      isSecondary: true,
                      heightButton: 42,
                      textSize: 13,
                      borderRadius: 9,
                      onTap: () => _contact(whatsapp: false),
                    ),
                  ),
                ],
              ),
              Divider(color: AppColors.border01.withOpacity(.5), height: 32.h,),
              CustomHeightSpacer(height: 16),
              FutureBuilder<List<CarModel>>(
                future: _carsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        const CardSkeleton(),
                        SizedBox(height: 12.h),
                        const CardSkeleton(),
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    return DataStateView(
                      title: l.noResults,
                      subtitle: snapshot.error.toString(),
                      actionText: l.tryNow,
                      onRetry: () => setState(_loadCars),
                    );
                  }
                  final cars = snapshot.data ?? const <CarModel>[];
                  if (cars.isEmpty) {
                    return DataStateView(
                      title: l.officeHasNoCars,
                      subtitle: '',
                      actionText: l.tryNow,
                      onRetry: () => setState(_loadCars),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.officeCars} (${cars.length})',
                        style: getRegularStyle(
                          size: 12,
                          color: AppColors.font02,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ...cars.map(
                        (car) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: CarCard(car: car.copyWith(office: office)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverImage() {
    final cover = office?.cover ?? '';
    if (cover.startsWith('http')) {
      return AppNetworkImage(
        url: cover,
        fit: BoxFit.cover,
        memoryCacheWidth: 1000,
        diskCacheWidth: 1600,
        placeholder: const ShimmerLoading(
          child: ColoredBox(color: AppColors.gray),
        ),
        fallback: Image.asset(AssetsApp.officeCover, fit: BoxFit.cover),
      );
    }
    return Image.asset(AssetsApp.officeCover, fit: BoxFit.cover);
  }

  Future<void> _contact({required bool whatsapp}) async {
    if (office == null) return;
    try {
      if (whatsapp) {
        await ContactLauncherService.whatsapp(
          phone: office!.phoneNumber,
          country: office!.country,
        );
      } else {
        await ContactLauncherService.call(office!.phoneNumber);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
