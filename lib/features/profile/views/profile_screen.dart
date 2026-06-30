import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:arini_plus_app/services/fcm_token_service.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/enums/enums.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/cache/app_preferences.dart';
import '../../../core/services/contact_launcher_service.dart';
import '../../../core/services/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/selection_bottom_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/views/login_screen.dart';
import '../../get_start/views/welcome_screen.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../notifications/views/notifications_screen.dart';
import '../data/legal_content.dart';
import 'content_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final session = context.watch<AuthProvider>().session;
    final isGuest = session == null;
    final language = context.watch<LanguageProvider>().language;
    final unread = context.watch<NotificationsProvider>().unreadCount;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<AuthProvider>().refreshCurrentSession();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 24.h),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.myAccount,
              style: getMediumStyle(size: 15, color: AppColors.font02),
            ),
            SizedBox(height: 26.h),
            Text(
              l.account,
              style: getRegularStyle(size: 12, color: AppColors.hint),
            ),
            SizedBox(height: 10.h),
            _row(
              AppIcons.profile,
              isGuest ? l.loginToContinue : l.personalData,
              onTap: () => isGuest
                  ? _open(context, const LoginScreen())
                  : _open(context, const EditProfileScreen()),
            ),
            SizedBox(height: 14.h),
            Text(
              l.language,
              style: getRegularStyle(size: 12, color: AppColors.hint),
            ),
            SizedBox(height: 10.h),
            _row(
              AppIcons.globe,
              l.language,
              trailing: language == 'ar' ? l.arabic : 'English',
              onTap: () => _chooseLanguage(context),
            ),
            SizedBox(height: 22.h),
            Text(
              l.aboutAjrni,
              style: getRegularStyle(size: 12, color: AppColors.hint),
            ),
            SizedBox(height: 10.h),
            _row(
              AppIcons.info,
              l.aboutAjrni,
              onTap: () => _openContent(
                context,
                l.aboutAjrni,
                LegalContent.about(language),
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              AppIcons.shield,
              l.privacyPolicy,
              onTap: () => _openContent(
                context,
                l.privacyPolicy,
                LegalContent.privacy(language),
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              AppIcons.document,
              l.termsAndConditions,
              onTap: () => _openContent(
                context,
                l.termsAndConditions,
                LegalContent.terms(language),
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              AppIcons.whatsapp,
              l.contactUs,
              onTap: () => ContactLauncherService.whatsapp(
                phone: '+968 76791559',
                country: 'OM',
              ),
            ),
            SizedBox(height: 12.h),
            _row(
              AppIcons.notification,
              l.notifications,
              trailing: unread > 0 ? (unread > 99 ? '99+' : '$unread') : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ).then((_) {
                  context.read<NotificationsProvider>().loadUnreadCount();
                });
              },
            ),
            if (!isGuest) ...[
              SizedBox(height: 22.h),
              Text(
                l.accountSettings,
                style: getRegularStyle(size: 12, color: AppColors.hint),
              ),
              SizedBox(height: 10.h),
              _row(
                AppIcons.logout,
                l.logout,
                destructive: true,
                onTap: () => _logout(context),
              ),
              SizedBox(height: 12.h),
              _row(
                AppIcons.delete,
                l.deleteAccount,
                destructive: true,
                onTap: () => _deleteAccount(context),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _row(
    IconData icon,
    String text, {
    String? trailing,
    bool destructive = false,
    VoidCallback? onTap,
  }) {
    final color = destructive ? AppColors.error : AppColors.font02;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9.r),
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: AppColors.border01.withValues(alpha: .7)),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: destructive
                    ? AppColors.error.withValues(alpha: .08)
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 19.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getMediumStyle(size: 14, color: color),
              ),
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
              Icon(AppIcons.chevronLeft, size: 18.sp, color: AppColors.hint),
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
    await FcmTokenService().deactivateCurrentToken();
    await AuthService().signOut();
    if (!context.mounted) return;
    context.read<AuthProvider>().clear();
    _toWelcome(context);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmationDialog(
      context: context,
      title: l.confirmDeleteTitle,
      message: l.confirmDeleteMessage,
      confirmText: l.confirm,
      cancelText: l.cancel,
    );
    if (!confirmed || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const CircularProgressIndicator(color: AppColors.primaryNormal),
          ),
        ),
      ),
    );

    try {
      await AuthService().deleteCurrentAccount();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      await FcmTokenService().deactivateCurrentToken();
      if (!context.mounted) return;
      await AuthService().signOut();
      if (!context.mounted) return;
      context.read<AuthProvider>().clear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.accountDeleted),
          backgroundColor: AppColors.primaryNormal,
        ),
      );
      _toWelcome(context);
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _toWelcome(BuildContext context) {
    AppPreferences().setter(CacheKeys.guestMode, false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _openContent(BuildContext context, String title, String content) {
    _open(context, ContentScreen(title: title, content: content));
  }
}
