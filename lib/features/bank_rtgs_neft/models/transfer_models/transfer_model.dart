import 'transfer_enums.dart';
import 'transfer_leg.dart';

class Transfer {
  final String transferId;
  final String transferReference;
  final TransferType transferType;
  final TransferMode transferMode;
  final double totalAmount;
  final String purpose;
  final String remarks;
  final TransferStatus status;
  final String requestedById;
  final String? approvedById;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final String? bankLetterReference;
  final String? bankLetterStatus;
  final DateTime? bankLetterGeneratedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TransferLeg> transferLegs;
  final SimpleUser? requestedBy;
  final SimpleUser? approver;
  final String? sourceAccountId;
  final String? sourceAccountName;
  final String? destinationAccountId;
  final String? destinationAccountName;

  Transfer({
    required this.transferId,
    required this.transferReference,
    required this.transferType,
    required this.transferMode,
    required this.totalAmount,
    required this.purpose,
    required this.remarks,
    required this.status,
    required this.requestedById,
    this.approvedById,
    this.approvedAt,
    this.completedAt,
    this.bankLetterReference,
    this.bankLetterStatus,
    this.bankLetterGeneratedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.transferLegs,
    this.requestedBy,
    this.approver,
    this.sourceAccountId,
    this.sourceAccountName,
    this.destinationAccountId,
    this.destinationAccountName,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      transferId: json['transferId'] as String,
      transferReference: json['transferReference'] as String,
      transferType: TransferType.fromString(json['transferType'] as String),
      transferMode: TransferMode.fromString(json['transferMode'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      purpose: json['purpose'] as String,
      remarks: json['remarks'] as String,
      status: TransferStatus.fromString(json['status'] as String),
      requestedById: json['requestedById'] as String,
      approvedById: (json['approvedById'] as String?)?.isEmpty ?? true ? null : json['approvedById'] as String?,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      bankLetterReference: (json['bankLetterReference'] as String?)?.isEmpty ?? true ? null : json['bankLetterReference'] as String?,
      bankLetterStatus: (json['bankLetterStatus'] as String?)?.isEmpty ?? true ? null : json['bankLetterStatus'] as String?,
      bankLetterGeneratedAt: json['bankLetterGeneratedAt'] != null ? DateTime.parse(json['bankLetterGeneratedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      transferLegs: (json['transferLegs'] as List<dynamic>?)?.map((e) => TransferLeg.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      requestedBy: json['requestedBy'] != null ? SimpleUser.fromJson(json['requestedBy'] as Map<String, dynamic>) : null,
      approver: json['approver'] != null ? SimpleUser.fromJson(json['approver'] as Map<String, dynamic>) : null,
      sourceAccountId: json['sourceAccountId'] as String?,
      sourceAccountName: json['sourceAccountName'] as String?,
      destinationAccountId: json['destinationAccountId'] as String?,
      destinationAccountName: json['destinationAccountName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'transferId': transferId,
    'transferReference': transferReference,
    'transferType': transferType.value,
    'transferMode': transferMode.value,
    'totalAmount': totalAmount,
    'purpose': purpose,
    'remarks': remarks,
    'status': status.value,
    'requestedById': requestedById,
    'approvedById': approvedById ?? '',
    'approvedAt': approvedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'bankLetterReference': bankLetterReference ?? '',
    'bankLetterStatus': bankLetterStatus ?? '',
    'bankLetterGeneratedAt': bankLetterGeneratedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'transferLegs': transferLegs.map((e) => e.toJson()).toList(),
    if (requestedBy != null) 'requestedBy': requestedBy!.toJson(),
    if (approver != null) 'approver': approver!.toJson(),
    if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
    if (sourceAccountName != null) 'sourceAccountName': sourceAccountName,
    if (destinationAccountId != null) 'destinationAccountId': destinationAccountId,
    if (destinationAccountName != null) 'destinationAccountName': destinationAccountName,
  };

  Transfer copyWith({
    String? transferId,
    String? transferReference,
    TransferType? transferType,
    TransferMode? transferMode,
    double? totalAmount,
    String? purpose,
    String? remarks,
    TransferStatus? status,
    String? requestedById,
    String? approvedById,
    DateTime? approvedAt,
    DateTime? completedAt,
    String? bankLetterReference,
    String? bankLetterStatus,
    DateTime? bankLetterGeneratedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TransferLeg>? transferLegs,
    SimpleUser? requestedBy,
    SimpleUser? approver,
    String? sourceAccountId,
    String? sourceAccountName,
    String? destinationAccountId,
    String? destinationAccountName,
  }) {
    return Transfer(
      transferId: transferId ?? this.transferId,
      transferReference: transferReference ?? this.transferReference,
      transferType: transferType ?? this.transferType,
      transferMode: transferMode ?? this.transferMode,
      totalAmount: totalAmount ?? this.totalAmount,
      purpose: purpose ?? this.purpose,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      requestedById: requestedById ?? this.requestedById,
      approvedById: approvedById ?? this.approvedById,
      approvedAt: approvedAt ?? this.approvedAt,
      completedAt: completedAt ?? this.completedAt,
      bankLetterReference: bankLetterReference ?? this.bankLetterReference,
      bankLetterStatus: bankLetterStatus ?? this.bankLetterStatus,
      bankLetterGeneratedAt: bankLetterGeneratedAt ?? this.bankLetterGeneratedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transferLegs: transferLegs ?? this.transferLegs,
      requestedBy: requestedBy ?? this.requestedBy,
      approver: approver ?? this.approver,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      sourceAccountName: sourceAccountName ?? this.sourceAccountName,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      destinationAccountName: destinationAccountName ?? this.destinationAccountName,
    );
  }

  String get displayText {
    if (transferLegs.isEmpty) return transferReference;

    final firstLeg = transferLegs.first;
    final sourceAccount = firstLeg.sourceAccount;
    final destinationText = firstLeg.destinationAccount?.accountName ?? firstLeg.destinationVendor?.name ?? 'Unknown';

    return '$transferReference - ${sourceAccount?.accountName ?? 'Unknown'} → $destinationText (₹$totalAmount)';
  }
}
