import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data_provider.dart';
import '../models.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final currencyFormat = NumberFormat.compactCurrency(symbol: '\$');

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
            Text('Customers', style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
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
            // Search Bar and Add Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search customers...',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Summary Stats
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard('Total Customers', data.customers.length.toString(), AppColors.primaryFixed.withOpacity(0.3), AppColors.primary),
                  const SizedBox(width: 8),
                  _buildStatCard('Active This Mo', '89', AppColors.tertiaryFixed.withOpacity(0.3), AppColors.tertiary),
                  const SizedBox(width: 8),
                  _buildStatCard('Avg LTV', '\$4.2k', AppColors.secondaryFixed.withOpacity(0.3), AppColors.secondary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Customer List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.customers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final customer = data.customers[index];
                return _buildCustomerCard(customer, currencyFormat);
              },
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {},
              icon: const Text('Load More'),
              label: const Icon(Icons.expand_more, size: 16),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.surfaceContainer,
                child: Text(customer.name.substring(0, 1), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(fontSize: 18)),
                    Text(customer.email, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invoices', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                  Text('12', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total Volume', style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                  Text('\$24,500.00', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
