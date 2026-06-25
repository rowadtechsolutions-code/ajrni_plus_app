import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/data_state_view.dart';
import '../../../core/widgets/location_filter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/offices_provider.dart';
import '../widgets/office_card.dart';

class OfficesScreen extends StatefulWidget {
  const OfficesScreen({super.key});

  @override
  State<OfficesScreen> createState() => _OfficesScreenState();
}

class _OfficesScreenState extends State<OfficesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<OfficesProvider>();
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 14.h),
            child: Text(
              l.offices,
              style: getMediumStyle(size: 15, color: AppColors.font02),
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
                      onChanged: (value) =>
                          provider.applyFilters(search: value),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
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
            child: provider.loading && provider.offices.isEmpty
                ? RefreshIndicator(
                    onRefresh: provider.load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: 3,
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (_, __) => const OfficeSkeleton(),
                    ),
                  )
                : provider.offices.isEmpty
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
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: provider.offices.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (_, index) =>
                          OfficeCard(office: provider.offices[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _filter(OfficesProvider provider) async {
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
