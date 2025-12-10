import 'transfer_enums.dart';
import 'transfer_model.dart';

// Helper for Create Request - matches protobuf TransferSourceInput
class TransferSourceInput {
  final String sourceAccountId;
  final double amount;

  TransferSourceInput({
    required this.sourceAccountId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    'source_account_id': sourceAccountId,
    'amount': amount,
  };
}

// Helper for Create Request - matches protobuf TransferDestinationInput
class TransferDestinationInput {
  // Must provide one of the following
  final String? destinationAccountId; // For INTERNAL
  final String? destinationVendorId;  // For EXTERNAL
  final double amount;

  TransferDestinationInput({
    this.destinationAccountId,
    this.destinationVendorId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
    if (destinationAccountId != null) 'destination_account_id': destinationAccountId,
    if (destinationVendorId != null) 'destination_vendor_id': destinationVendorId,
    'amount': amount,
  };
}

// Matches protobuf message CreateAccountTransferRequest
class CreateAccountTransferRequest {
  final TransferType transferType;        // transfer_type = 1
  final TransferMode transferMode;        // transfer_mode = 2
  final String purpose;                   // purpose = 3
  final String remarks;                   // remarks = 4
  final String requestedById;             // requested_by_id = 5
  final List<TransferSourceInput> sources;      // repeated sources = 6
  final List<TransferDestinationInput> destinations; // repeated destinations = 7

  CreateAccountTransferRequest({
    required this.transferType,
    required this.transferMode,
    required this.purpose,
    required this.remarks,
    required this.requestedById,
    required this.sources,
    required this.destinations,
  });

  Map<String, dynamic> toJson() => {
    'transfer_type': transferType.value,
    'transfer_mode': transferMode.value,
    'purpose': purpose,
    'remarks': remarks,
    'requested_by_id': requestedById,
    'sources': sources.map((s) => s.toJson()).toList(),
    'destinations': destinations.map((d) => d.toJson()).toList(),
  };

  bool validate() {
    if (sources.isEmpty || destinations.isEmpty) {
      throw ValidationException('At least one source and destination required');
    }

    final sourceTotal = sources.fold<double>(0, (sum, s) => sum + s.amount);
    final destTotal = destinations.fold<double>(0, (sum, d) => sum + d.amount);

    if (sourceTotal != destTotal) {
      throw ValidationException('Source total (₹$sourceTotal) must equal destination total (₹$destTotal)');
    }

    for (var source in sources) {
      if (source.amount <= 0) {
        throw ValidationException('Source amounts must be greater than 0');
      }
    }

    for (var dest in destinations) {
      if (dest.amount <= 0) {
        throw ValidationException('Destination amounts must be greater than 0');
      }

      if (transferType == TransferType.internal && dest.destinationAccountId == null) {
        throw ValidationException('Internal transfers require destination account IDs');
      }

      if (transferType == TransferType.external && dest.destinationVendorId == null) {
        throw ValidationException('External transfers require destination vendor IDs');
      }
    }

    return true;
  }
}

// Matches protobuf message AccountTransferResponse
class AccountTransferResponse {
  final Transfer transfer;

  AccountTransferResponse({
    required this.transfer,
  });

  factory AccountTransferResponse.fromJson(Map<String, dynamic> json) {
    return AccountTransferResponse(
      transfer: Transfer.fromJson(json['transfer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'transfer': transfer.toJson(),
  };
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}
