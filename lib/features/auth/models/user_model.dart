class UserModel {
  final String id;
  final DateTime? createdAt;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String country;
  final String city;

  const UserModel({
    required this.id,
    this.createdAt,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.country,
    required this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName.trim(),
    'email': email.trim().toLowerCase(),
    'phone_number': phoneNumber.trim(),
    'country': country,
    'city': city,
  };

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? country,
    String? city,
  }) {
    return UserModel(
      id: id,
      createdAt: createdAt,
      fullName: fullName ?? this.fullName,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }
}
