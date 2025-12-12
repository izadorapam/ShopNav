class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final double lat;
  final double lng;
  final String? category;
  final String? floor;

  Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.lat,
    required this.lng,
    this.category,
    this.floor,
  });

  Contact copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    double? lat,
    double? lng,
    String? category,
    String? floor,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      category: category ?? this.category,
      floor: floor ?? this.floor,
    );
  }
}