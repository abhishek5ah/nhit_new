enum TransferType {
  unknown('TRANSFER_TYPE_UNKNOWN'),
  internal('INTERNAL'),
  external('EXTERNAL');

  final String value;
  const TransferType(this.value);

  static TransferType fromString(String value) {
    return TransferType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransferType.unknown,
    );
  }
}

enum TransferMode {
  unknown('TRANSFER_MODE_UNKNOWN'),
  oneToOne('ONE_TO_ONE'),
  oneToMany('ONE_TO_MANY'),
  manyToOne('MANY_TO_ONE'),
  manyToMany('MANY_TO_MANY');

  final String value;
  const TransferMode(this.value);

  static TransferMode fromString(String value) {
    return TransferMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => TransferMode.unknown,
    );
  }
}

enum TransferStatus {
  unknown('TRANSFER_STATUS_UNKNOWN'),
  pending('TRANSFER_STATUS_PENDING'),
  approved('TRANSFER_STATUS_APPROVED'),
  completed('TRANSFER_STATUS_COMPLETED'),
  rejected('TRANSFER_STATUS_REJECTED'),
  failed('TRANSFER_STATUS_FAILED'),
  cancelled('TRANSFER_STATUS_CANCELLED');

  final String value;
  const TransferStatus(this.value);

  static TransferStatus fromString(String value) {
    return TransferStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TransferStatus.unknown,
    );
  }
}
