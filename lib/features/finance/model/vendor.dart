class Vendor {
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;

  Vendor({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }
}
