import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/cars_provider.dart';
import '../widgets/car_card.dart';
import 'car_filters_screen.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<CarsProvider>();
    final cars = provider.cars;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.cars,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getMediumStyle(size: 15, color: AppColors.font02),
                  ),
                ),
                if (provider.hasActiveFilters) ...[
                  SizedBox(width: 12.w),
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 4.h,
                      ),
                      child: Text(
                        l.reset,
                        style: getMediumStyle(
                          size: 13,
                          color: AppColors.primaryNormal,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        provider.applyFilters(search: value);
                      },
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        hintStyle: getRegularStyle(
                          size: 13,
                          color: AppColors.hint,
                        ),
                        prefixIcon: Icon(
                          AppIcons.search,
                          size: 20.sp,
                          color: AppColors.hint,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: AppColors.border01,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: AppColors.border01,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
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
          SizedBox(height: 16.h),
          Expanded(
            child: provider.loading && cars.isEmpty
                ? RefreshIndicator(
                    onRefresh: provider.load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      itemCount: 3,
                      separatorBuilder: (_, __) => SizedBox(height: 20.h),
                      itemBuilder: (_, __) => const CardSkeleton(),
                    ),
                  )
                : cars.isEmpty
                ? RefreshIndicator(
                    onRefresh: provider.load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: DataStateView(
                        title: l.noResults,
                        subtitle: l.noResultsSubtitle,
                        actionText: l.tryNow,
                        onRetry: provider.load,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      itemCount: cars.length,
                      separatorBuilder: (_, __) => SizedBox(height: 20.h),
                      itemBuilder: (_, index) => CarCard(car: cars[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _filter(CarsProvider provider) async {
    final didChange = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CarFiltersScreen(provider: provider),
      ),
    );
    if (didChange == true && provider.search.isEmpty) {
      _searchController.clear();
    }
  }
}
