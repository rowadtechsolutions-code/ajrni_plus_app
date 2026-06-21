import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../../core/helpers/image_picker.dart';
import '../../../core/services/suabase/supabase_upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/my_lable_text_fild.dart';
import '../../../core/widgets/selection_bottom_sheet.dart';
import '../../../data/country_city_data.dart';
import '../../auth/models/account_session.dart';
import '../../auth/providers/auth_provider.dart';
import '../../offices/services/office_service.dart';
import '../helpers/dealer_text.dart';

class DealerEditProfileScreen extends StatefulWidget {
  const DealerEditProfileScreen({super.key});

  @override
  State<DealerEditProfileScreen> createState() =>
      _DealerEditProfileScreenState();
}

class _DealerEditProfileScreenState extends State<DealerEditProfileScreen>
    with ImagePikerHelper {
  final _upload = SupabaseUploadService();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _commercialRegistration;
  late final TextEditingController _bio;
  late String _country;
  late String _city;
  File? _logo;
  File? _cover;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final office = context.read<AuthProvider>().session!.office!;
    _name = TextEditingController(text: office.officeName);
    _email = TextEditingController(text: office.email);
    _phone = TextEditingController(text: office.phoneNumber);
    _commercialRegistration = TextEditingController(
      text: office.commercialRegistrationNumber,
    );
    _bio = TextEditingController(text: office.bio);
    _country = office.country;
    _city = office.city;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _commercialRegistration.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    final office = context.watch<AuthProvider>().session!.office!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: t.officeProfile),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pick(cover: true),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: SizedBox(
                              width: double.infinity,
                              height: 145.h,
                              child: _cover != null
                                  ? Image.file(_cover!, fit: BoxFit.cover)
                                  : office.cover.startsWith('http')
                                  ? Image.network(
                                      office.cover,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppColors.primaryLight,
                                      child: Icon(
                                        AppIcons.image,
                                        size: 34.sp,
                                        color: AppColors.primaryNormal,
                                      ),
                                    ),
                            ),
                          ),
                          PositionedDirectional(
                            bottom: 10.h,
                            end: 10.w,
                            child: _editBadge(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: () => _pick(cover: false),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 44.r,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: _logo != null
                                ? FileImage(_logo!)
                                : office.image.startsWith('http')
                                ? NetworkImage(office.image)
                                : null,
                            child:
                                _logo == null &&
                                    !office.image.startsWith('http')
                                ? Icon(
                                    AppIcons.officeBold,
                                    size: 28.sp,
                                    color: AppColors.primaryNormal,
                                  )
                                : null,
                          ),
                          PositionedDirectional(
                            bottom: -2.h,
                            end: -4.w,
                            child: _editBadge(size: 32),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    MyTextField(
                      label: t.ar ? 'اسم المكتب' : 'Office name',
                      hintText: t.officeProfile,
                      controller: _name,
                      isRequired: true,
                    ),
                    SizedBox(height: 16.h),
                    MyTextField(
                      label: t.ar ? 'البريد الإلكتروني' : 'Email',
                      hintText: 'office@example.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                    ),
                    SizedBox(height: 16.h),
                    MyTextField(
                      label: t.ar ? 'رقم الهاتف' : 'Phone number',
                      hintText: 'XXXXXXXX',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: SelectionField(
                            label: t.ar ? 'الدولة' : 'Country',
                            value: _countryLabel(t.ar),
                            onTap: () => _chooseCountry(t),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: SelectionField(
                            label: t.ar ? 'المدينة' : 'City',
                            value: _city,
                            onTap: () => _chooseCity(t),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    MyTextField(
                      label: t.ar
                          ? 'رقم السجل التجاري'
                          : 'Commercial registration number',
                      hintText: t.ar ? 'رقم السجل التجاري' : 'CR number',
                      controller: _commercialRegistration,
                      enabled: false,
                    ),
                    SizedBox(height: 16.h),
                    MyTextField(
                      label: t.ar ? 'نبذة عن المكتب' : 'Office bio',
                      hintText: t.ar
                          ? 'اكتب نبذة مختصرة عن المكتب'
                          : 'Write a short office bio',
                      controller: _bio,
                      maxLines: 5,
                    ),
                    SizedBox(height: 24.h),
                    MyButton(
                      textButton: t.ar ? 'حفظ التعديلات' : 'Save changes',
                      isLoading: _loading,
                      onTap: () => _save(t),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick({required bool cover}) async {
    final file = await choseImage(ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() {
      if (cover) {
        _cover = file;
      } else {
        _logo = file;
      }
    });
  }

  Future<void> _save(DealerText t) async {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _country.isEmpty ||
        _city.isEmpty) {
      _message(t.requiredFields);
      return;
    }

    setState(() => _loading = true);
    final uploaded = <String>[];
    try {
      final provider = context.read<AuthProvider>();
      final office = provider.session!.office!;
      var logoUrl = office.image;
      var coverUrl = office.cover;

      if (_logo != null) {
        logoUrl =
            await _upload.uploadFile(
              file: _logo!,
              bucket: SupabaseTables.officesBucket,
              folder: 'offices/${office.id}',
              fileNamePrefix: 'profile',
            ) ??
            '';
        if (logoUrl.isEmpty) {
          throw Exception('Unable to upload office logo');
        }
        uploaded.add(logoUrl);
      }
      if (_cover != null) {
        coverUrl =
            await _upload.uploadFile(
              file: _cover!,
              bucket: SupabaseTables.officesBucket,
              folder: 'offices/${office.id}',
              fileNamePrefix: 'cover',
            ) ??
            '';
        if (coverUrl.isEmpty) {
          throw Exception('Unable to upload office cover');
        }
        uploaded.add(coverUrl);
      }

      final updated = office.copyWith(
        officeName: _name.text.trim(),
        phoneNumber: _phone.text.trim(),
        country: _country,
        city: _city,
        bio: _bio.text.trim(),
        image: logoUrl,
        cover: coverUrl,
      );
      await OfficeService().updateOffice(updated);

      if (_logo != null) {
        await _upload.deleteUrl(
          url: office.image,
          bucket: SupabaseTables.officesBucket,
        );
      }
      if (_cover != null) {
        await _upload.deleteUrl(
          url: office.cover,
          bucket: SupabaseTables.officesBucket,
        );
      }

      provider.setSession(AccountSession.office(updated));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.saved), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (error) {
      await _upload.deleteUrls(
        urls: uploaded,
        bucket: SupabaseTables.officesBucket,
      );
      if (mounted) _message('${t.failed}: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _countryLabel(bool isArabic) {
    if (_country.isEmpty) return '';
    final item = CountryCityData.countryList.firstWhere(
      (country) => country['key'] == _country,
      orElse: () => {'key': _country, 'name_ar': _country, 'name_en': _country},
    );
    return item[isArabic ? 'name_ar' : 'name_en'] ?? _country;
  }

  Future<void> _chooseCountry(DealerText t) async {
    final selected = await showSelectionBottomSheet<String>(
      context: context,
      title: t.ar ? 'اختر الدولة' : 'Choose country',
      selectedValue: _country,
      items: CountryCityData.countryList
          .map(
            (country) => SelectionItem(
              value: country['key']!,
              label: country[t.ar ? 'name_ar' : 'name_en']!,
            ),
          )
          .toList(),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (_country != selected) _city = '';
      _country = selected;
    });
  }

  Future<void> _chooseCity(DealerText t) async {
    if (_country.isEmpty) {
      _message(t.ar ? 'اختر الدولة أولًا' : 'Choose a country first');
      return;
    }
    final selected = await showSelectionBottomSheet<String>(
      context: context,
      title: t.ar ? 'اختر المدينة' : 'Choose city',
      selectedValue: _city,
      items: CountryCityData.citiesFor(
        _country,
      ).map((city) => SelectionItem(value: city, label: city)).toList(),
    );
    if (selected != null && mounted) setState(() => _city = selected);
  }

  Widget _editBadge({double size = 36}) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: AppColors.primaryNormal,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Icon(
        AppIcons.cameraAlt,
        size: (size * .48).sp,
        color: AppColors.white,
      ),
    );
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
