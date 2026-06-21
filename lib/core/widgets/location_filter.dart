import 'package:flutter/material.dart';

import '../../data/country_city_data.dart';
import '../l10n/app_localizations.dart';
import 'selection_bottom_sheet.dart';

class LocationFilterResult {
  final String country;
  final String city;

  const LocationFilterResult({required this.country, required this.city});
}

Future<LocationFilterResult?> showLocationFilter({
  required BuildContext context,
  String country = '',
  String city = '',
}) async {
  final l = AppLocalizations.of(context)!;
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final selectedCountry = await showSelectionBottomSheet<String>(
    context: context,
    title: l.chooseCountry,
    selectedValue: country,
    items: [
      SelectionItem(value: '', label: l.showAll),
      ...CountryCityData.countryList.map(
        (item) => SelectionItem(
          value: item['key']!,
          label: item[isArabic ? 'name_ar' : 'name_en']!,
        ),
      ),
    ],
  );
  if (selectedCountry == null || !context.mounted) return null;
  if (selectedCountry.isEmpty) {
    return const LocationFilterResult(country: '', city: '');
  }
  final selectedCity = await showSelectionBottomSheet<String>(
    context: context,
    title: l.chooseCity,
    selectedValue: selectedCountry == country ? city : '',
    items: [
      SelectionItem(value: '', label: l.showAll),
      ...CountryCityData.citiesFor(
        selectedCountry,
      ).map((item) => SelectionItem(value: item, label: item)),
    ],
  );
  if (selectedCity == null) return null;
  return LocationFilterResult(country: selectedCountry, city: selectedCity);
}
