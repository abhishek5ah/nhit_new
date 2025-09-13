class Party {
  final String name, address, gstin, email, phone;

  Party({
    required this.name,
    required this.address,
    required this.gstin,
    required this.email,
    required this.phone,
  });
}

class InvoiceItem {
  final String name, hsn;
  final int quantity;
  final double price, gst, total;

  InvoiceItem({
    required this.name,
    required this.hsn,
    required this.quantity,
    required this.price,
    required this.gst,
    required this.total,
  });
}

class InvoiceTotals {
  final double subtotal, cgst, sgst, total;
  final int cgstPercent, sgstPercent;

  InvoiceTotals({
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.cgstPercent,
    required this.sgstPercent,
    required this.total,
  });
}

class Invoice {
  final Party sender, recipient;
  final String number;
  final DateTime date, dueDate;
  final List<InvoiceItem> items;
  final InvoiceTotals totals;

  Invoice({
    required this.sender,
    required this.recipient,
    required this.number,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.totals,
  });
}
