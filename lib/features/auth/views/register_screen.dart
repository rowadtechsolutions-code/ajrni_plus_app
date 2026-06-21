import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/helpers/form_validators.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/enums/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_height_spacer.dart';
import '../../../core/widgets/custom_width_spacer.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/my_lable_text_fild.dart';
import '../../../core/widgets/selection_bottom_sheet.dart';
import '../../../data/country_city_data.dart';
import '../services/auth_service.dart';
import '../helpers/auth_error_mapper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _gulfCodes = ['+968', '+966', '+971', '+965', '+974', '+973'];

  static const _codeToCountry = {
    '+968': 'OM',
    '+966': 'SA',
    '+971': 'AE',
    '+965': 'KW',
    '+974': 'QA',
    '+973': 'BH',
  };

  final _nameController = TextEditingController();
  final _commercialController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isOffice = false;
  bool _isLoading = false;
  String? _country;
  String? _city;
  String _phoneCode = '+968';

  @override
  void dispose() {
    _nameController.dispose();
    _commercialController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(24.w, 20.h, 24.w, 28.h),
            child: Column(
              children: [
                Image.asset(AssetsApp.logoWelcome, width: 86.w),
                CustomHeightSpacer(height: 12),
                Text(
                  l.createNewAccount,
                  style: getSemiBoldStyle(size: 20, color: AppColors.black10),
                ),
                CustomHeightSpacer(height: 8),
                Text(
                  l.registerSubtitle,
                  textAlign: TextAlign.center,
                  style: getRegularStyle(size: 13, color: AppColors.font01),
                ),
                CustomHeightSpacer(height: 18),
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _typeButton(l.user, false, AppIcons.user),
                      ),
                      Expanded(
                        child: _typeButton(
                          l.officeOwner,
                          true,
                          AppIcons.office,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomHeightSpacer(height: 16),
                MyTextField(
                  label: _isOffice ? l.officeName : l.fullName,
                  isRequired: true,
                  hintText: _isOffice ? l.officeName : l.fullName,
                  controller: _nameController,
                  icon: _isOffice ? AppIcons.office : AppIcons.user,
                  validator: (value) =>
                      FormValidators.name(value ?? '', l.invalidName),
                ),
                if (_isOffice) ...[
                  CustomHeightSpacer(height: 14),
                  MyTextField(
                    label: l.commercialRegistration,
                    isRequired: true,
                    hintText: l.commercialRegistration,
                    controller: _commercialController,
                    icon: AppIcons.document,
                    validator: (value) {
                      final clean = value?.trim() ?? '';
                      return clean.length < 3
                          ? l.invalidCommercialRegistration
                          : null;
                    },
                  ),
                ],
                CustomHeightSpacer(height: 14),
                MyTextField(
                  label: l.email,
                  isRequired: true,
                  hintText: 'example@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  icon: AppIcons.email,
                  validator: (value) =>
                      FormValidators.email(value ?? '', l.invalidEmail),
                ),
                CustomHeightSpacer(height: 14),
                MyTextField(
                  label: l.phoneNumber,
                  isRequired: true,
                  hintText: 'XXXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: _buildPhoneCodePrefix(context),
                  validator: (value) {
                    final phoneCountry = _codeToCountry[_phoneCode] ?? '';
                    return FormValidators.gulfPhone(
                      '$_phoneCode${value ?? ''}',
                      phoneCountry,
                      l.invalidPhone,
                    );
                  },
                ),
                CustomHeightSpacer(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SelectionField(
                        label: l.country,
                        value: _countryLabel(context),
                        onTap: () => _chooseCountry(context),
                      ),
                    ),
                    CustomWidthSpacer(width: 12),
                    Expanded(
                      child: SelectionField(
                        label: l.city,
                        value: _city ?? '',
                        onTap: () => _chooseCity(context),
                      ),
                    ),
                  ],
                ),
                CustomHeightSpacer(height: 14),
                MyTextField(
                  label: l.password,
                  isRequired: true,
                  hintText: l.password,
                  controller: _passwordController,
                  obscureText: true,
                  icon: AppIcons.lock,
                  validator: (value) =>
                      FormValidators.password(value ?? '', l.weakPassword),
                ),
                CustomHeightSpacer(height: 14),
                MyTextField(
                  label: l.confirmPassword,
                  isRequired: true,
                  hintText: l.confirmPassword,
                  controller: _confirmController,
                  obscureText: true,
                  icon: AppIcons.lock,
                  validator: (value) => value == _passwordController.text
                      ? null
                      : l.passwordMismatch,
                ),
                CustomHeightSpacer(height: 20),
                MyButton(
                  textButton: l.createAccount,
                  isLoading: _isLoading,
                  onTap: () => _register(l),
                ),
                CustomHeightSpacer(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l.alreadyHaveAccount,
                      style: getRegularStyle(size: 13),
                    ),
                    CustomWidthSpacer(width: 5),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        l.login,
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

  Widget _typeButton(String text, bool value, IconData icon) {
    final selected = _isOffice == value;
    return GestureDetector(
      onTap: () => setState(() => _isOffice = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: selected ? AppColors.primaryNormal : AppColors.font01,
            ),
            CustomWidthSpacer(width: 6),
            Text(
              text,
              style: getMediumStyle(
                size: 13,
                color: selected ? AppColors.primaryNormal : AppColors.font01,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _countryLabel(BuildContext context) {
    if (_country == null) return '';
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return CountryCityData.countryList.firstWhere(
      (item) => item['key'] == _country,
    )[isArabic ? 'name_ar' : 'name_en']!;
  }

  Future<void> _chooseCountry(BuildContext context) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selected = await showSelectionBottomSheet<String>(
      context: context,
      title: AppLocalizations.of(context)!.chooseCountry,
      selectedValue: _country,
      items: CountryCityData.countryList
          .map(
            (item) => SelectionItem(
              value: item['key']!,
              label: item[isArabic ? 'name_ar' : 'name_en']!,
            ),
          )
          .toList(),
    );
    if (selected != null && mounted) {
      setState(() {
        if (_country != selected) _city = null;
        _country = selected;
      });
    }
  }

  Future<void> _chooseCity(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    if (_country == null) {
      _showMessage(l.chooseCountry, AppColors.error);
      return;
    }
    final selected = await showSelectionBottomSheet<String>(
      context: context,
      title: l.chooseCity,
      selectedValue: _city,
      items: CountryCityData.citiesFor(
        _country!,
      ).map((city) => SelectionItem(value: city, label: city)).toList(),
    );
    if (selected != null && mounted) setState(() => _city = selected);
  }

  Widget _buildPhoneCodePrefix(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCodePicker(context),
      child: Center(
        child: Text(
          _phoneCode,
          style: getMediumStyle(size: 12, color: AppColors.font01),
        ),
      ),
    );
  }

  Future<void> _showCodePicker(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final selected = await showSelectionBottomSheet<String>(
      context: context,
      title: l.chooseCountry,
      selectedValue: _phoneCode,
      items: _gulfCodes.map((code) {
        final countryKey = _codeToCountry[code]!;
        final countryName = isArabic
            ? CountryCityData.countryNameAr(countryKey)
            : CountryCityData.countryNameEn(countryKey);
        return SelectionItem(value: code, label: '$code  -  $countryName');
      }).toList(),
    );
    if (selected != null && mounted) {
      setState(() => _phoneCode = selected);
    }
  }

  Future<void> _register(AppLocalizations l) async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_country == null || _city == null) {
      _showMessage(l.selectCountryAndCity, AppColors.error);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await AuthService().register(
        RegistrationData(
          type: _isOffice ? AccountType.office : AccountType.user,
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: FormValidators.normalizePhone(
            '$_phoneCode${_phoneController.text}',
          ),
          country: _country!,
          city: _city!,
          password: _passwordController.text,
          commercialRegistrationNumber: _commercialController.text,
        ),
      );
      if (!mounted) return;
      if (result.needsEmailConfirmation) {
        _showMessage(l.confirmEmailMessage, AppColors.success);
        Navigator.pop(context);
        return;
      }
      _showMessage(l.accountCreated, AppColors.success);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on AuthException catch (error) {
      _showMessage(AuthErrorMapper.message(error, l), AppColors.error);
    } catch (error) {
      _showMessage(AuthErrorMapper.message(error, l), AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
