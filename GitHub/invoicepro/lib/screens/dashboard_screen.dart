import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data_provider.dart';
import '../models.dart';
import 'create_invoice_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBjQiSbK_apHR7ehjSyjUUzPhDEgAbCRxxeye2h7oXObm4yKB9pjvaCRWZ40mQa4tI997SdKTx-PJCcLesgEtmgl0eoD1QUtsoJT0BwteG4SSsVY8YKMsNoh1fwglvmoJDlBfwib7j4o0N3MtNgaDcCK5d70lSJWQoGnyjxPpRvfGob3Vj982Sj0dj-rwt3Mb_d1SHenntOneBM5osnTO6mnAd60gTOWmz60CIBsEyg1m3CjFGzQkLb',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.receipt, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('Dashboard', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
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
            Text('Hello, Alex', style: AppTheme.lightTheme.textTheme.displayLarge),
            Text(
              DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: [
                _buildOverviewCard(
                  'Total',
                  data.totalInvoices.toString(),
                  '+12% this month',
                  Icons.receipt,
                  AppColors.primary,
                  AppColors.primaryContainer,
                ),
                _buildOverviewCard(
                  'Paid',
                  currencyFormat.format(data.totalRevenue),
                  '84% collection rate',
                  Icons.check_circle,
                  AppColors.tertiary,
                  AppColors.tertiaryContainer,
                ),
                _buildOverviewCard(
                  'Pending',
                  currencyFormat.format(data.pendingAmount),
                  '${data.pendingInvoicesCount} invoices',
                  Icons.schedule,
                  AppColors.secondary,
                  AppColors.secondaryContainer,
                ),
                _buildOverviewCard(
                  'Overdue',
                  currencyFormat.format(data.overdueAmount),
                  'Requires action',
                  Icons.warning,
                  AppColors.error,
                  AppColors.errorContainer,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildRevenueTrend(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('Recent Invoices', style: AppTheme.lightTheme.textTheme.headlineSmall),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Text('View All'),
                  label: const Icon(Icons.arrow_forward, size: 16),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.invoices.take(3).length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final invoice = data.invoices[index];
                final customer = data.getCustomerById(invoice.customerId);
                return _buildInvoiceItem(invoice, customer, currencyFormat);
              },
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, String subtitle, IconData icon, Color textColor, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(color: textColor == AppColors.primary ? AppColors.onSurface : textColor)),
          Text(subtitle, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildRevenueTrend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue Trend', style: AppTheme.lightTheme.textTheme.headlineSmall),
                  Text('Last 6 months', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
              Text('\$184k', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: ChartPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: const [
              Text('May', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text('Jun', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text('Jul', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text('Aug', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text('Sep', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              Text('Oct', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice, Customer? customer, NumberFormat format) {
    Color statusColor;
    switch (invoice.status) {
      case InvoiceStatus.paid:
        statusColor = AppColors.tertiary;
        break;
      case InvoiceStatus.pending:
        statusColor = AppColors.secondary;
        break;
      case InvoiceStatus.overdue:
        statusColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondaryContainer,
            child: Text(
              customer?.name.substring(0, 1) ?? '?',
              style: const TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.name ?? 'Unknown Customer',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(invoice.invoiceNumber, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(format.format(invoice.total), style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  invoice.status.name.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.2, size.height * 0.7,
      size.width * 0.3, size.height * 0.3,
      size.width * 0.4, size.height * 0.3,
    );
    path.cubicTo(
      size.width * 0.5, size.height * 0.3,
      size.width * 0.6, size.height * 0.6,
      size.width * 0.7, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.4,
      size.width * 0.9, size.height * 0.2,
      size.width, size.height * 0.1,
    );

    canvas.drawPath(path, paint);

    // Points
    final pointPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    void drawPoint(Offset offset) {
      canvas.drawCircle(offset, 4, pointPaint);
      canvas.drawCircle(offset, 4, borderPaint);
    }

    drawPoint(Offset(0, size.height * 0.8));
    drawPoint(Offset(size.width * 0.4, size.height * 0.3));
    drawPoint(Offset(size.width * 0.7, size.height * 0.5));
    drawPoint(Offset(size.width, size.height * 0.1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
