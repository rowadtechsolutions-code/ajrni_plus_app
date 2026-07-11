import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/helpers/form_validators.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/my_lable_text_fild.dart';
import '../../../core/widgets/selection_bottom_sheet.dart';
import '../../../data/country_city_data.dart';
import '../../auth/models/account_session.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/user_service.dart';
import '../../location/services/location_service.dart';
import '../../offices/services/office_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _gulfCodes = ['+968', '+966', '+971', '+965', '+974', '+973'];

  static const _codeToCountry = {
    '+968': 'OM',
    '+966': 'SA',
    '+971': 'AE',
    '+965': 'KW',
    '+974': 'QA',
    '+973': 'BH',
  };

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String? _country;
  String? _city;
  bool _loading = false;
  late String _phoneCode;

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthProvider>().session!;
    _nameController = TextEditingController(text: session.displayName);
    _emailController = TextEditingController(text: session.email);
    final existingPhone =
        session.user?.phoneNumber ?? session.office?.phoneNumber ?? '';
    _country = session.user?.country ?? session.office?.country;
    _city = session.user?.city ?? session.office?.city;
    _phoneCode = '+968';
    String localNumber = existingPhone;
    for (final code in _gulfCodes) {
      if (existingPhone.startsWith(code)) {
        _phoneCode = code;
        localNumber = existingPhone.substring(code.length);
        break;
      }
    }
    _phoneController = TextEditingController(text: localNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: l.personalData),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      MyTextField(
                        label: l.fullName,
                        hintText: l.fullName,
                        controller: _nameController,
                        isRequired: true,
                        validator: (value) =>
                            FormValidators.name(value ?? '', l.invalidName),
                      ),
                      SizedBox(height: 16.h),
                      MyTextField(
                        label: l.email,
                        hintText: l.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false,
                      ),
                      SizedBox(height: 16.h),
                      MyTextField(
                        label: l.phoneNumber,
                        hintText: 'XXXXXXXX',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired:
                            context.read<AuthProvider>().session?.user == null,
                        prefixIcon: _buildPhoneCodePrefix(context),
                        validator: (value) {
                          final phone = value?.trim() ?? '';
                          if (phone.isEmpty &&
                              context.read<AuthProvider>()
                                      .session
                                      ?.user !=
                                  null) {
                            return null;
                          }
                          final phoneCountry = _codeToCountry[_phoneCode] ?? '';
                          return FormValidators.gulfPhone(
                            '$_phoneCode$phone',
                            phoneCountry,
                            l.invalidPhone,
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: SelectionField(
                              label: l.country,
                              value: _countryLabel(context),
                              onTap: () => _chooseCountry(context),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: SelectionField(
                              label: l.city,
                              value: _city ?? '',
                              onTap: () => _chooseCity(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      MyButton(
                        textButton: l.saveChanges,
                        isLoading: _loading,
                        onTap: () => _save(l),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _countryLabel(BuildContext context) {
    if (_country == null) return '';
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return LocationService.countryName(_country!, ar);
  }

  Future<void> _chooseCountry(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final countries = await _loadCountries(context, l);
    if (countries == null) return;
    final value = await showSelectionBottomSheet<String>(
      context: context,
      title: l.chooseCountry,
      selectedValue: _country,
      items: countries
          .map((item) => SelectionItem(
                value: item.code,
                label: ar ? item.nameAr : item.nameEn,
              ))
          .toList(),
    );
    if (value != null && mounted) {
      setState(() {
        if (_country != value) _city = null;
        _country = value;
      });
    }
  }

  Future<void> _chooseCity(BuildContext context) async {
    if (_country == null) return;
    final l = AppLocalizations.of(context)!;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final cities = await _loadCities(context, l, _country!);
    if (cities == null) return;
    final value = await showSelectionBottomSheet<String>(
      context: context,
      title: l.chooseCity,
      selectedValue: _city,
      items: cities
          .map((city) => SelectionItem(
                value: city.nameAr,
                label: ar ? city.nameAr : city.nameEn,
              ))
          .toList(),
    );
    if (value != null && mounted) setState(() => _city = value);
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

  Future<void> _save(AppLocalizations l) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_country == null || _city == null) return;
    final provider = context.read<AuthProvider>();
    final session = provider.session!;
    setState(() => _loading = true);
    try {
      AccountSession updatedSession;
      if (session.user != null) {
        final user = session.user!.copyWith(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? ''
              : FormValidators.normalizePhone(
                  '$_phoneCode${_phoneController.text}',
                ),
          country: _country,
          city: _city,
        );
        await UserService().updateUser(user);
        updatedSession = AccountSession.user(user);
      } else {
        final office = session.office!.copyWith(
          officeName: _nameController.text.trim(),
          phoneNumber: FormValidators.normalizePhone(
            '$_phoneCode${_phoneController.text}',
          ),
          country: _country,
          city: _city,
        );
        await OfficeService().updateOffice(office);
        updatedSession = AccountSession.office(office);
      }
      provider.setSession(updatedSession);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.profileUpdated),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.unexpectedError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<Country>?> _loadCountries(
      BuildContext context, AppLocalizations l) async {
    try {
      return await LocationService.getCountries();
    } catch (e) {
      debugPrint('LocationService.getCountries error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.unexpectedError), backgroundColor: AppColors.error),
        );
      }
      return null;
    }
  }

  Future<List<City>?> _loadCities(
      BuildContext context, AppLocalizations l, String countryCode) async {
    try {
      return await LocationService.getCities(countryCode);
    } catch (e) {
      debugPrint('LocationService.getCities($countryCode) error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.unexpectedError), backgroundColor: AppColors.error),
        );
      }
      return null;
    }
  }
}
