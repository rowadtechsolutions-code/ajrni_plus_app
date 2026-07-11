import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../cars/widgets/car_card.dart';
import '../../cars/views/search_screen.dart';
import '../../offices/widgets/office_card.dart';
import '../../offices/views/office_details_screen.dart';
import '../../offices/services/office_service.dart';
import '../../home/providers/home_provider.dart';
import '../../home/models/banner_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/app_network_image.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _guestInitialRefreshDone = false;

  Future<void> _refreshHomeData() async {
    await context.read<AuthProvider>().refreshCurrentSession();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await context.read<HomeProvider>().load(
      country: auth.session?.country ?? '',
      city: auth.session?.city ?? '',
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = context.read<AuthProvider>().session;
      if (session == null && !_guestInitialRefreshDone) {
        _guestInitialRefreshDone = true;
        _refreshHomeData();
      }
    });
  }

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
        onRefresh: _refreshHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: SizedBox.square(
                      dimension: 50.r,
                      child: AppNetworkImage(
                        url: session?.office?.image ?? '',
                        memoryCacheWidth: 160,
                        diskCacheWidth: 320,
                        fallback: Image.asset(
                          AssetsApp.logoAppV1,
                          fit: BoxFit.cover,
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
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: CircleAvatar(
                      radius: 21.r,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        AppIcons.search,
                        color: AppColors.primaryNormal,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
              if (homeProvider.banners.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _bannerSection(homeProvider.banners),
                SizedBox(height: 14.h),
              ],
              SizedBox(height: 17.h),
              _sectionHeader(
                l.nearbyCars,
                l.showAll,
                onTap: () => widget.onNavigate?.call(1),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 270.h,
                child: homeProvider.loading && cars.isEmpty
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, __) =>
                            const CardSkeleton(compact: true),
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
                        itemCount: cars.length > 8 ? 8 : cars.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (_, index) =>
                            CarCard(car: cars[index], compact: true),
                      ),
              ),
              SizedBox(height: 22.h),
              _sectionHeader(
                l.nearbyOffices,
                l.showAll,
                onTap: () => widget.onNavigate?.call(2),
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

  Widget _bannerSection(List<BannerModel> banners) {
    return _BannerCarousel(banners: banners);
  }
}

class _BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;

  const _BannerCarousel({required this.banners});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.banners.length < 2) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _startTimer();
            },
            itemBuilder: (_, index) => Padding(
              padding: EdgeInsetsDirectional.only(
                end: index < banners.length - 1 ? 10.w : 0,
              ),
              child: _BannerCard(banner: banners[index]),
            ),
          ),
        ),
        if (banners.length > 1) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final isActive = index == _currentPage;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: EdgeInsetsDirectional.only(end: 6.w),
                  width: isActive ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryNormal
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (banner.officeId != null && banner.officeId!.isNotEmpty) {
          final office = await OfficeService().getOfficeById(banner.officeId!);
          if (office != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfficeDetailsScreen(office: office),
              ),
            );
          }
        } else {
          final url = banner.linkUrl;
          if (url != null && url.isNotEmpty) {
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.r),
        child: SizedBox(
          width: double.infinity,
          height: 140.h,
          child: AppNetworkImage(
            url: banner.imageUrl,
            fit: BoxFit.cover,
            memoryCacheWidth: 1000,
            diskCacheWidth: 1600,
            fallback: Image.asset(AssetsApp.hyundaiAvante, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
