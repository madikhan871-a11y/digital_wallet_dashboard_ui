import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/reservation_model.dart';
import '../../models/fine_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

class OccupancyReportScreen extends StatefulWidget {
  const OccupancyReportScreen({super.key});

  @override
  State<OccupancyReportScreen> createState() => _OccupancyReportScreenState();
}

class _OccupancyReportScreenState extends State<OccupancyReportScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.secondary,
              onPrimary: Colors.white,
              onSurface: AppTheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final isToday = dateStr == provider.todayDateString;

    // Filter reservations for the selected date
    final dateReservations = provider.reservations.where((r) =>
    DateFormat('yyyy-MM-dd').format(r.reservationDate) == dateStr
    ).toList();

    // Metric Calculations (Real Supabase Data)
    final activeSeats = provider.activeSeatsCount;
    final expectedCount = dateReservations.where((r) => r.status != ReservationStatus.cancelled).length;
    final checkedInCount = dateReservations.where((r) => r.status == ReservationStatus.checked_in).length;
    final absentCount = dateReservations.where((r) => r.status == ReservationStatus.absent).length;
    final cancelledCount = dateReservations.where((r) => r.status == ReservationStatus.cancelled).length;

    // Reserved = Reserved + Checked In
    final currentlyReserved = dateReservations.where((r) =>
    r.status == ReservationStatus.reserved || r.status == ReservationStatus.checked_in
    ).length;

    final availableCount = (activeSeats - currentlyReserved).clamp(0, activeSeats);
    final occupancyPct = activeSeats == 0 ? 0.0 : (currentlyReserved / activeSeats);

    // Fine Calculations for the selected date
    final dateResIds = dateReservations.map((r) => r.id).toSet();
    final dateFines = provider.fines.where((f) => dateResIds.contains(f.reservationId)).toList();
    final totalFinesAmount = dateFines.fold(0.0, (sum, f) => sum + f.amount);
    final unpaidFinesAmount = dateFines.where((f) => f.status == FineStatus.unpaid).fold(0.0, (sum, f) => sum + f.amount);

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
              // Header with Date Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? "Today's Report" : "Daily Report",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  IconButton.filledTonal(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.event_note),
                    style: IconButton.styleFrom(foregroundColor: AppTheme.secondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Key Performance Indicator Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAILY SEAT OCCUPANCY',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 12,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$currentlyReserved',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '/ $activeSeats ACTIVE',
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 18,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        _buildCircularChart(occupancyPct),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusIndicator(AppTheme.tertiaryFixedDim, '$availableCount Available'),
                        _buildStatusIndicator(AppTheme.secondaryFixedDim, '$checkedInCount Checked In'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Metrics Grid
              _buildLabel('Statistical Breakdown'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildMetricTile('Expected', '$expectedCount', Icons.people_outline, AppTheme.secondary),
                  _buildMetricTile('Absent', '$absentCount', Icons.person_off_outlined, AppTheme.error),
                  _buildMetricTile('Cancelled', '$cancelledCount', Icons.cancel_outlined, AppTheme.onSurfaceVariant),
                  _buildMetricTile('Total Fines', 'Rs. ${totalFinesAmount.toStringAsFixed(0)}', Icons.receipt_long, AppTheme.error),
                  _buildMetricTile('Unpaid Fines', 'Rs. ${unpaidFinesAmount.toStringAsFixed(0)}', Icons.pending_actions, AppTheme.error),
                ],
              ),

              const SizedBox(height: 24),

              // Detailed Roster
              _buildLabel("Roster Details"),
              const SizedBox(height: 12),

              if (dateReservations.isEmpty)
                _buildNoDataState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dateReservations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildStudentTile(context, provider, dateReservations[index], isToday),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularChart(double pct) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: pct,
            strokeWidth: 7,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.tertiaryFixedDim),
          ),
        ),
        Text(
          '${(pct * 100).toInt()}%',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildStatusIndicator(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text('No reservation data recorded for this date.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
      ),
    );
  }

  Widget _buildStudentTile(BuildContext context, AppProvider provider, ReservationModel res, bool isToday) {
    final isCheckedIn = res.status == ReservationStatus.checked_in;
    final isAbsent = res.status == ReservationStatus.absent;
    final isCancelled = res.status == ReservationStatus.cancelled;

    Color statusColor = AppTheme.secondary;
    if (isCheckedIn) statusColor = AppTheme.onTertiaryContainer;
    if (isAbsent) statusColor = AppTheme.error;
    if (isCancelled) statusColor = AppTheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                          child: Text(
                            res.studentName?.isNotEmpty == true ? res.studentName![0].toUpperCase() : 'S',
                            style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(res.studentName ?? 'Unknown Student', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(res.seatNumber ?? 'No Seat', style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        _buildStatusBadge(res.status),
                      ],
                    ),
                    if (isToday && !isCancelled) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isCheckedIn && !isAbsent) ...[
                            TextButton.icon(
                              onPressed: () async {
                                await provider.markCheckedIn(res.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Marked as Checked In')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_circle_outline, size: 18),
                              label: const Text('Check In'),
                              style: TextButton.styleFrom(foregroundColor: AppTheme.onTertiaryContainer),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () async {
                                await provider.markAbsent(res.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Marked as Absent & fine applied')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Mark Absent'),
                              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                            ),
                          ] else if (isCheckedIn)
                            const Text('Attendance Marked', style: TextStyle(color: AppTheme.onTertiaryContainer, fontStyle: FontStyle.italic, fontSize: 13))
                          else if (isAbsent)
                              const Text('Student Absent (Fine Levied)', style: TextStyle(color: AppTheme.error, fontStyle: FontStyle.italic, fontSize: 13)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.reserved:
        return const StatusBadge(
          label: 'Reserved',
          type: BadgeType.reserved,
        );

      case ReservationStatus.checked_in:
        return const StatusBadge(
          label: 'Checked In',
          type: BadgeType.checkedIn,
        );

      case ReservationStatus.absent:
        return const StatusBadge(
          label: 'Absent',
          type: BadgeType.missed,
        );

      case ReservationStatus.missed:
        return const StatusBadge(
          label: 'Missed',
          type: BadgeType.missed,
        );

      case ReservationStatus.cancelled:
        return const StatusBadge(
          label: 'Cancelled',
          type: BadgeType.available,
        );
    }
  }
}