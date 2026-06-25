import 'package:arini_plus_app/core/widgets/custom_width_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/helpers/location_matcher.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/my_button.dart';
import '../../../data/country_city_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dealer/data/car_brands_data.dart';
import '../models/car_model.dart';
import '../providers/cars_provider.dart';

class CarFiltersScreen extends StatefulWidget {
  final CarsProvider provider;

  const CarFiltersScreen({super.key, required this.provider});

  @override
  State<CarFiltersScreen> createState() => _CarFiltersScreenState();
}

class _CarFiltersScreenState extends State<CarFiltersScreen> {
  late CarFilterSelection _draft;
  _CarFilterCategory _selectedCategory = _CarFilterCategory.region;
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCountry = '';
  bool _didInitCountry = false;

  @override
  void initState() {
    super.initState();
    _draft = _clone(widget.provider.filters);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitCountry) return;
    final session = context.read<AuthProvider>().session;
    final country = session?.country ?? widget.provider.country;
    _selectedCountry = _countryKey(country.isNotEmpty ? country : '');
    _didInitCountry = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final categories = _categories(l);
    final options = _filteredOptions(_optionsFor(_selectedCategory, l));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 58.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border01.withValues(alpha: .65),
                    width: 1.w,
                  ),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        AppIcons.arrowForward,
                        size: 20.sp,
                        color: AppColors.font01,
                      ),
                    ),
                  ),
                  CustomWidthSpacer(width: 16.w),
                  Expanded(
                    child: Text(
                      l.filter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getMediumStyle(
                        size: 14,
                        color: AppColors.font02,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _reset,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        l.reset,
                        style: getMediumStyle(
                          size: 14,
                          color: AppColors.primaryNormal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 16.h),
                child: Row(
                  textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _optionsPanel(l, options)),
                    SizedBox(width: 12.w),
                    SizedBox(width: 154.w, child: _categoriesPanel(categories)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 18.h),
              child: MyButton(
                textButton: l.apply,
                onTap: _apply,
                heightButton: 56,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionsPanel(AppLocalizations l, List<_FilterOption> options) {
    if (_selectedCategory == _CarFilterCategory.price) {
      return _pricePanel();
    }

    return Column(
      children: [
        SizedBox(
          height: 48.h,
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: l.searchHint,
              hintStyle: getRegularStyle(size: 13, color: AppColors.hint),
              prefixIcon: Icon(
                AppIcons.search,
                size: 21.sp,
                color: AppColors.hint,
              ),
              filled: true,
              fillColor: AppColors.white,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: const BorderSide(color: AppColors.border01),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: const BorderSide(color: AppColors.border01),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: const BorderSide(color: AppColors.primaryNormal),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: options.isEmpty
              ? Center(
                  child: Text(
                    l.noFilterOptions,
                    textAlign: TextAlign.center,
                    style: getRegularStyle(size: 13, color: AppColors.hint),
                  ),
                )
              : ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: options.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1.h, color: AppColors.border01),
                  itemBuilder: (_, index) {
                    final option = options[index];
                    final selected = option.isAll
                        ? _selectedValues.isEmpty
                        : _selectedValues.contains(option.value);
                    return InkWell(
                      onTap: () => _toggle(option.value, isAll: option.isAll),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: (_) =>
                                  _toggle(option.value, isAll: option.isAll),
                              activeColor: AppColors.primaryNormal,
                              side: const BorderSide(color: AppColors.hint),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            if (option.color != null) ...[
                              SizedBox(width: 4.w),
                              Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color: option.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.border02,
                                    width: .7.w,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                option.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: getMediumStyle(
                                  size: 15,
                                  color: AppColors.font02,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _pricePanel() {
    final bounds = _priceBounds();
    final currency = _currencyForCountry(_selectedCountry);
    if (bounds == null) {
      return Center(
        child: Text(
          _t(
            'لا توجد أسعار متاحة لهذا الفلتر.',
            'No available prices for this filter.',
          ),
          textAlign: TextAlign.center,
          style: getRegularStyle(size: 13, color: AppColors.hint),
        ),
      );
    }

    final min = bounds.$1;
    final max = bounds.$2 > bounds.$1 ? bounds.$2 : bounds.$1 + 1;
    final start = (_draft.minPrice ?? bounds.$1).clamp(min, max).toDouble();
    final end = (_draft.maxPrice ?? bounds.$2).clamp(min, max).toDouble();
    final values = RangeValues(start, end < start ? start : end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border01),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _priceValue(
                      _t('أقل سعر', 'Minimum price'),
                      values.start,
                      currency,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _priceValue(
                      _t('أعلى سعر', 'Maximum price'),
                      values.end,
                      currency,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              RangeSlider(
                min: min,
                max: max,
                values: values,
                activeColor: AppColors.primaryNormal,
                inactiveColor: AppColors.primaryLightActive,
                labels: RangeLabels(
                  _formatPrice(values.start, currency),
                  _formatPrice(values.end, currency),
                ),
                onChanged: (newValues) {
                  setState(() {
                    _draft = _draft.copyWithPrice(
                      minPrice: newValues.start,
                      maxPrice: newValues.end,
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceValue(String label, double value, String currency) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border01),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: getRegularStyle(size: 11, color: AppColors.hint)),
          SizedBox(height: 4.h),
          Text(
            _formatPrice(value, currency),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getMediumStyle(size: 13, color: AppColors.font02),
          ),
        ],
      ),
    );
  }

  Widget _categoriesPanel(List<_FilterCategoryItem> categories) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border01),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1.h, color: AppColors.border01),
          itemBuilder: (_, index) {
            final category = categories[index];
            final selected = category.category == _selectedCategory;
            final disabled =
                category.category == _CarFilterCategory.model &&
                _draft.brands.isEmpty;
            return InkWell(
              onTap: () {
                if (disabled) return;
                setState(() {
                  _selectedCategory = category.category;
                  _query = '';
                  _searchController.clear();
                });
              },
              child: Container(
                height: 54.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                color: selected ? AppColors.primaryLight : AppColors.background,
                child: Row(
                  children: [
                    Icon(
                        category.icon,
                        size: 20.sp,
                        color: selected
                            ? AppColors.primaryNormal
                            : AppColors.hint.withValues(
                                alpha: disabled ? .45 : 1,
                              ),
                      ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getMediumStyle(
                          size: 13,
                          color: disabled
                              ? AppColors.hint
                              : selected
                              ? AppColors.primaryNormal
                              : AppColors.font01,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<_FilterCategoryItem> _categories(AppLocalizations l) {
    return [
      _FilterCategoryItem(
        _CarFilterCategory.brand,
        l.manufacturer,
        Icons.business_rounded,
      ),
      _FilterCategoryItem(_CarFilterCategory.model, l.model, AppIcons.car),
      _FilterCategoryItem(_CarFilterCategory.year, l.year, AppIcons.calendar),
      _FilterCategoryItem(
        _CarFilterCategory.transmission,
        l.transmission,
        AppIcons.transmission,
      ),
      _FilterCategoryItem(_CarFilterCategory.fuel, l.fuel, AppIcons.fuel),
      _FilterCategoryItem(_CarFilterCategory.price, _t('السعر', 'Price'), Icons.attach_money_rounded),
      _FilterCategoryItem(
        _CarFilterCategory.exteriorColor,
        l.exteriorColor,
        Icons.color_lens_outlined,
      ),
      _FilterCategoryItem(
        _CarFilterCategory.region,
        l.region,
        AppIcons.globe,
      ),
    ];
  }

  List<_FilterOption> _optionsFor(
    _CarFilterCategory category,
    AppLocalizations l,
  ) {
    final cars = widget.provider.allCars;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return switch (category) {
      _CarFilterCategory.brand => _uniqueOptions(
        CarBrandsData.brands.map((b) => b.name),
        labelBuilder: (value) => _brandLabel(value),
        valueBuilder: (value) => _brandFilterValue(value),
      ),
      _CarFilterCategory.model => _draft.brands.isEmpty
          ? const []
          : _uniqueOptions(_modelsForSelectedBrands()),
      _CarFilterCategory.year => _yearOptions(cars),
      _CarFilterCategory.transmission => [
        _FilterOption('', _t('الكل', 'All'), isAll: true),
        _FilterOption('AUTOMATIC', _transmissionLabel('AUTOMATIC', isArabic)),
        _FilterOption('MANUAL', _transmissionLabel('MANUAL', isArabic)),
      ],
      _CarFilterCategory.fuel => [
        _FilterOption('', _t('الكل', 'All'), isAll: true),
        _FilterOption('GASOLINE', _fuelLabel('GASOLINE', isArabic)),
        _FilterOption('DIESEL', _fuelLabel('DIESEL', isArabic)),
        _FilterOption('ELECTRIC', _fuelLabel('ELECTRIC', isArabic)),
        _FilterOption('HYBRID', _fuelLabel('HYBRID', isArabic)),
      ],
      _CarFilterCategory.exteriorColor => _uniqueOptions(
        cars.map((car) => car.color),
        labelBuilder: (value) => _colorLabel(value, isArabic),
        colorBuilder: _colorValue,
        keyBuilder: (value) => _colorKey(value),
      ),
      _CarFilterCategory.region => _cityOptions(isArabic),
      _ => const [],
    };
  }

  List<String> _modelsForSelectedBrands() {
    final models = <String>{};
    for (final brandName in _draft.brands) {
      final brand = CarBrandsData.byName(brandName);
      if (brand != null) {
        models.addAll(brand.models);
      }
    }
    return models.toList();
  }

  List<_FilterOption> _filteredOptions(List<_FilterOption> options) {
    final query = _normalize(_query);
    if (query.isEmpty) return options;
    return options
        .where((option) => _normalize(option.label).contains(query))
        .toList();
  }

  List<_FilterOption> _yearOptions(List<CarModel> cars) {
    final years = cars
        .map((car) => car.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return years
        .map((year) => _FilterOption(year.toString(), year.toString()))
        .toList();
  }

  List<_FilterOption> _cityOptions(bool isArabic) {
    return _uniqueOptions(
      CountryCityData.citiesFor(_selectedCountry),
      labelBuilder: (value) => _cityLabel(value, isArabic),
    );
  }

  List<_FilterOption> _uniqueOptions(
    Iterable<String> values, {
    String Function(String value)? labelBuilder,
    Color? Function(String value)? colorBuilder,
    String Function(String value)? keyBuilder,
    String Function(String value)? valueBuilder,
  }) {
    final options = <String, _FilterOption>{};
    for (final raw in values) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      final key = keyBuilder?.call(value) ?? _normalize(value);
      options.putIfAbsent(
        key,
        () => _FilterOption(
          valueBuilder?.call(value) ?? value,
          labelBuilder?.call(value) ?? value,
          color: colorBuilder?.call(value),
        ),
      );
    }
    final result = options.values.toList();
    result.sort((a, b) => a.label.compareTo(b.label));
    return result;
  }

  Set<String> get _selectedValues {
    return switch (_selectedCategory) {
      _CarFilterCategory.brand => _draft.brands,
      _CarFilterCategory.model => _draft.models,
      _CarFilterCategory.year => _draft.years,
      _CarFilterCategory.transmission => _draft.transmissions,
      _CarFilterCategory.fuel => _draft.fuels,
      _CarFilterCategory.exteriorColor => _draft.colors,
      _CarFilterCategory.region => _draft.cities,
      _ => const {},
    };
  }

  void _toggle(String value, {bool isAll = false}) {
    if (!_supportsSelection(_selectedCategory)) return;
    setState(() {
      if (isAll) {
        _setSelectedValues({});
        return;
      }
      final values = {..._selectedValues};
      if (values.contains(value)) {
        values.remove(value);
      } else {
        values.add(value);
      }
      _setSelectedValues(values);
    });
  }

  bool _supportsSelection(_CarFilterCategory category) {
    return switch (category) {
      _CarFilterCategory.brand ||
      _CarFilterCategory.model ||
      _CarFilterCategory.year ||
      _CarFilterCategory.transmission ||
      _CarFilterCategory.fuel ||
      _CarFilterCategory.exteriorColor ||
      _CarFilterCategory.region => true,
      _ => false,
    };
  }

  void _setSelectedValues(Set<String> values) {
    switch (_selectedCategory) {
      case _CarFilterCategory.brand:
        _draft = _draft.copyWith(
          brands: values,
          models: _validModelsForBrands(values),
        );
        break;
      case _CarFilterCategory.model:
        if (_draft.brands.isNotEmpty) {
          _draft = _draft.copyWith(models: values);
        }
        break;
      case _CarFilterCategory.year:
        _draft = _draft.copyWith(years: values);
        break;
      case _CarFilterCategory.transmission:
        _draft = _draft.copyWith(transmissions: values);
        break;
      case _CarFilterCategory.fuel:
        _draft = _draft.copyWith(fuels: values);
        break;
      case _CarFilterCategory.exteriorColor:
        _draft = _draft.copyWith(colors: values);
        break;
      case _CarFilterCategory.region:
        _draft = _draft.copyWith(cities: values);
        break;
      default:
        break;
    }
  }

  Set<String> _validModelsForBrands(Set<String> selectedBrands) {
    if (selectedBrands.isEmpty) return {};
    final available = <String>{};
    for (final brandName in selectedBrands) {
      final brand = CarBrandsData.byName(brandName);
      if (brand != null) {
        available.addAll(brand.models.map(_normalize));
      }
    }
    return _draft.models
        .where((model) => available.contains(_normalize(model)))
        .toSet();
  }

  void _apply() {
    widget.provider.applyFilters(
      country: _selectedCountry,
      city: '',
      filters: _draft,
    );
    Navigator.pop(context, true);
  }

  void _reset() {
    widget.provider.clearFilters();
    Navigator.pop(context, true);
  }

  static CarFilterSelection _clone(CarFilterSelection source) {
    return CarFilterSelection(
      brands: {...source.brands},
      models: {...source.models},
      years: {...source.years},
      transmissions: {...source.transmissions},
      fuels: {...source.fuels},
      colors: {...source.colors},
      cities: {...source.cities},
      minPrice: source.minPrice,
      maxPrice: source.maxPrice,
    );
  }

  static String _countryKey(String country) {
    if (country.trim().isEmpty) return '';
    for (final item in CountryCityData.countryList) {
      final key = item['key'] ?? '';
      if (LocationMatcher.country(country, key) ||
          LocationMatcher.country(country, item['name_ar'] ?? '') ||
          LocationMatcher.country(country, item['name_en'] ?? '')) {
        return key;
      }
    }
    return country.trim();
  }

  (double, double)? _priceBounds() {
    final prices = widget.provider.allCars
        .where(
          (car) =>
              _selectedCountry.isEmpty ||
              (car.office != null &&
                  LocationMatcher.country(
                    car.office!.country,
                    _selectedCountry,
                  )),
        )
        .map((car) => car.dailyPrice?.toDouble())
        .whereType<double>()
        .toList();
    if (prices.isEmpty) return null;
    prices.sort();
    return (prices.first, prices.last);
  }

  String _t(String ar, String en) {
    return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  }

  static String _formatPrice(double value, String currency) {
    return '${value.round()} $currency';
  }

  static String _currencyForCountry(String country) {
    switch (country.trim().toUpperCase()) {
      case 'SA':
        return 'SAR';
      case 'AE':
        return 'AED';
      case 'QA':
        return 'QAR';
      case 'KW':
        return 'KWD';
      case 'BH':
        return 'BHD';
      default:
        return 'OMR';
    }
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  static String _brandFilterValue(String brandName) {
    final aliases = <String, String>{
      'mercedes-benz': 'Mercedes-Benz',
      'mercedes benz': 'Mercedes-Benz',
      'vw': 'Volkswagen',
      'vw - volkswagen': 'Volkswagen',
      'range rover': 'Land Rover',
    };
    return aliases[_normalize(brandName)] ?? brandName;
  }

  static String _brandLabel(String value) {
    final labels = <String, String>{
      'toyota': 'Toyota',
      'honda': 'Honda',
      'nissan': 'Nissan',
      'hyundai': 'Hyundai',
      'kia': 'Kia',
      'mercedes': 'Mercedes',
      'bmw': 'BMW',
      'audi': 'Audi',
      'ford': 'Ford',
      'chevrolet': 'Chevrolet',
      'mitsubishi': 'Mitsubishi',
      'mazda': 'Mazda',
      'suzuki': 'Suzuki',
      'lexus': 'Lexus',
      'volkswagen': 'Volkswagen',
      'porsche': 'Porsche',
      'jeep': 'Jeep',
      'renault': 'Renault',
      'peugeot': 'Peugeot',
      'mg': 'MG',
      'chery': 'Chery',
      'geely': 'Geely',
      'changan': 'Changan',
      'gac': 'GAC',
      'baic': 'BAIC',
    };
    final key = _normalize(value);
    return labels[key] ?? value;
  }

  static String _fuelLabel(String value, bool isArabic) {
    return switch (value) {
      'GASOLINE' => isArabic ? 'بنزين' : 'Gasoline',
      'DIESEL' => isArabic ? 'ديزل' : 'Diesel',
      'ELECTRIC' => isArabic ? 'كهرباء' : 'Electric',
      'HYBRID' => isArabic ? 'هايبرد' : 'Hybrid',
      _ => value,
    };
  }

  static String _transmissionLabel(String value, bool isArabic) {
    return switch (value) {
      'AUTOMATIC' => isArabic ? 'أوتوماتيك' : 'Automatic',
      'MANUAL' => isArabic ? 'يدوي' : 'Manual',
      _ => value,
    };
  }

  static String _colorLabel(String value, bool isArabic) {
    final label = _colorLabels[_colorKey(value)];
    if (label == null) return value;
    return isArabic ? label.$1 : label.$2;
  }

  static Color _colorValue(String value) {
    final hexColor = _hexColor(value);
    if (hexColor != null) return hexColor;
    switch (_colorKey(value)) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'gray':
        return Colors.grey;
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'purple':
        return Colors.purple;
      case 'maroon':
        return const Color(0xFF800000);
      default:
        return AppColors.border02;
    }
  }

  static const Map<String, (String ar, String en)> _colorLabels = {
    'white': ('أبيض', 'White'),
    'black': ('أسود', 'Black'),
    'gray': ('رمادي', 'Gray'),
    'silver': ('فضي', 'Silver'),
    'red': ('أحمر', 'Red'),
    'blue': ('أزرق', 'Blue'),
    'green': ('أخضر', 'Green'),
    'yellow': ('أصفر', 'Yellow'),
    'orange': ('برتقالي', 'Orange'),
    'brown': ('بني', 'Brown'),
    'beige': ('بيج', 'Beige'),
    'gold': ('ذهبي', 'Gold'),
    'purple': ('بنفسجي', 'Purple'),
    'maroon': ('عنابي', 'Maroon'),
  };

  static String _colorKey(String value) {
    final normalized = _normalizeArabic(value);
    switch (normalized) {
      case 'white':
      case 'ابيض':
        return 'white';
      case 'black':
      case 'اسود':
        return 'black';
      case 'gray':
      case 'grey':
      case 'رمادي':
      case 'رصاصي':
        return 'gray';
      case 'silver':
      case 'فضي':
        return 'silver';
      case 'red':
      case 'احمر':
        return 'red';
      case 'blue':
      case 'ازرق':
        return 'blue';
      case 'green':
      case 'اخضر':
        return 'green';
      case 'yellow':
      case 'اصفر':
        return 'yellow';
      case 'orange':
      case 'برتقالي':
        return 'orange';
      case 'brown':
      case 'بني':
        return 'brown';
      case 'beige':
      case 'بيج':
        return 'beige';
      case 'gold':
      case 'golden':
      case 'ذهبي':
        return 'gold';
      case 'purple':
      case 'بنفسجي':
        return 'purple';
      case 'maroon':
      case 'عنابي':
        return 'maroon';
      default:
        return normalized;
    }
  }

  static String _normalizeArabic(String value) => _normalize(value);

  static Color? _hexColor(String value) {
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;
    return Color(normalized.length == 6 ? 0xFF000000 | parsed : parsed);
  }

  static String _cityLabel(String value, bool isArabic) {
    final normalized = _normalize(value);
    final labels = <String, (String ar, String en)>{
      'muscat': ('مسقط', 'Muscat'),
      'مسقط': ('مسقط', 'Muscat'),
      'salalah': ('صلالة', 'Salalah'),
      'صلالة': ('صلالة', 'Salalah'),
      'sohar': ('صحار', 'Sohar'),
      'صحار': ('صحار', 'Sohar'),
      'nizwa': ('نزوى', 'Nizwa'),
      'نزوى': ('نزوى', 'Nizwa'),
      'sur': ('صور', 'Sur'),
      'صور': ('صور', 'Sur'),
      'barka': ('بركاء', 'Barka'),
      'بركاء': ('بركاء', 'Barka'),
      'riyadh': ('الرياض', 'Riyadh'),
      'الرياض': ('الرياض', 'Riyadh'),
      'jeddah': ('جدة', 'Jeddah'),
      'جدة': ('جدة', 'Jeddah'),
      'dubai': ('دبي', 'Dubai'),
      'دبي': ('دبي', 'Dubai'),
      'abu dhabi': ('أبو ظبي', 'Abu Dhabi'),
      'أبو ظبي': ('أبو ظبي', 'Abu Dhabi'),
      'doha': ('الدوحة', 'Doha'),
      'الدوحة': ('الدوحة', 'Doha'),
      'kuwait': ('الكويت', 'Kuwait'),
      'الكويت': ('الكويت', 'Kuwait'),
      'manama': ('المنامة', 'Manama'),
      'المنامة': ('المنامة', 'Manama'),
    };
    final label = labels[normalized] ?? labels[value.trim()];
    if (label == null) return value;
    return isArabic ? label.$1 : label.$2;
  }
}

enum _CarFilterCategory {
  brand,
  model,
  year,
  transmission,
  fuel,
  price,
  exteriorColor,
  region,
}

class _FilterCategoryItem {
  final _CarFilterCategory category;
  final String label;
  final IconData icon;

  const _FilterCategoryItem(this.category, this.label, this.icon);
}

class _FilterOption {
  final String value;
  final String label;
  final Color? color;
  final bool isAll;

  const _FilterOption(this.value, this.label, {this.color, this.isAll = false});
}
