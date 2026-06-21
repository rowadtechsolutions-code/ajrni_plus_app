import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/cache/app_preferences.dart';
import '../../../core/services/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/selection_bottom_sheet.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../get_start/views/welcome_screen.dart';
import '../../profile/data/legal_content.dart';
import '../../profile/views/content_screen.dart';
import '../helpers/dealer_text.dart';
import 'dealer_edit_profile_screen.dart';

class DealerProfileScreen extends StatelessWidget {
  const DealerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    final office = context.watch<AuthProvider>().session?.office;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.profile,
              style: getSemiBoldStyle(size: 20, color: AppColors.navy),
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border01),
              ),
              child: Column(
                children: [
                  ClipOval(
                    child: SizedBox.square(
                      dimension: 84.r,
                      child: AppNetworkImage(
                        url: office?.image ?? '',
                        memoryCacheWidth: 252,
                        diskCacheWidth: 504,
                        fallback: Image.asset(
                          AssetsApp.logoApp,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    office?.officeName ?? '',
                    style: getSemiBoldStyle(size: 18, color: AppColors.black10),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    office?.email ?? '',
                    style: getRegularStyle(size: 12, color: AppColors.font01),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    [
                      office?.city ?? '',
                      office?.country ?? '',
                    ].where((value) => value.isNotEmpty).join(' - '),
                    style: getRegularStyle(size: 11, color: AppColors.font01),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            _row(
              context,
              AppIcons.edit,
              t.officeProfile,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DealerEditProfileScreen(),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              context,
              AppIcons.globe,
              AppLocalizations.of(context)!.language,
              () => _chooseLanguage(context),
              trailing: context.watch<LanguageProvider>().language == 'ar'
                  ? AppLocalizations.of(context)!.arabic
                  : 'English',
            ),
            SizedBox(height: 12.h),
            _row(
              context,
              AppIcons.info,
              AppLocalizations.of(context)!.aboutAjrni,
              () => _openContent(
                context,
                AppLocalizations.of(context)!.aboutAjrni,
                LegalContent.about(context.read<LanguageProvider>().language),
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              context,
              AppIcons.shield,
              AppLocalizations.of(context)!.privacyPolicy,
              () => _openContent(
                context,
                AppLocalizations.of(context)!.privacyPolicy,
                LegalContent.privacy(context.read<LanguageProvider>().language),
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              context,
              AppIcons.document,
              AppLocalizations.of(context)!.termsAndConditions,
              () => _openContent(
                context,
                AppLocalizations.of(context)!.termsAndConditions,
                LegalContent.terms(context.read<LanguageProvider>().language),
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              context,
              AppIcons.logout,
              t.logout,
              () => _logout(context),
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool destructive = false,
    String? trailing,
  }) {
    final color = destructive ? AppColors.error : AppColors.font02;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11.r),
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: AppColors.border01),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(label, style: getMediumStyle(size: 14, color: color)),
            ),
            if (trailing != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  trailing,
                  style: getRegularStyle(size: 10, color: AppColors.font01),
                ),
              ),
            if (!destructive)
              Icon(AppIcons.chevronLeft, color: AppColors.hint, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final provider = context.read<LanguageProvider>();
    final value = await showSelectionBottomSheet<String>(
      context: context,
      title: l.selectLanguage,
      selectedValue: provider.language,
      items: [
        SelectionItem(value: 'ar', label: l.arabic),
        const SelectionItem(value: 'en', label: 'English'),
      ],
    );
    if (value != null) await provider.setLanguage(value);
  }

  void _openContent(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentScreen(title: title, content: content),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context: context,
      title: l.confirmLogoutTitle,
      message: l.confirmLogoutMessage,
      confirmText: l.confirm,
      cancelText: l.cancel,
    );
    if (!confirmed || !context.mounted) return;
    await AuthService().signOut();
    await AppPreferences().removeSession();
    if (!context.mounted) return;
    context.read<AuthProvider>().clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }
}
