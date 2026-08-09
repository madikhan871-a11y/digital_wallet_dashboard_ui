import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/reservation_model.dart';
import '../../models/fine_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    final allRes = provider.reservations;
    final allFines = provider.fines;

    // Filter reservations for the current logged-in student
    final studentRes = allRes.where((r) => r.studentId == user?.id).toList();

    // Sort by date descending
    studentRes.sort((a, b) => b.reservationDate.compareTo(a.reservationDate));

    // Distinguish between Upcoming (reserved or checked_in) and Past (absent or cancelled)
    final upcomingRes = studentRes.where((r) =>
    r.status == ReservationStatus.reserved ||
        r.status == ReservationStatus.checked_in
    ).toList();

    final pastRes = studentRes.where((r) =>
    r.status == ReservationStatus.absent ||
        r.status == ReservationStatus.cancelled
    ).toList();

    // Calculate unpaid fines balance
    final unpaidFines = allFines.where((f) => f.studentId == user?.id && f.status == FineStatus.unpaid).toList();
    final studentFinesHistory = allFines.where((f) => f.studentId == user?.id).toList();
    final totalFines = unpaidFines.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.secondary))
          : RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fines Alert Banner
              if (totalFines > 0) ...[
                _buildFinesBanner(context, totalFines, studentFinesHistory),
                const SizedBox(height: 20),
              ],

              // Upcoming Section
              _buildSectionHeader(context, 'Upcoming Reservations'),
              const SizedBox(height: 12),
              if (upcomingRes.isEmpty)
                _buildEmptyState('No active reservations found.')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingRes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildUpcomingCard(context, provider, upcomingRes[index]),
                ),

              const SizedBox(height: 24),

              // History Section
              _buildSectionHeader(context, 'Reservation History'),
              const SizedBox(height: 12),
              if (pastRes.isEmpty)
                _buildEmptyState('No previous history recorded.')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pastRes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildPastCard(context, pastRes[index]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.onSurface,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppTheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildFinesBanner(BuildContext context, double total, List<FineModel> finesHistory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.error.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.onErrorContainer, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unpaid Fines',
                  style: TextStyle(
                    color: AppTheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Missed reservation penalty',
                  style: TextStyle(
                    color: AppTheme.onErrorContainer,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${total.toStringAsFixed(0)}',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onErrorContainer,
                ),
              ),
              GestureDetector(
                onTap: () => _showFinesHistoryDialog(context, finesHistory),
                child: Text(
                  'HISTORY',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onErrorContainer,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, AppProvider provider, ReservationModel res) {
    final isToday = DateFormat('yyyy-MM-dd').format(res.reservationDate) == provider.todayDateString;
    final dateStr = isToday ? "TODAY" : DateFormat('EEEE, MMM d').format(res.reservationDate).toUpperCase();
    final isCheckedIn = res.status == ReservationStatus.checked_in;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: isCheckedIn ? AppTheme.checkedIn : AppTheme.secondary,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateStr,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCheckedIn ? AppTheme.checkedIn : AppTheme.secondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                res.seatNumber ?? 'Seat',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          StatusBadge(
                            label: isCheckedIn ? 'Checked In' : 'Reserved',
                            type: isCheckedIn ? BadgeType.checkedIn : BadgeType.reserved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCheckedIn ? Icons.check_circle_outline : Icons.schedule,
                                size: 16,
                                color: AppTheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isCheckedIn
                                    ? 'Presence marked at ${DateFormat.jm().format(res.checkInTime ?? DateTime.now())}'
                                    : 'Awaiting Check-in',
                                style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                          if (!isCheckedIn)
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _confirmCancellation(context, provider, res),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: AppTheme.error, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastCard(BuildContext context, ReservationModel res) {
    final isAbsent = res.status == ReservationStatus.absent;
    final isCancelled = res.status == ReservationStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: isAbsent ? const Border(left: BorderSide(color: AppTheme.error, width: 4)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(res.reservationDate),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                res.seatNumber ?? 'Unknown Seat',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          StatusBadge(
            label: isAbsent ? 'Absent' : (isCancelled ? 'Cancelled' : 'Attended'),
            type: isAbsent ? BadgeType.missed : (isCancelled ? BadgeType.available : BadgeType.checkedIn),
            icon: isAbsent ? Icons.cancel : (isCancelled ? Icons.close : Icons.check_circle),
          ),
        ],
      ),
    );
  }

  void _confirmCancellation(BuildContext context, AppProvider provider, ReservationModel res) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation?'),
        content: Text('Are you sure you want to cancel your reservation for ${res.seatNumber} on ${DateFormat('MMM d').format(res.reservationDate)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              final error = await provider.cancelReservation(res.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Reservation successfully cancelled.'),
                    backgroundColor: error != null ? AppTheme.error : null,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFinesHistoryDialog(BuildContext context, List<FineModel> fines) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          title: const Text('Fines & Penalties'),
          content: SizedBox(
            width: double.maxFinite,
            child: fines.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('You have no fines on record.', textAlign: TextAlign.center),
            )
                : Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: fines.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final fine = fines[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(fine.reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('MMM d, yyyy').format(fine.createdAt), style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        _buildFineStatusBadge(fine.status),
                      ],
                    ),
                    trailing: Text(
                      'Rs. ${fine.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fine.status == FineStatus.unpaid ? AppTheme.error : AppTheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFineStatusBadge(FineStatus status) {
    switch (status) {
      case FineStatus.unpaid:
        return const StatusBadge(label: 'Unpaid', type: BadgeType.missed);
      case FineStatus.paid:
        return const StatusBadge(label: 'Paid', type: BadgeType.checkedIn);
      case FineStatus.waived:
        return const StatusBadge(label: 'Waived', type: BadgeType.available);
    }
  }
}