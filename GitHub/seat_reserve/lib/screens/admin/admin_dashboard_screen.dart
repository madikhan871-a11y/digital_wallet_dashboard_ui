import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/reservation_model.dart';
import 'admin_settings_dialog.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const AdminDashboardScreen({super.key, required this.onNavigate});

  void _showSendNoticeDialog(BuildContext context, AppProvider provider) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Notice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Send this notification to all approved students.'),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final message = messageController.text.trim();
              if (title.isNotEmpty && message.isNotEmpty) {
                await provider.broadcastNotice(title, message);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notice broadcasted to all students.')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final occupancyPct = (provider.occupancyPercentage * 100).toInt();

    final hours = provider.timeUntilDeadline.inHours.toString().padLeft(2, '0');
    final minutes = (provider.timeUntilDeadline.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (provider.timeUntilDeadline.inSeconds % 60).toString().padLeft(2, '0');
    final countdownStr = '$hours:$minutes:$seconds';

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
              // Today's Occupancy Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Occupancy",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.group, color: AppTheme.onSurfaceVariant),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${provider.occupiedSeatsCount}',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ ${provider.activeSeatsCount} ACTIVE SEATS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: provider.occupancyPercentage,
                        minHeight: 8,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$occupancyPct% FULL',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.tertiaryFixedDim.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${provider.availableSeatsCount} AVAILABLE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats Summary Grid 1: Checked In & Expected
              Row(
                children: [
                  _buildStatCard(
                    context,
                    'Checked In',
                    '${provider.presentTodayCount}',
                    Icons.check_circle,
                    AppTheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    'Expected',
                    '${provider.expectedTodayCount}',
                    Icons.person_search,
                    AppTheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats Summary Grid 2: Absent & Unpaid Fines
              Row(
                children: [
                  _buildStatCard(
                    context,
                    'Absent',
                    '${provider.absentTodayCount}',
                    Icons.cancel,
                    AppTheme.error,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    'Unpaid Fines',
                    'Rs. ${provider.totalUnpaidFinesAmount.toStringAsFixed(0)}',
                    Icons.account_balance_wallet,
                    AppTheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pending Approvals & Deadline Cards Grid
              Row(
                children: [
                  // Pending Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onNavigate(1), // Navigate to approvals
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pending\nApprovals',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(Icons.mark_email_unread, color: Colors.white70),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${provider.pendingStudents.length}',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Deadline Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Booking\nDeadline',
                                style: TextStyle(
                                  color: AppTheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Icon(Icons.schedule, color: AppTheme.secondary),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            countdownStr,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          Text(
                            provider.settings.reservationDeadline.format(context),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const AdminSettingsDialog(),
                        );
                      },
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Settings'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () => _showSendNoticeDialog(context, provider),
                      icon: const Icon(Icons.campaign, size: 18),
                      label: const Text('Send Notice'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Attendance Management Section
              Text(
                "Today's Reservations",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (provider.todayReservations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("No reservations for today.", style: TextStyle(color: AppTheme.onSurfaceVariant)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.todayReservations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final res = provider.todayReservations[index];
                    return _buildAttendanceTile(context, provider, res);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.hankenGrotesk(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTile(BuildContext context, AppProvider provider, ReservationModel res) {
    final isCheckedIn = res.status == ReservationStatus.checked_in;
    final isAbsent = res.status == ReservationStatus.absent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
            child: Text(
                res.studentName?.isNotEmpty == true ? res.studentName![0].toUpperCase() : 'S',
                style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(res.studentName ?? 'Unknown Student', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(res.seatNumber, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Mark Checked In',
                icon: Icon(Icons.check_circle, color: isCheckedIn ? AppTheme.onTertiaryContainer : AppTheme.outlineVariant),
                onPressed: isCheckedIn || isAbsent ? null : () async {
                  await provider.markCheckedIn(res.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student marked as Checked In')),
                    );
                  }
                },
              ),
              IconButton(
                tooltip: 'Mark Absent',
                icon: Icon(Icons.cancel, color: isAbsent ? AppTheme.error : AppTheme.outlineVariant),
                onPressed: isCheckedIn || isAbsent ? null : () async {
                  await provider.markAbsent(res.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student marked as Absent. Fine generated.')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}