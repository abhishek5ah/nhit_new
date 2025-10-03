class Vendor {
  final int id;
  final String code;
  final String name;
  final String email;
  final String mobile;
  final String beneficiaryName;
  final String status;

  Vendor({
    required this.id,
    required this.code,
    required this.name,
    required this.email,
    required this.mobile,
    required this.beneficiaryName,
    required this.status,
  });

  Vendor copyWith({
    String? code,
    String? name,
    String? email,
    String? mobile,
    String? beneficiaryName,
    String? status,
  }) {
    return Vendor(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      status: status ?? this.status,
    );
  }
}
