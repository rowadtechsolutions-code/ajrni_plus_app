import 'package:arini_plus_app/core/constants/app_icons.dart';
import 'package:arini_plus_app/services/fcm_token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/helpers/nav_helper.dart';
import '../../../core/helpers/form_validators.dart';
import '../../../core/enums/enums.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_circular_progress_indicator.dart';
import '../../../core/widgets/custom_height_spacer.dart';
import '../../../core/widgets/custom_width_spacer.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/my_lable_text_fild.dart';
import '../widgets/auth_heder_section.dart';
import '../widgets/bg_image_widget.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../../dealer/views/dealer_dashboard_screen.dart';
import '../helpers/auth_error_mapper.dart';
import '../../home/views/main_home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with NavHelper {
  late TextEditingController _emailController;

  late TextEditingController _passwordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BgImageWidget(),
          AuthHeaderSection(
            title: localizations.logInToYourAccount,
            subtitle: localizations.supTitleLogin,
            logoAsset: AssetsApp.logoWhite,
          ),
          loginContent(localizations),
        ],
      ),
    );
  }

  Widget loginContent(AppLocalizations localizations) {
    return PositionedDirectional(
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
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            24.w,
            16.h,
            24.w,
            24.h + MediaQuery.paddingOf(context).bottom,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                MyTextField(
                  hintText: localizations.emailHint,
                  controller: _emailController,
                  label: localizations.email,
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
                CustomHeightSpacer(height: 18),
                MyTextField(
                  hintText: localizations.passwordHint,
                  controller: _passwordController,
                  label: localizations.password,
                  isRequired: true,
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: Icon(
                    AppIcons.lock,
                    size: 18.sp,
                    color: AppColors.hint,
                  ),
                  obscureText: true,
                  labelSize: 13,
                  hintSize: 12,
                  fieldHeight: 50,
                  borderRadius: 10,
                  labelSpacing: 10,
                  textSize: 14,
                  compact: true,
                ),
                CustomHeightSpacer(height: 18),
                GestureDetector(
                  onTap: () => jump(
                    context,
                    ForgotPasswordScreen(
                      initialEmail: _emailController.text.trim(),
                    ),
                    false,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      localizations.didYouForgetYourPassword,
                      textAlign: TextAlign.start,
                      style: getMediumStyle(size: 12, color: AppColors.font02)
                          .copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.font02,
                          ),
                    ),
                  ),
                ),
                CustomHeightSpacer(height: 20),
                _isLoading == true
                    ? CustomCircularProgressIndicator()
                    : MyButton(
                        textButton: localizations.login,
                        heightButton: 50,
                        textSize: 15,
                        borderRadius: 10,
                        onTap: () => _login(localizations),
                      ),
                CustomHeightSpacer(height: 27),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localizations.createNewAccountQues,
                      style: getRegularStyle(size: 12, color: AppColors.font01),
                    ),
                    CustomWidthSpacer(width: 6),
                    GestureDetector(
                      onTap: () => jump(context, const RegisterScreen(), false),
                      child: Text(
                        localizations.registerNow,
                        style: getSemiBoldStyle(
                          size: 13,
                          color: AppColors.primaryNormal,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(AppLocalizations l) async {
    FocusScope.of(context).unfocus();
    final emailError = FormValidators.email(
      _emailController.text,
      l.invalidEmail,
    );
    final password = _passwordController.text;
    if (emailError != null || password.isEmpty) {
      _showMessage(emailError ?? l.fieldRequired);
      return;
    }
    setState(() => _isLoading = true);
    final provider = context.read<AuthProvider>();
    provider.setLoading(true);
    try {
      final session = await AuthService().signIn(
        email: _emailController.text,
        password: password,
      );
      if (!mounted) return;
      provider.setSession(session);
      FcmTokenService().syncCurrentDeviceToken();
      final target = session.type == AccountType.office
          ? const DealerDashboardScreen()
          : const MainHomeScreen();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => target),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (mounted) {
        final message = AuthErrorMapper.message(error, l);
        provider.setError(message);
        _showMessage(message);
      }
    } catch (error) {
      if (mounted) {
        final message = AuthErrorMapper.message(error, l);
        provider.setError(message);
        _showMessage(message);
      }
    } finally {
      provider.finishLoading();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

}
