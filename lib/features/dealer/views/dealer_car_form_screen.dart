import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/constants/assets_app.dart';
import '../../../core/helpers/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/my_button.dart';
import '../../../core/widgets/my_lable_text_fild.dart';
import '../../../core/widgets/selection_bottom_sheet.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../cars/models/car_model.dart';
import '../data/car_brands_data.dart';
import '../helpers/dealer_text.dart';
import '../services/dealer_car_service.dart';
import '../widgets/brand_selection.dart';

class DealerCarFormScreen extends StatefulWidget {
  final CarModel? car;

  const DealerCarFormScreen({super.key, this.car});

  @override
  State<DealerCarFormScreen> createState() => _DealerCarFormScreenState();
}

class _DealerCarFormScreenState extends State<DealerCarFormScreen>
    with ImagePikerHelper {
  final _service = DealerCarService();
  late final TextEditingController _name;
  late final TextEditingController _year;
  late final TextEditingController _color;
  late final TextEditingController _plate;
  late final TextEditingController _price;
  String _brand = '';
  String _model = '';
  String _fuel = 'GASOLINE';
  String _transmission = 'AUTOMATIC';
  int _seats = 5;
  String _rentalType = 'daily';
  String _status = 'available';
  List<String> _existing = [];
  final List<File> _newImages = [];
  int _step = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final car = widget.car;
    _name = TextEditingController(text: car?.name ?? '');
    _year = TextEditingController(text: car?.year?.toString() ?? '');
    _color = TextEditingController(text: car?.color ?? '');
    _plate = TextEditingController(text: car?.plateNumber ?? '');
    _price = TextEditingController(text: car?.dailyPrice?.toString() ?? '');
    _brand = car?.brand ?? '';
    _model = car?.model ?? '';
    _fuel = car?.fuel.isNotEmpty == true ? car!.fuel : 'GASOLINE';
    _transmission = car?.transmission.isNotEmpty == true
        ? car!.transmission
        : 'AUTOMATIC';
    _seats = car?.seats ?? 5;
    _rentalType = car?.rentalType ?? 'daily';
    _status = car?.status ?? 'available';
    _existing = car == null
        ? []
        : {car.image, ...car.images}
              .where(
                (value) => value.isNotEmpty && value != AssetsApp.hyundaiAvante,
              )
              .take(3)
              .toList();
  }

  @override
  void dispose() {
    _name.dispose();
    _year.dispose();
    _color.dispose();
    _plate.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = DealerText.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: widget.car == null ? t.addCar : t.editCar),
            _steps(t),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.r),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: switch (_step) {
                    0 => _basicStep(t),
                    1 => _specificationsStep(t),
                    2 => _priceStep(t),
                    _ => _imagesStep(t),
                  },
                ),
              ),
            ),
            _actions(t),
          ],
        ),
      ),
    );
  }

  Widget _steps(DealerText t) {
    final labels = [t.carName, t.status, t.price, t.images];
    final icons = [
      AppIcons.car,
      AppIcons.settings,
      Icons.attach_money,
      AppIcons.image,
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 4.h),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == _step;
          final done = index < _step;
          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: active
                      ? AppColors.primaryNormal
                      : done
                      ? AppColors.success
                      : AppColors.gray,
                  child: Icon(
                    done ? Icons.check_rounded : icons[index],
                    size: 19.sp,
                    color: active || done ? AppColors.white : AppColors.hint,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getMediumStyle(
                    size: 9,
                    color: active ? AppColors.primaryNormal : AppColors.font01,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _basicStep(DealerText t) {
    return Column(
      key: const ValueKey(0),
      children: [
        MyTextField(
          label: t.carName,
          hintText: t.carName,
          controller: _name,
          isRequired: true,
        ),
        SizedBox(height: 18.h),
        BrandSelectionField(
          label: t.brand,
          brand: CarBrandsData.byName(_brand),
          onTap: () => _chooseBrand(t),
        ),
        SizedBox(height: 18.h),
        _selection(
          t.model,
          _model,
          _brand.isEmpty ? null : () => _chooseModel(t),
        ),
      ],
    );
  }

  Widget _specificationsStep(DealerText t) {
    return Column(
      key: const ValueKey(1),
      children: [
        Row(
          children: [
            Expanded(
              child: MyTextField(
                label: t.year,
                hintText: '2024',
                controller: _year,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: MyTextField(
                label: t.color,
                hintText: t.color,
                controller: _color,
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: _selection(
                t.transmission,
                _transmissionLabel(t),
                () => _chooseValue(
                  t.transmission,
                  [
                    (t.ar ? 'أوتوماتيك' : 'Automatic', 'AUTOMATIC'),
                    (t.ar ? 'عادي' : 'Manual', 'MANUAL'),
                  ],
                  _transmission,
                  (value) => setState(() => _transmission = value),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _selection(
                t.fuel,
                _fuelLabel(t),
                () => _chooseValue(
                  t.fuel,
                  [
                    (t.ar ? 'بنزين' : 'Gasoline', 'GASOLINE'),
                    (t.ar ? 'ديزل' : 'Diesel', 'DIESEL'),
                    (t.ar ? 'كهرباء' : 'Electric', 'ELECTRIC'),
                    (t.ar ? 'هجين' : 'Hybrid', 'HYBRID'),
                  ],
                  _fuel,
                  (value) => setState(() => _fuel = value),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: _selection(
                t.seats,
                _seats.toString(),
                () => _choose(
                  t.seats,
                  const ['2', '4', '5', '7', '8'],
                  _seats.toString(),
                  (value) => setState(() => _seats = int.parse(value)),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: MyTextField(
                label: t.plate,
                hintText: t.plate,
                controller: _plate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _priceStep(DealerText t) {
    return Column(
      key: const ValueKey(2),
      children: [
        _segmented(
          t.rentalType,
          [(t.daily, 'daily'), (t.monthly, 'monthly')],
          _rentalType,
          (value) => setState(() => _rentalType = value),
        ),
        SizedBox(height: 20.h),
        MyTextField(
          label: t.price,
          hintText: '0',
          controller: _price,
          isRequired: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        SizedBox(height: 20.h),
        _segmented(
          t.status,
          [
            (t.available, 'available'),
            (t.rented, 'rented'),
            (t.maintenance, 'maintenance'),
          ],
          _status,
          (value) => setState(() => _status = value),
        ),
      ],
    );
  }

  Widget _imagesStep(DealerText t) {
    final imagesCount = _existing.length + _newImages.length;
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.images,
          style: getSemiBoldStyle(size: 16, color: AppColors.black10),
        ),
        SizedBox(height: 5.h),
        Text(
          t.imagesHint,
          style: getRegularStyle(size: 11, color: AppColors.font01),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: .95,
          ),
          itemCount: 3,
          itemBuilder: (_, index) {
            if (index < _existing.length) {
              return _imageTile(
                AppNetworkImage(
                  url: _existing[index],
                  fit: BoxFit.cover,
                  memoryCacheWidth: 360,
                  diskCacheWidth: 720,
                  fallback: const ColoredBox(color: AppColors.background),
                ),
                () => setState(() => _existing.removeAt(index)),
                () => _replaceImage(existingIndex: index),
              );
            }
            final fileIndex = index - _existing.length;
            if (fileIndex < _newImages.length) {
              return _imageTile(
                Image.file(_newImages[fileIndex], fit: BoxFit.cover),
                () => setState(() => _newImages.removeAt(fileIndex)),
                () => _replaceImage(newIndex: fileIndex),
              );
            }
            return InkWell(
              onTap: imagesCount >= 3 ? null : _pickImages,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border02,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Icon(
                  AppIcons.image,
                  color: AppColors.primaryNormal,
                  size: 28.sp,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _imageTile(Widget image, VoidCallback remove, VoidCallback replace) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12.r), child: image),
        PositionedDirectional(
          top: 4.h,
          end: 4.w,
          child: GestureDetector(
            onTap: remove,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: AppColors.error,
              child: Icon(Icons.close, color: AppColors.white, size: 14.sp),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 4.h,
          end: 4.w,
          child: GestureDetector(
            onTap: replace,
            child: CircleAvatar(
              radius: 13.r,
              backgroundColor: AppColors.primaryNormal,
              child: Icon(AppIcons.edit, color: AppColors.white, size: 14.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _selection(String label, String value, VoidCallback? onTap) {
    return SelectionField(label: label, value: value, onTap: onTap ?? () {});
  }

  Widget _segmented(
    String title,
    List<(String, String)> items,
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: getMediumStyle(size: 14)),
        SizedBox(height: 10.h),
        Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: 8.w),
                    child: InkWell(
                      onTap: () => onChanged(item.$2),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        height: 50.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected == item.$2
                              ? AppColors.primaryNormal
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: selected == item.$2
                                ? AppColors.primaryNormal
                                : AppColors.border01,
                          ),
                        ),
                        child: Text(
                          item.$1,
                          style: getSemiBoldStyle(
                            size: 13,
                            color: selected == item.$2
                                ? AppColors.white
                                : AppColors.font01,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _actions(DealerText t) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
        child: Row(
          children: [
            if (_step > 0)
              Expanded(
                child: MyButton(
                  textButton: t.ar ? 'السابق' : 'Previous',
                  heightButton: 48,
                  textSize: 13,
                  isSecondary: true,
                  onTap: () => setState(() => _step--),
                ),
              ),
            if (_step > 0) SizedBox(width: 10.w),
            Expanded(
              child: MyButton(
                textButton: _step == 3 ? t.save : (t.ar ? 'التالي' : 'Next'),
                heightButton: 48,
                textSize: 13,
                isLoading: _loading,
                onTap: _step == 3 ? () => _save(t) : () => _next(t),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choose(
    String title,
    List<String> items,
    String selected,
    ValueChanged<String> onSelected,
  ) async {
    final value = await showSelectionBottomSheet<String>(
      context: context,
      title: title,
      selectedValue: selected,
      items: items
          .map((item) => SelectionItem(value: item, label: item))
          .toList(),
    );
    if (value != null) onSelected(value);
  }

  Future<void> _chooseBrand(DealerText t) async {
    final value = await showBrandSelection(
      context: context,
      title: t.brand,
      selected: CarBrandsData.byName(_brand),
    );
    if (value == null || !mounted) return;
    setState(() {
      if (_brand != value.name) _model = '';
      _brand = value.name;
    });
  }

  Future<void> _chooseModel(DealerText t) async {
    final models = CarBrandsData.byName(_brand)?.models ?? const <String>[];
    final value = await showSelectionBottomSheet<String>(
      context: context,
      title: t.model,
      selectedValue: models.contains(_model) ? _model : null,
      items: models
          .map((model) => SelectionItem(value: model, label: model))
          .toList(),
    );
    if (value == null || !mounted) return;
    setState(() => _model = value);
  }

  Future<void> _chooseValue(
    String title,
    List<(String, String)> items,
    String selected,
    ValueChanged<String> onSelected,
  ) async {
    final value = await showSelectionBottomSheet<String>(
      context: context,
      title: title,
      selectedValue: selected,
      items: items
          .map((item) => SelectionItem(value: item.$2, label: item.$1))
          .toList(),
    );
    if (value != null) onSelected(value);
  }

  String _fuelLabel(DealerText t) {
    return switch (_fuel) {
      'DIESEL' => t.ar ? 'ديزل' : 'Diesel',
      'ELECTRIC' => t.ar ? 'كهرباء' : 'Electric',
      'HYBRID' => t.ar ? 'هجين' : 'Hybrid',
      _ => t.ar ? 'بنزين' : 'Gasoline',
    };
  }

  String _transmissionLabel(DealerText t) {
    return _transmission == 'MANUAL'
        ? (t.ar ? 'عادي' : 'Manual')
        : (t.ar ? 'أوتوماتيك' : 'Automatic');
  }

  void _next(DealerText t) {
    if (_step == 0 &&
        (_name.text.trim().isEmpty || _brand.isEmpty || _model.isEmpty)) {
      _message(t.requiredFields);
      return;
    }
    if (_step == 1 &&
        (int.tryParse(_year.text) == null || _color.text.trim().isEmpty)) {
      _message(t.requiredFields);
      return;
    }
    if (_step == 2 &&
        (_price.text.trim().isEmpty ||
            num.tryParse(_price.text) == null ||
            num.parse(_price.text) <= 0)) {
      _message(t.requiredFields);
      return;
    }
    setState(() => _step++);
  }

  Future<void> _pickImages() async {
    final picked = await choseMaltyImage();
    if (!mounted) return;
    final room = 3 - _existing.length - _newImages.length;
    setState(() => _newImages.addAll(picked.take(room)));
  }

  Future<void> _replaceImage({int? existingIndex, int? newIndex}) async {
    final file = await choseImage(ImageSource.gallery);
    if (file == null || !mounted) return;
    setState(() {
      if (existingIndex != null) {
        _existing.removeAt(existingIndex);
        _newImages.add(file);
      } else if (newIndex != null) {
        _newImages[newIndex] = file;
      }
    });
  }

  Future<void> _save(DealerText t) async {
    if (_existing.isEmpty && _newImages.isEmpty) {
      _message(t.imagesHint);
      return;
    }
    setState(() => _loading = true);
    try {
      await _service.save(
        current: widget.car,
        name: _name.text,
        brand: _brand,
        model: _model,
        year: int.parse(_year.text),
        color: _color.text,
        fuel: _fuel,
        transmission: _transmission,
        seats: _seats,
        plateNumber: _plate.text,
        rentalType: _rentalType,
        status: _status,
        price: _price.text,
        newImages: _newImages,
        existingImages: _existing,
      );
      if (!mounted) return;
      _message(t.saved, success: true);
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _message('${t.failed}: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}
