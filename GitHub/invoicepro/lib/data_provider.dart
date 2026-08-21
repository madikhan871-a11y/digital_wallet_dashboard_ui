import 'package:flutter/material.dart';
import 'models.dart';

class DataProvider extends ChangeNotifier {
  final List<Customer> _customers = [
    Customer(
      name: 'Acme Corp',
      email: 'contact@acmecorp.com',
      phone: '+1 555-0101',
      address: '123 Business Way, Tech City, TC 12345',
    ),
    Customer(
      name: 'Globex Inc',
      email: 'info@globex.com',
      phone: '+1 555-0202',
      address: '456 Global Plaza, Metro City, MC 67890',
    ),
    Customer(
      name: 'Stark Ind',
      email: 'tony@stark.com',
      phone: '+1 555-0303',
      address: '888 Stark Tower, New York, NY 10001',
    ),
  ];

  final List<Invoice> _invoices = [];

  DataProvider() {
    // Add some initial dummy data
    _invoices.addAll([
      Invoice(
        invoiceNumber: 'INV-2023-089',
        date: DateTime(2023, 10, 25),
        dueDate: DateTime(2023, 11, 25),
        customerId: _customers[0].id,
        status: InvoiceStatus.paid,
        items: [
          InvoiceItem(description: 'Software Development', quantity: 1, price: 4500.0),
        ],
      ),
      Invoice(
        invoiceNumber: 'INV-2023-090',
        date: DateTime(2023, 10, 26),
        dueDate: DateTime(2023, 11, 26),
        customerId: _customers[1].id,
        status: InvoiceStatus.pending,
        items: [
          InvoiceItem(description: 'UI/UX Design', quantity: 1, price: 1250.50),
        ],
      ),
      Invoice(
        invoiceNumber: 'INV-2023-088',
        date: DateTime(2023, 10, 20),
        dueDate: DateTime(2023, 10, 27),
        customerId: _customers[2].id,
        status: InvoiceStatus.overdue,
        items: [
          InvoiceItem(description: 'Arc Reactor Maintenance', quantity: 1, price: 12000.0),
        ],
      ),
    ]);
  }

  List<Customer> get customers => List.unmodifiable(_customers);
  List<Invoice> get invoices => List.unmodifiable(_invoices);

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }

  void addInvoice(Invoice invoice) {
    _invoices.insert(0, invoice);
    notifyListeners();
  }

  void updateInvoice(Invoice invoice) {
    final index = _invoices.indexWhere((i) => i.id == invoice.id);
    if (index != -1) {
      _invoices[index] = invoice;
      notifyListeners();
    }
  }

  void deleteInvoice(String id) {
    _invoices.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  double get totalRevenue => _invoices.where((i) => i.status == InvoiceStatus.paid).fold(0, (sum, i) => sum + i.total);
  double get pendingAmount => _invoices.where((i) => i.status == InvoiceStatus.pending).fold(0, (sum, i) => sum + i.total);
  double get overdueAmount => _invoices.where((i) => i.status == InvoiceStatus.overdue).fold(0, (sum, i) => sum + i.total);
  int get totalInvoices => _invoices.length;
  int get pendingInvoicesCount => _invoices.where((i) => i.status == InvoiceStatus.pending).length;
}
