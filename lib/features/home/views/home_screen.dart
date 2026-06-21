import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../cars/widgets/car_card.dart';
import '../../cars/views/search_screen.dart';
import '../../offices/widgets/office_card.dart';
import '../../home/providers/home_provider.dart';
import '../../notifications/views/notifications_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final homeProvider = context.watch<HomeProvider>();
    final session = context.watch<AuthProvider>().session;
    final cars = homeProvider.homeCars;
    final offices = homeProvider.nearbyOffices;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          final auth = context.read<AuthProvider>();
          await context.read<HomeProvider>().load(
            country: auth.session?.country ?? '',
            city: auth.session?.city ?? '',
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundImage: session?.office?.image.isNotEmpty == true
                        ? NetworkImage(session!.office!.image)
                        : const AssetImage(AssetsApp.avitar) as ImageProvider,
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.welcomeBack,
                          style: getRegularStyle(
                            size: 12,
                            color: AppColors.font01,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          session == null
                              ? l.guest
                              : session.displayName.isNotEmpty
                              ? session.displayName
                              : l.userDisplayName,
                          style: getSemiBoldStyle(
                            size: 16,
                            color: AppColors.primaryNormal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 21.r,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            AppIcons.notification,
                            color: AppColors.primaryNormal,
                            size: 20.sp,
                          ),
                        ),
                        PositionedDirectional(
                          top: -3.h,
                          end: -2.w,
                          child: CircleAvatar(
                            radius: 8.r,
                            backgroundColor: AppColors.error,
                            child: Text(
                              '4',
                              style: getBoldStyle(size: 9, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      child: AbsorbPointer(
                        child: SizedBox(
                          height: 48.h,
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: l.searchHint,
                              hintStyle: getRegularStyle(
                                size: 12,
                                color: AppColors.hint,
                              ),
                              prefixIcon: Icon(
                                AppIcons.search,
                                size: 20.sp,
                                color: AppColors.hint,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(
                                  color: AppColors.border01,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryNormal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    borderRadius: BorderRadius.circular(9.r),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNormal,
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: AppColors.white,
                        size: 23.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 17.h),
              _sectionHeader(
                l.nearbyCars,
                l.showAll,
                onTap: () => onNavigate?.call(1),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 270.h,
                child: homeProvider.loading && cars.isEmpty
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, __) => const CardSkeleton(compact: true),
                      )
                    : cars.isEmpty
                    ? DataStateView(
                        title: l.noResults,
                        subtitle: l.noResultsSubtitle,
                        actionText: l.tryNow,
                        onRetry: () {
                          final auth = context.read<AuthProvider>();
                          context.read<HomeProvider>().load(
                            country: auth.session?.country ?? '',
                            city: auth.session?.city ?? '',
                          );
                        },
                        compact: true,
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cars.length > 5 ? 5 : cars.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, index) =>
                            CarCard(car: cars[index], compact: true),
                      ),
              ),
              SizedBox(height: 22.h),
              _sectionHeader(
                l.nearbyOffices,
                l.showAll,
                onTap: () => onNavigate?.call(2),
              ),
              SizedBox(height: 12.h),
              if (homeProvider.loading && offices.isEmpty)
                Column(
                  children: [
                    const OfficeSkeleton(),
                    SizedBox(height: 14.h),
                    const OfficeSkeleton(),
                  ],
                )
              else if (offices.isEmpty)
                DataStateView(
                  title: l.noResults,
                  subtitle: l.noResultsSubtitle,
                  actionText: l.tryNow,
                  onRetry: () {
                    final auth = context.read<AuthProvider>();
                    context.read<HomeProvider>().load(
                      country: auth.session?.country ?? '',
                      city: auth.session?.city ?? '',
                    );
                  },
                  compact: true,
                )
              else
                ...offices
                    .take(2)
                    .map(
                      (office) => Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: OfficeCard(office: office),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action, {VoidCallback? onTap}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: getSemiBoldStyle(size: 16, color: AppColors.black10),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: getMediumStyle(
              size: 12,
              color: AppColors.primaryNormal,
            ).copyWith(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
