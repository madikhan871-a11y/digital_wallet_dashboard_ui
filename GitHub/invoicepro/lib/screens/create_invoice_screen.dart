import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data_provider.dart';
import '../models.dart';
import 'invoice_preview_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final Invoice? invoiceToEdit;
  const CreateInvoiceScreen({super.key, this.invoiceToEdit});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  late String _invoiceNumber;
  late DateTime _date;
  late String _dueDateOption;
  Customer? _selectedCustomer;
  final List<InvoiceItem> _items = [];
  final TextEditingController _customerSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.invoiceToEdit != null) {
      _invoiceNumber = widget.invoiceToEdit!.invoiceNumber;
      _date = widget.invoiceToEdit!.date;
      _dueDateOption = 'Custom Date...';
      _selectedCustomer = Provider.of<DataProvider>(context, listen: false).getCustomerById(widget.invoiceToEdit!.customerId);
      _items.addAll(widget.invoiceToEdit!.items);
    } else {
      _invoiceNumber = 'INV-2024-${(Provider.of<DataProvider>(context, listen: false).invoices.length + 1).toString().padLeft(3, '0')}';
      _date = DateTime.now();
      _dueDateOption = 'Net 30';
      _items.add(InvoiceItem(description: '', quantity: 1, price: 0.0));
    }
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get _tax => _subtotal * 0.1;
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBjQiSbK_apHR7ehjSyjUUzPhDEgAbCRxxeye2h7oXObm4yKB9pjvaCRWZ40mQa4tI997SdKTx-PJCcLesgEtmgl0eoD1QUtsoJT0BwteG4SSsVY8YKMsNoh1fwglvmoJDlBfwib7j4o0N3MtNgaDcCK5d70lSJWQoGnyjxPpRvfGob3Vj982Sj0dj-rwt3Mb_d1SHenntOneBM5osnTO6mnAd60gTOWmz60CIBsEyg1m3CjFGzQkLb',
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.receipt, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('Create Invoice', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAFzig4dGn9ssLgpl5MItn4QgaxaTglPY8rgGKND-8UIUFabQQiHAqTSm40lEJRX2yqTpF8Brpr3gge1xl-4GxVERTX3Jh_wLndSGiv-AHJyGBnkIDGGSJMSGlWZabfqWHIh7lkO-rAPz-hERDwc1BQeLN5EOyq5fp-W81xrGdv4SsI38Fqf3Sjphh0Nu_sFbmtCNvhEcUHC8G3no4CgK1qibaHR4cZktyBzCc4hsFxmH4zFZsY1sVQ',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('New Invoice', style: AppTheme.lightTheme.textTheme.headlineMedium),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.receipt_long,
              title: 'Invoice Details',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('Invoice #', _invoiceNumber, readOnly: true),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateField('Date', _date, (date) => setState(() => _date = date)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField('Due Date', _dueDateOption, ['Net 30', 'Net 15', 'Due on Receipt', 'Custom Date...'], (val) => setState(() => _dueDateOption = val!)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.person,
              title: 'Customer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedCustomer == null)
                    TextField(
                      controller: _customerSearchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                        hintText: 'Search or add new...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.outlineVariant)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        // In a real app, this would filter a list
                      },
                      onSubmitted: (val) {
                        final found = data.customers.where((c) => c.name.toLowerCase().contains(val.toLowerCase())).toList();
                        if (found.isNotEmpty) {
                          setState(() => _selectedCustomer = found.first);
                        }
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryFixed,
                            child: Text(_selectedCustomer!.name.substring(0, 2).toUpperCase(), style: const TextStyle(color: AppColors.onPrimaryFixed)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedCustomer!.name, style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                Text(_selectedCustomer!.email, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.secondary),
                            onPressed: () => setState(() => _selectedCustomer = null),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              icon: Icons.list_alt,
              title: 'Line Items',
              child: Column(
                children: [
                  ..._items.asMap().entries.map((entry) => _buildLineItem(entry.key, entry.value)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _items.add(InvoiceItem(description: '', quantity: 1, price: 0.0))),
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Add Line Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainer,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: ElevatedButton.icon(
          onPressed: _selectedCustomer != null && _items.isNotEmpty ? _previewInvoice : null,
          icon: const Icon(Icons.visibility),
          label: const Text('Save & Preview'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTheme.lightTheme.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 4),
        TextField(
          readOnly: readOnly,
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.outlineVariant)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (picked != null) onSelected(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text(DateFormat('yyyy-MM-dd').format(date)),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.secondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.outlineVariant)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildLineItem(int index, InvoiceItem item) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        _buildTextField('Item / Service', item.description),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 80,
              child: _buildTextField('Qty', item.quantity.toString()),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField('Price (\$)', item.price.toStringAsFixed(2)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.secondary),
              onPressed: () => setState(() => _items.removeAt(index)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Tax (10%)', '\$${_tax.toStringAsFixed(2)}'),
          _buildSummaryRow('Discount', '-\$0.00', isError: true),
          const Divider(height: 24),
          _buildSummaryRow('Total', '\$${_total.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isError = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: isTotal ? AppTheme.lightTheme.textTheme.headlineSmall : AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
          Text(
            value,
            style: isTotal
                ? AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(color: AppColors.primary)
                : AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: isError ? AppColors.error : AppColors.onSurface,
                    fontFamily: 'Courier', // Simulating data-mono
                  ),
          ),
        ],
      ),
    );
  }

  void _previewInvoice() {
    final invoice = Invoice(
      invoiceNumber: _invoiceNumber,
      date: _date,
      dueDate: _date.add(const Duration(days: 30)), // Simplified
      customerId: _selectedCustomer!.id,
      items: _items,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InvoicePreviewScreen(invoice: invoice)),
    );
  }
}
