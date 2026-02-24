class Address {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String district;
  final String province;
  final String country;
  final String? postalCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.district,
    required this.province,
    required this.country,
    this.postalCode,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      label: (json['label'] ?? 'HOME').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      addressLine1: (json['addressLine1'] ?? '').toString(),
      addressLine2: json['addressLine2']?.toString(),
      city: (json['city'] ?? '').toString(),
      district: (json['district'] ?? '').toString(),
      province: (json['province'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      postalCode: json['postalCode']?.toString(),
      isDefault: json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'label': label,
        'name': name,
        'phone': phone,
        'addressLine1': addressLine1,
        if (addressLine2 != null) 'addressLine2': addressLine2,
        'city': city,
        'district': district,
        'province': province,
        'country': country,
        if (postalCode != null) 'postalCode': postalCode,
        'isDefault': isDefault,
      };

  Map<String, dynamic> toUpdateJson() => {
        'label': label,
        'name': name,
        'phone': phone,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'city': city,
        'district': district,
        'province': province,
        'country': country,
        'postalCode': postalCode,
      }..removeWhere((k, v) => v == null);
}