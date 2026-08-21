import 'package:uuid/uuid.dart';

enum InvoiceStatus { paid, pending, overdue }

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  Customer({
    String? id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  }) : id = id ?? const Uuid().v4();

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double price;

  InvoiceItem({
    String? id,
    required this.description,
    required this.quantity,
    required this.price,
  }) : id = id ?? const Uuid().v4();

  double get total => quantity * price;

  InvoiceItem copyWith({
    String? description,
    int? quantity,
    double? price,
  }) {
    return InvoiceItem(
      id: id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final DateTime dueDate;
  final String customerId;
  final List<InvoiceItem> items;
  final InvoiceStatus status;

  Invoice({
    String? id,
    required this.invoiceNumber,
    required this.date,
    required this.dueDate,
    required this.customerId,
    required this.items,
    this.status = InvoiceStatus.pending,
  }) : id = id ?? const Uuid().v4();

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.1; // Default 10% tax
  double get total => subtotal + tax;

  Invoice copyWith({
    String? invoiceNumber,
    DateTime? date,
    DateTime? dueDate,
    String? customerId,
    List<InvoiceItem>? items,
    InvoiceStatus? status,
  }) {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }
}
