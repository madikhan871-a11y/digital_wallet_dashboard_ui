import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../theme.dart';
import '../data_provider.dart';
import '../models.dart';
import '../pdf_service.dart';

class InvoicePreviewScreen extends StatelessWidget {
  final Invoice invoice;
  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final customer = data.getCustomerById(invoice.customerId);
    final business = data.businessProfile;
    final currencyFormat = NumberFormat.currency(symbol: business.currencySymbol);
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (customer == null) {
      return const Scaffold(body: Center(child: Text('Customer not found')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.network(
              business.logoUrl,
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.receipt, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('Invoice Details', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
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
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(business.logoUrl, height: 48, errorBuilder: (context, error, stackTrace) => const SizedBox(height: 48)),
                          const SizedBox(height: 12),
                          Text(business.name, style: AppTheme.lightTheme.textTheme.headlineSmall),
                          Text(business.address, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('INVOICE', style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(color: AppColors.primary, fontSize: 24)),
                          const SizedBox(height: 8),
                          Text('Invoice #', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                          Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                            child: Text(invoice.status.name.toUpperCase(), style: AppTheme.lightTheme.textTheme.labelMedium),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BILLED TO', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(customer.address, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('DATE ISSUED', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                          Text(dateFormat.format(invoice.date)),
                          const SizedBox(height: 12),
                          Text('DUE DATE', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                          Text(dateFormat.format(invoice.dueDate)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Expanded(child: Text('DESCRIPTION', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant))),
                        SizedBox(width: 60, child: Text('QTY', textAlign: pw.TextAlign.right.toEdgeInsets() == null ? null : null, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant))),
                        SizedBox(width: 100, child: Text('AMOUNT', textAlign: TextAlign.right, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...invoice.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            SizedBox(width: 60, child: Text('${item.quantity}', textAlign: TextAlign.right)),
                            SizedBox(width: 100, child: Text(currencyFormat.format(item.total), textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w500))),
                          ],
                        ),
                      )),
                  const Divider(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', currencyFormat.format(invoice.subtotal)),
                          _buildSummaryRow('Tax (${(invoice.taxRate * 100).toStringAsFixed(0)}%)', currencyFormat.format(invoice.taxAmount)),
                          if (invoice.discount > 0) _buildSummaryRow('Discount', '-${currencyFormat.format(invoice.discount)}', isError: true),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Text('Total', style: AppTheme.lightTheme.textTheme.headlineSmall),
                              Text(currencyFormat.format(invoice.total), style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Payment is due within 30 days. Thank you for your business.',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
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
        child: Row(
          children: [
            IconButton(
              icon: const Column(children: [Icon(Icons.print), Text('Print', style: TextStyle(fontSize: 10))]),
              onPressed: () async {
                final pdf = await PdfService.generateInvoicePdf(invoice, customer, business);
                await Printing.layoutPdf(onLayout: (format) => pdf);
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Column(children: [Icon(Icons.share), Text('Share', style: TextStyle(fontSize: 10))]),
              onPressed: () async {
                final pdf = await PdfService.generateInvoicePdf(invoice, customer, business);
                await Printing.sharePdf(bytes: pdf, filename: '${invoice.invoiceNumber}.pdf');
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final pdf = await PdfService.generateInvoicePdf(invoice, customer, business);
                  await Printing.layoutPdf(onLayout: (format) => pdf);
                  // Saving to DataProvider if it's new
                  if (!data.invoices.any((i) => i.id == invoice.id)) {
                    data.addInvoice(invoice);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice saved successfully!')));
                },
                icon: const Icon(Icons.download),
                label: const Text('Download PDF & Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          Text(value, style: TextStyle(color: isError ? AppColors.error : AppColors.onSurface, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
