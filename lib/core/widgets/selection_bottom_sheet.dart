import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SelectionItem<T> {
  final T value;
  final String label;

  const SelectionItem({required this.value, required this.label});
}

Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<SelectionItem<T>> items,
  T? selectedValue,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SelectionSheet<T>(
      title: title,
      items: items,
      selectedValue: selectedValue,
    ),
  );
}

class SelectionField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isRequired;

  const SelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isRequired ? '$label *' : label, style: getMediumStyle(size: 14)),
        SizedBox(height: 12.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border01),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(AppIcons.globe, size: 18.sp, color: AppColors.hint),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    hasValue ? value : label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRegularStyle(
                      size: 12,
                      color: hasValue ? AppColors.font02 : AppColors.hint,
                    ),
                  ),
                ),
                Icon(AppIcons.chevronDown, size: 16.sp, color: AppColors.hint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionSheet<T> extends StatefulWidget {
  final String title;
  final List<SelectionItem<T>> items;
  final T? selectedValue;

  const _SelectionSheet({
    required this.title,
    required this.items,
    this.selectedValue,
  });

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      return item.label.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .72,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    style: getSemiBoldStyle(size: 17, color: AppColors.black10),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: SizedBox(
                  height: 46.h,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value.trim()),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: MaterialLocalizations.of(
                        context,
                      ).searchFieldLabel,
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
                        borderSide: const BorderSide(color: AppColors.border01),
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
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1.h,
                    color: AppColors.border01.withValues(alpha: .6),
                  ),
                  itemBuilder: (_, index) {
                    final item = filteredItems[index];
                    final selected = item.value == widget.selectedValue;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      title: Text(
                        item.label,
                        style: getMediumStyle(
                          size: 14,
                          color: selected
                              ? AppColors.primaryNormal
                              : AppColors.font02,
                        ),
                      ),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.primaryNormal,
                              size: 21.sp,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, item.value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
