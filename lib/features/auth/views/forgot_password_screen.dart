import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/helpers/form_validators.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_height_spacer.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/my_lable_text_fild.dart';
import '../helpers/auth_error_mapper.dart';
import '../services/auth_service.dart';
import '../widgets/auth_heder_section.dart';
import '../widgets/bg_image_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BgImageWidget(),
          AuthHeaderSection(
            title: l.forgotPasswordTitle,
            subtitle: l.forgotPasswordDescription,
            logoAsset: AssetsApp.logoWhite,
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            top: 278.h,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
                color: AppColors.white,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  24.w,
                  16.h,
                  24.w,
                  24.h + MediaQuery.paddingOf(context).bottom,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      CustomHeightSpacer(height: 3),
                      Container(
                        width: 60.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.gray,
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      CustomHeightSpacer(height: 24),
                      Text(
                        l.forgotPasswordDescription,
                        textAlign: TextAlign.start,
                        style: getRegularStyle(
                          size: 13,
                          color: AppColors.font01,
                        ),
                      ),
                      CustomHeightSpacer(height: 24),
                      MyTextField(
                        hintText: l.resetEmailHint,
                        controller: _emailController,
                        label: l.email,
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          AppIcons.email,
                          size: 18.sp,
                          color: AppColors.hint,
                        ),
                        labelSize: 13,
                        hintSize: 12,
                        fieldHeight: 50,
                        borderRadius: 10,
                        labelSpacing: 10,
                        textSize: 14,
                        compact: true,
                      ),
                      CustomHeightSpacer(height: 24),
                      MyButton(
                        textButton: l.sendResetLink,
                        heightButton: 50,
                        textSize: 15,
                        borderRadius: 10,
                        isLoading: _isLoading,
                        onTap: () => _sendResetLink(l),
                      ),
                      CustomHeightSpacer(height: 14),
                      MyButton(
                        textButton: l.backToLogin,
                        heightButton: 50,
                        textSize: 14,
                        borderRadius: 10,
                        isSecondary: true,
                        onTap: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResetLink(AppLocalizations l) async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError(l.fieldRequired);
      return;
    }
    final validationError = FormValidators.email(email, l.invalidEmail);
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final sent = await AuthService().sendPasswordReset(email);
      if (!mounted) return;
      if (!sent) {
        _showError(l.emailNotRegistered);
        return;
      }
      await _showSuccessDialog(l);
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (error) {
      if (mounted) _showError(AuthErrorMapper.message(error, l));
    } catch (error) {
      if (mounted) _showError(AuthErrorMapper.message(error, l));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessDialog(AppLocalizations l) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Text(
          l.operationSuccessful,
          textAlign: TextAlign.center,
          style: getSemiBoldStyle(size: 18, color: AppColors.black10),
        ),
        content: Text(
          l.passwordResetSuccessMessage,
          textAlign: TextAlign.center,
          style: getRegularStyle(size: 13, color: AppColors.font01),
        ),
        actionsPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
        actions: [
          Row(
            children: [
              Expanded(
                child: MyButton(
                  textButton: l.understood,
                  heightButton: 44,
                  textSize: 13,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
