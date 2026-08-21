import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data_provider.dart';
import '../models.dart';
import 'invoice_preview_screen.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;
  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final customerInvoices = data.invoices.where((i) => i.customerId == customer.id).toList();
    final totalBilled = customerInvoices.fold(0.0, (sum, i) => sum + i.total);
    final pendingAmount = customerInvoices.where((i) => i.status == InvoiceStatus.pending || i.status == InvoiceStatus.overdue).fold(0.0, (sum, i) => sum + i.total);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

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
            Text('Customer Profile', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB0I1cCQUNdACTRLw0Ml6T00-goOxGVqFiRgOmGhAw8xS48dyIry1XjLhaSf9a8-KogfxjGwnLCxwZF0SHkQ9rZu7YM6FhZdoy5r8IvLEEzA9EJbgmRPg1v0BNDteyDqpt9JzenRppo6VA9nFWlHJc33KbDuQfnY7osnzUPQBRcYyuarr3EShrBK_-KEgPb-0CdcI4wi5OHTbG34eS_iH-1dC16LRRbLEJLU8X_dX53cPJFzHuz-oQj'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(customer.name, style: AppTheme.lightTheme.textTheme.headlineMedium),
                            Row(
                              children: [
                                const Icon(Icons.business, size: 16, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text('Tech Solutions', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildContactItem(Icons.mail, customer.email),
                  _buildContactItem(Icons.phone, customer.phone),
                  _buildContactItem(Icons.location_on, customer.address),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.mail, size: 18),
                          label: const Text('Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryFixed,
                            foregroundColor: AppColors.onPrimaryFixed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.edit, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Billed', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(currencyFormat.format(totalBilled), style: AppTheme.lightTheme.textTheme.headlineMedium),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.trending_up, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('+12% YTD', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildMiniStat('Pending', currencyFormat.format(pendingAmount), Icons.schedule, AppColors.error),
                      const SizedBox(height: 16),
                      _buildMiniStat('Avg. Pay Time', '14 Days', Icons.speed, AppColors.onSurface),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Invoice History
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('Invoice History', style: AppTheme.lightTheme.textTheme.headlineSmall),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Text('Filter'),
                  label: const Icon(Icons.filter_list, size: 16),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customerInvoices.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final invoice = customerInvoices[index];
                  return _buildHistoryItem(context, invoice, currencyFormat);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLowest,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
              child: const Text('View All Invoices'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTheme.lightTheme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: label == 'Pending' ? AppColors.errorContainer : AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: label == 'Pending' ? AppColors.error : AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Invoice invoice, NumberFormat format) {
    Color statusColor;
    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusColor = AppColors.primary;
        break;
      case InvoiceStatus.overdue:
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.onSurface;
    }

    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => InvoicePreviewScreen(invoice: invoice)));
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(invoice.invoiceNumber, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: invoice.status == InvoiceStatus.paid ? AppColors.primaryFixed : (invoice.status == InvoiceStatus.overdue ? AppColors.errorContainer : AppColors.surfaceContainerHigh),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  invoice.status.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(invoice.items.isNotEmpty ? invoice.items[0].description : 'Invoice', style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Text(
              invoice.status == InvoiceStatus.overdue 
                ? 'Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}' 
                : DateFormat('MMM dd, yyyy').format(invoice.date),
              style: TextStyle(color: invoice.status == InvoiceStatus.overdue ? AppColors.error : AppColors.onSurfaceVariant),
            ),
            Text(format.format(invoice.total), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.secondary, size: 20),
    );
  }
}
