class OfficeModel {
  final String id;
  final DateTime? createdAt;
  final String officeName;
  final String email;
  final String phoneNumber;
  final String country;
  final String city;
  final bool isActive;
  final String bio;
  final String image;
  final String cover;
  final String commercialRegistrationNumber;

  const OfficeModel({
    required this.id,
    this.createdAt,
    required this.officeName,
    required this.email,
    required this.phoneNumber,
    required this.country,
    required this.city,
    this.isActive = false,
    this.bio = '',
    this.image = '',
    this.cover = '',
    required this.commercialRegistrationNumber,
  });

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      id: _value(json, ['id', 'office_id']) ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      officeName:
          _value(json, ['office_name', 'name', 'title', 'business_name']) ?? '',
      email: _value(json, ['email', 'office_email']) ?? '',
      phoneNumber:
          _value(json, [
            'phone_number',
            'phone',
            'mobile',
            'whatsapp_number',
          ]) ??
          '',
      country: _value(json, ['country', 'country_code']) ?? '',
      city: _value(json, ['city', 'city_name']) ?? '',
      isActive: json['is_active'] == true || json['active'] == true,
      bio: _value(json, ['bio', 'description', 'about']) ?? '',
      image: _value(json, ['image', 'logo', 'image_url', 'avatar']) ?? '',
      cover:
          _value(json, ['cover', 'cover_image', 'banner', 'cover_url']) ?? '',
      commercialRegistrationNumber:
          _value(json, [
            'commercial_registration_number',
            'commercial_registration',
            'cr_number',
          ]) ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'office_name': officeName.trim(),
    'email': email.trim().toLowerCase(),
    'phone_number': phoneNumber.trim(),
    'country': country,
    'city': city,
    'bio': bio.trim(),
    'image': image,
    'cover': cover,
    'commercial_registration_number': commercialRegistrationNumber.trim(),
  };

  OfficeModel copyWith({
    String? officeName,
    String? email,
    String? phoneNumber,
    String? country,
    String? city,
    String? bio,
    String? image,
    String? cover,
    String? commercialRegistrationNumber,
  }) {
    return OfficeModel(
      id: id,
      createdAt: createdAt,
      officeName: officeName ?? this.officeName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      city: city ?? this.city,
      isActive: isActive,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      cover: cover ?? this.cover,
      commercialRegistrationNumber:
          commercialRegistrationNumber ?? this.commercialRegistrationNumber,
    );
  }

  static String? _value(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
