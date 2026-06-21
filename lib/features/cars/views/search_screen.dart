import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/location_filter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/cars_provider.dart';
import '../widgets/car_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<CarsProvider>();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: l.searchAndFilter),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 18.h),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            provider.clearFilters();
                          } else {
                            provider.applyFilters(search: value);
                          }
                        },
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
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
                  SizedBox(width: 12.w),
                  InkWell(
                    onTap: () => _filter(provider),
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
            ),
            Expanded(
              child: provider.loading
                  ? ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      itemCount: 3,
                      separatorBuilder: (_, __) => SizedBox(height: 20.h),
                      itemBuilder: (_, __) => const CardSkeleton(),
                    )
                  : provider.cars.isEmpty
                  ? DataStateView(
                      title: l.noResults,
                      subtitle: l.noResultsSubtitle,
                      actionText: l.tryNow,
                      onRetry: provider.load,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      itemCount: provider.cars.length,
                      separatorBuilder: (_, __) => SizedBox(height: 20.h),
                      itemBuilder: (_, index) =>
                          CarCard(car: provider.cars[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _filter(CarsProvider provider) async {
    final value = await showLocationFilter(
      context: context,
      country: provider.country,
      city: provider.city,
    );
    if (value != null) {
      provider.applyFilters(country: value.country, city: value.city);
    }
  }
}
