import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/seat_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class StudentBookingScreen extends StatefulWidget {
  const StudentBookingScreen({super.key});

  @override
  State<StudentBookingScreen> createState() => _StudentBookingScreenState();
}

class _StudentBookingScreenState extends State<StudentBookingScreen> {
  String _selectedZone = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;
    final isLocked = provider.isPastDeadline;
    final hasReserved = provider.hasUserReservedToday;

    // Handle student account status notices (Fallback routing/Reactive UI)
    if (user?.status == UserStatus.pending) {
      return _buildNotice(
        context,
        Icons.hourglass_empty_rounded,
        'Account Pending Admin Approval',
        'Your registration has been submitted successfully. Please wait for an administrator to approve your account before you can start reserving seats.',
      );
    } else if (user?.status == UserStatus.rejected) {
      return _buildNotice(
        context,
        Icons.block_rounded,
        'Account Rejected',
        'Your account registration has been rejected by the administrator. Please contact the office for more information.',
      );
    }

    final seats = provider.seats;
    final todayRes = provider.todayReservations;
    final reservedSeatIds = todayRes.map((r) => r.seatId).toSet();

    // Extract dynamic zones from seats list
    final dynamicZones = seats.map((s) => s.zone).where((z) => z.isNotEmpty).toSet().toList();
    final zones = ['All', ...dynamicZones];

    final filteredSeats = _selectedZone == 'All'
        ? seats.where((s) => s.isActive).toList()
        : seats.where((s) => s.isActive && s.zone == _selectedZone).toList();

    return RefreshIndicator(
      color: AppTheme.secondary,
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deadline Countdown Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasReserved
                    ? AppTheme.surfaceContainerHigh
                    : (isLocked ? AppTheme.errorContainer : AppTheme.surfaceContainerHigh),
                borderRadius: BorderRadius.circular(16),
                border: hasReserved ? Border.all(color: AppTheme.secondary, width: 2) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    hasReserved ? Icons.check_circle_rounded : (isLocked ? Icons.lock_clock_rounded : Icons.timer_rounded),
                    color: hasReserved ? AppTheme.secondary : (isLocked ? AppTheme.error : AppTheme.secondary),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasReserved
                              ? 'You have a seat reserved today!'
                              : (isLocked ? 'Daily Booking Deadline Passed' : 'Reserve Before ${provider.settings.reservationDeadline.format(context)}'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLocked && !hasReserved ? AppTheme.error : AppTheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasReserved
                              ? 'Your reservation is active. Check "My Seats" for details.'
                              : (isLocked
                              ? 'The daily deadline has been reached for today.'
                              : 'Seats must be reserved daily before the system deadline.'),
                          style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Area Selection Header
            Text(
              'Select Seat Area',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            // Area Selection Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: zones.map((zone) {
                  final isSelected = _selectedZone == zone;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(zone),
                      selected: isSelected,
                      selectedColor: AppTheme.secondaryContainer,
                      checkmarkColor: AppTheme.secondary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.secondary : AppTheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (val) {
                        setState(() => _selectedZone = zone);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Seats Grid or Empty State
            provider.isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: AppTheme.secondary),
              ),
            )
                : filteredSeats.isEmpty
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: const Center(
                child: Text(
                  'No available seats found in this zone.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredSeats.length,
              itemBuilder: (context, index) {
                final seat = filteredSeats[index];
                final isBookedToday = reservedSeatIds.contains(seat.id);

                return _buildSeatCard(
                    context,
                    provider,
                    seat,
                    isBookedToday,
                    isLocked || hasReserved
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatCard(
      BuildContext context,
      AppProvider provider,
      SeatModel seat,
      bool isBooked,
      bool disableBooking
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBooked ? AppTheme.surfaceContainer : AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBooked ? AppTheme.outlineVariant : AppTheme.secondary.withValues(alpha: 0.3),
          width: isBooked ? 1 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                seat.seatNumber,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
              StatusBadge(
                label: isBooked ? 'Taken' : 'Available',
                type: isBooked ? BadgeType.reserved : BadgeType.available,
              ),
            ],
          ),
          Text(
            seat.zone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
          ),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBooked || disableBooking ? AppTheme.surfaceVariant : AppTheme.secondary,
                foregroundColor: isBooked || disableBooking ? AppTheme.onSurfaceVariant : Colors.white,
                padding: EdgeInsets.zero,
                elevation: isBooked || disableBooking ? 0 : 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isBooked || disableBooking
                  ? null
                  : () => _showConfirmDialog(context, provider, seat),
              child: Text(
                isBooked
                    ? 'Occupied'
                    : disableBooking
                    ? 'Locked'
                    : 'Reserve',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, AppProvider provider, SeatModel seat) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceContainerLowest,
          title: Text('Reserve ${seat.seatNumber}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location: ${seat.zone}', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text('Deadline to Check-in: ${provider.settings.attendanceCutoff.format(dialogContext)}'),
              const SizedBox(height: 12),
              Text(
                'Notice: Failure to show up without cancelling will result in a fine of Rs. ${provider.settings.noShowFine.toStringAsFixed(0)} automatically.',
                style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog first to avoid multi-clicks
                final error = await provider.reserveSeat(seat);

                if (context.mounted) {
                  if (error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${seat.seatNumber} reserved successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: AppTheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotice(BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                icon,
                size: 80,
                color: icon == Icons.block_rounded ? AppTheme.error : AppTheme.secondary
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Provider.of<AppProvider>(context, listen: false).logout(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}