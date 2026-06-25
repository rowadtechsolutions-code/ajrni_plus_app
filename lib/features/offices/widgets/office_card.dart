import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/helpers/nav_helper.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/services/contact_launcher_service.dart';
import '../views/office_details_screen.dart';
import '../models/office_model.dart';

class OfficeCard extends StatelessWidget with NavHelper {
  final OfficeModel? office;

  const OfficeCard({super.key, this.office});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => jump(context, OfficeDetailsScreen(office: office), false),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: AppColors.border01),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _officeAvatar(),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            AppIcons.verified,
                            size: 17.sp,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              office?.officeName ?? l.officeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getSemiBoldStyle(
                                size: 15,
                                color: AppColors.black10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        office?.bio.isNotEmpty == true
                            ? office!.bio
                            : l.officeDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getRegularStyle(
                          size: 11,
                          color: AppColors.font01,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.location,
                        size: 13.sp,
                        color: AppColors.primaryNormal,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        office == null
                            ? l.locationValue
                            : '${office!.city} - ${office!.country}',
                        style: getMediumStyle(
                          size: 10,
                          color: AppColors.primaryNormal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: MyButton(
                    heightButton: 42,
                    textButton: l.whatsapp,
                    textSize: 13,
                    borderRadius: 9,
                    icon: AppIcons.whatsapp,
                    bGColor: AppColors.success.withValues(alpha: .10),
                    textColor: AppColors.success,
                    onTap: () => _contact(context, whatsapp: true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: MyButton(
                    heightButton: 42,
                    textButton: l.call,
                    textSize: 13,
                    borderRadius: 9,
                    icon: AppIcons.call,
                    isSecondary: true,
                    onTap: () => _contact(context, whatsapp: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _officeAvatar() {
    final image = office?.image.trim() ?? '';
    return ClipOval(
      child: SizedBox.square(
        dimension: 48.r,
        child: AppNetworkImage(
          url: image,
          memoryCacheWidth: 144,
          diskCacheWidth: 288,
          fallback: ColoredBox(
            color: AppColors.surfaceBlue,
            child: Icon(
              AppIcons.officeBold,
              color: AppColors.primaryNormal,
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _contact(BuildContext context, {required bool whatsapp}) async {
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
