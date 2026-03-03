class AdoptionCenter {
  final String id;
  final String name;
  final String phone;
  final String email;
  final AddressInfo address;
  final LocationCoordinates? location;
  final String? description;
  final String? licenseNumber;
  final int availablePets;
  final double? distance; // Distance in meters

  AdoptionCenter({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.location,
    this.description,
    this.licenseNumber,
    this.availablePets = 0,
    this.distance,
  });

  /// Format address as single line string
  String get formattedAddress {
    final parts = <String>[];
    if (address.street?.isNotEmpty == true) parts.add(address.street!);
    if (address.city?.isNotEmpty == true) parts.add(address.city!);
    if (address.state?.isNotEmpty == true) parts.add(address.state!);
    if (address.zipCode?.isNotEmpty == true) parts.add(address.zipCode!);
    return parts.join(', ');
  }

  /// Format distance for display
  String get formattedDistance {
    if (distance == null) return '';
    if (distance! >= 1000) {
      return '${(distance! / 1000).toStringAsFixed(1)} km';
    }
    return '${distance!.toInt()} m';
  }

  factory AdoptionCenter.fromJson(Map<String, dynamic> json) {
    // Parse location coordinates
    LocationCoordinates? loc;
    if (json['location'] != null && json['location']['coordinates'] is List) {
      final coords = json['location']['coordinates'] as List;
      if (coords.length >= 2) {
        loc = LocationCoordinates(
          longitude: (coords[0] as num).toDouble(),
          latitude: (coords[1] as num).toDouble(),
        );
      }
    }

    // Parse distance (can be from aggregation or separate field)
    double? dist;
    if (json['distance'] != null) {
      dist = (json['distance'] is num)
          ? (json['distance'] as num).toDouble()
          : double.tryParse(json['distance'].toString());
    }

    return AdoptionCenter(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: AddressInfo.fromJson(json['address'] ?? {}),
      location: loc,
      description: json['description']?.toString(),
      licenseNumber: json['licenseNumber']?.toString(),
      availablePets: (json['availablePets'] as num?)?.toInt() ?? 0,
      distance: dist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address.toJson(),
      'location': location?.toJson(),
      'description': description,
      'licenseNumber': licenseNumber,
      'availablePets': availablePets,
      'distance': distance,
    };
  }
}

class AddressInfo {
  final String? street;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  AddressInfo({
    this.street,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      street: json['street']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      zipCode: json['zipCode']?.toString(),
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

class LocationCoordinates {
  final double longitude;
  final double latitude;

  LocationCoordinates({
    required this.longitude,
    required this.latitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'Point',
      'coordinates': [longitude, latitude],
    };
  }
}
