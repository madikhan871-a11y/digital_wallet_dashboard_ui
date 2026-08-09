import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/fine_model.dart';
import '../../widgets/status_badge.dart';

class FinesManagementScreen extends StatefulWidget {
  const FinesManagementScreen({super.key});

  @override
  State<FinesManagementScreen> createState() =>
      _FinesManagementScreenState();
}

class _FinesManagementScreenState
    extends State<FinesManagementScreen> {
  String _filterStatus = 'unpaid';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allFines = provider.fines;

    final filteredFines = allFines.where((f) {
      if (_filterStatus == 'all') return true;
      return f.status.name == _filterStatus;
    }).toList();

    return Scaffold(
      body: provider.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppTheme.secondary,
        ),
      )
          : RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fine Management',
                style:
                Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track and process no-show penalties.',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('unpaid', 'Unpaid'),
                    const SizedBox(width: 8),
                    _buildFilterChip('paid', 'Paid'),
                    const SizedBox(width: 8),
                    _buildFilterChip('waived', 'Waived'),
                    const SizedBox(width: 8),
                    _buildFilterChip('all', 'All'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (filteredFines.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  itemCount: filteredFines.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildFineCard(
                      context,
                      provider,
                      filteredFines[index],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _filterStatus == status;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _filterStatus = status;
        });
      },
      selectedColor:
      AppTheme.secondary.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.secondary,
      labelStyle: TextStyle(
        color: isSelected
            ? AppTheme.secondary
            : AppTheme.onSurfaceVariant,
        fontWeight:
        isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color:
              AppTheme.onSurfaceVariant.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              'No fines found for this category.',
              style: TextStyle(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFineCard(
      BuildContext context,
      AppProvider provider,
      FineModel fine,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
          AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      fine.studentName ?? 'Unknown Student',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy')
                          .format(fine.createdAt),
                      style: const TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${fine.amount.toStringAsFixed(0)}',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: fine.status == FineStatus.unpaid
                      ? AppTheme.error
                      : AppTheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            fine.reason,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(fine.status),

              if (fine.status == FineStatus.unpaid)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _confirmAction(
                        context,
                        'Waive',
                            () => provider.waiveFine(fine.id),
                      ),
                      child: const Text(
                        'Waive',
                        style: TextStyle(
                          color:
                          AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppTheme.onTertiaryContainer,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _confirmAction(
                        context,
                        'Mark as Paid',
                            () => provider.markFinePaid(fine.id),
                      ),
                      child: const Text('Mark Paid'),
                    ),
                  ],
                )
              else if (fine.status == FineStatus.paid &&
                  fine.paidAt != null)
                Text(
                  'Paid on ${DateFormat('MMM d').format(fine.paidAt!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                    AppTheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(FineStatus status) {
    switch (status) {
      case FineStatus.unpaid:
        return const StatusBadge(
          label: 'Unpaid',
          type: BadgeType.missed,
        );

      case FineStatus.paid:
        return const StatusBadge(
          label: 'Paid',
          type: BadgeType.checkedIn,
        );

      case FineStatus.waived:
        return const StatusBadge(
          label: 'Waived',
          type: BadgeType.available,
        );
    }
  }

  void _confirmAction(
      BuildContext context,
      String actionTitle,
      Future<void> Function() action,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$actionTitle Fine?'),
          content: Text(
            'Are you sure you want to ${actionTitle.toLowerCase()} this fine?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                await action();

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Fine ${actionTitle.toLowerCase()} successfully.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}