import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../models.dart';

class AddItemScreen extends StatefulWidget {
  final InvoiceItem? itemToEdit;
  const AddItemScreen({super.key, this.itemToEdit});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.itemToEdit?.description ?? '');
    _descriptionController = TextEditingController();
    _qtyController = TextEditingController(text: widget.itemToEdit?.quantity.toString() ?? '1');
    _priceController = TextEditingController(text: widget.itemToEdit?.price.toStringAsFixed(2) ?? '0.00');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _qty => double.tryParse(_qtyController.text) ?? 0;
  double get _price => double.tryParse(_priceController.text) ?? 0;
  double get _total => _qty * _price;

  @override
  Widget build(BuildContext context) {
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
            ),
            const SizedBox(width: 8),
            Text('Create Invoice', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Item', style: AppTheme.lightTheme.textTheme.headlineMedium),
            Text(
              'Enter details for the new line item to be added to the current invoice.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Item/Service Name'),
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('e.g., Logo Design, Consulting Hours'),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Description (Optional)'),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _inputDecoration('Provide additional details about the service or item...'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Quantity / Hrs'),
                            TextField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: _inputDecoration('0'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Unit Price (\$)'),
                            TextField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: _inputDecoration('0.00').copyWith(
                                prefixText: '\$ ',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Calculated Total', style: TextStyle(color: AppColors.onPrimaryContainer.withOpacity(0.8), fontSize: 12)),
                      Text('${_qty.toStringAsFixed(0)} × ${currencyFormat.format(_price)}', 
                          style: TextStyle(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Text(currencyFormat.format(_total), 
                      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(color: AppColors.onPrimaryContainer)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  final newItem = InvoiceItem(
                    description: _nameController.text,
                    quantity: _qty.toInt(),
                    price: _price,
                  );
                  Navigator.pop(context, newItem);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: AppTheme.lightTheme.textTheme.labelMedium),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
