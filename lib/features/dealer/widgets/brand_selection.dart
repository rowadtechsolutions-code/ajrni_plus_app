import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/car_brands_data.dart';

class BrandSelectionField extends StatelessWidget {
  final String label;
  final CarBrand? brand;
  final VoidCallback onTap;

  const BrandSelectionField({
    super.key,
    required this.label,
    required this.brand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: getMediumStyle(size: 14)),
        SizedBox(height: 12.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 54.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border01),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                if (brand != null) ...[
                  BrandLogo(brand: brand!, size: 30),
                  SizedBox(width: 10.w),
                ] else
                  Icon(AppIcons.car, size: 20.sp, color: AppColors.hint),
                if (brand == null) SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    brand?.name ?? label,
                    style: getMediumStyle(
                      size: 13,
                      color: brand == null ? AppColors.hint : AppColors.font02,
                    ),
                  ),
                ),
                Icon(AppIcons.chevronDown, size: 17.sp, color: AppColors.hint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BrandLogo extends StatelessWidget {
  final CarBrand brand;
  final double size;

  const BrandLogo({super.key, required this.brand, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size.r,
      child: brand.logoUrl.contains('google.com/s2/favicons')
          ? CachedNetworkImage(
              imageUrl: brand.logoUrl,
              fit: BoxFit.contain,
              fadeInDuration: Duration.zero,
              placeholder: (_, __) => _fallback(),
              errorWidget: (_, __, ___) => _fallback(),
            )
          : SvgPicture.network(
              brand.logoUrl,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => _fallback(),
              errorBuilder: (_, __, ___) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Text(
        brand.name.characters.first,
        style: getSemiBoldStyle(size: 12, color: AppColors.primaryNormal),
      ),
    );
  }
}

Future<CarBrand?> showBrandSelection({
  required BuildContext context,
  required String title,
  CarBrand? selected,
}) {
  return showModalBottomSheet<CarBrand>(
    context: context,
    isScrollControlled: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 160),
      reverseDuration: Duration(milliseconds: 110),
    ),
    backgroundColor: Colors.transparent,
    builder: (_) => _BrandSheet(title: title, selected: selected),
  );
}

class _BrandSheet extends StatefulWidget {
  final String title;
  final CarBrand? selected;

  const _BrandSheet({required this.title, this.selected});

  @override
  State<_BrandSheet> createState() => _BrandSheetState();
}

class _BrandSheetState extends State<_BrandSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final brands = CarBrandsData.brands
        .where(
          (brand) => brand.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final availableHeight = mediaQuery.size.height - keyboardHeight;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        top: false,
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: availableHeight * .78),
            child: Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 48.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border01,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      widget.title,
                      style: getSemiBoldStyle(
                        size: 17,
                        color: AppColors.black10,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _query = value.trim()),
                    decoration: InputDecoration(
                      hintText: MaterialLocalizations.of(
                        context,
                      ).searchFieldLabel,
                      prefixIcon: Icon(
                        AppIcons.search,
                        color: AppColors.hint,
                        size: 20.sp,
                      ),
                      isDense: true,
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
                Expanded(
                  child: GridView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: brands.length,
                    itemBuilder: (_, index) {
                      final brand = brands[index];
                      final selected = widget.selected?.name == brand.name;
                      return InkWell(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(context, brand);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryLight
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryNormal
                                  : AppColors.border01,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BrandLogo(brand: brand, size: 38),
                              SizedBox(height: 8.h),
                              Text(
                                brand.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: getMediumStyle(
                                  size: 11,
                                  color: selected
                                      ? AppColors.primaryNormal
                                      : AppColors.font02,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
