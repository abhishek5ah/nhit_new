class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final List<String> roles;
  final bool isActive;

  // Optional fields
  final String? designation;
  final String? department;
  final String? signatureUrl;
  final String? employeeId;
  final String? contactNumber;
  final String? accountHolder;
  final String? bankName;
  final String? bankAccount;
  final String? ifsc;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.roles,
    required this.isActive,
    this.designation,
    this.department,
    this.signatureUrl,
    this.employeeId,
    this.contactNumber,
    this.accountHolder,
    this.bankName,
    this.bankAccount,
    this.ifsc,
  });

  User copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    List<String>? roles,
    bool? isActive,
    String? designation,
    String? department,
    String? signatureUrl,
    String? employeeId,
    String? contactNumber,
    String? accountHolder,
    String? bankName,
    String? bankAccount,
    String? ifsc,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      roles: roles ?? List<String>.from(this.roles),
      isActive: isActive ?? this.isActive,
      designation: designation ?? this.designation,
      department: department ?? this.department,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      employeeId: employeeId ?? this.employeeId,
      contactNumber: contactNumber ?? this.contactNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      ifsc: ifsc ?? this.ifsc,
    );
  }
}
