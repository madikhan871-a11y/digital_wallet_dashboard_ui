import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/app_settings_model.dart';

class AdminSettingsDialog extends StatefulWidget {
  const AdminSettingsDialog({super.key});

  @override
  State<AdminSettingsDialog> createState() =>
      _AdminSettingsDialogState();
}

class _AdminSettingsDialogState extends State<AdminSettingsDialog> {
  late TextEditingController _seatsController;
  late TextEditingController _fineController;

  late TimeOfDay _reservationDeadline;
  late TimeOfDay _attendanceCutoff;
  late TimeOfDay _cancellationDeadline;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(
      context,
      listen: false,
    );

    final settings = provider.settings;

    _seatsController = TextEditingController(
      text: settings.totalSeats.toString(),
    );

    _fineController = TextEditingController(
      text: settings.noShowFine.toStringAsFixed(0),
    );

    _reservationDeadline = settings.reservationDeadline;
    _attendanceCutoff = settings.attendanceCutoff;
    _cancellationDeadline = settings.cancellationDeadline;
  }

  @override
  void dispose() {
    _seatsController.dispose();
    _fineController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(
      BuildContext context,
      String label,
      TimeOfDay initial,
      Function(TimeOfDay) onPicked,
      ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'SELECT $label',
    );

    if (picked != null && mounted) {
      setState(() {
        onPicked(picked);
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final provider = Provider.of<AppProvider>(
      context,
      listen: false,
    );

    try {
      final seats = int.tryParse(
        _seatsController.text.trim(),
      ) ??
          provider.settings.totalSeats;

      final fine = double.tryParse(
        _fineController.text.trim(),
      ) ??
          provider.settings.noShowFine;

      final newSettings = AppSettingsModel(
        totalSeats: seats,
        noShowFine: fine,
        reservationDeadline: _reservationDeadline,
        cancellationDeadline: _cancellationDeadline,
        attendanceCutoff: _attendanceCutoff,
      );

      final error = await provider.updateSettings(newSettings);

      if (!mounted) return;

      if (error == null) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Settings updated successfully.',
            ),
            backgroundColor: AppTheme.onTertiaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save settings:\n$error',
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save settings:\n$e',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceContainerLowest,

      title: const Text(
        'System Settings',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Inventory'),

              _buildTextField(
                _seatsController,
                'Total Active Seats',
                'e.g. 20',
                Icons.event_seat,
              ),

              const SizedBox(height: 16),

              _buildSectionTitle('Deadlines'),

              _buildTimeTile(
                'Reservation Deadline',
                _reservationDeadline,
                    (time) {
                  _reservationDeadline = time;
                },
              ),

              _buildTimeTile(
                'Cancellation Deadline',
                _cancellationDeadline,
                    (time) {
                  _cancellationDeadline = time;
                },
              ),

              _buildTimeTile(
                'Attendance Cutoff',
                _attendanceCutoff,
                    (time) {
                  _attendanceCutoff = time;
                },
              ),

              const SizedBox(height: 16),

              _buildSectionTitle('Penalties'),

              _buildTextField(
                _fineController,
                'No-Show Fine (Rs.)',
                'e.g. 200',
                Icons.payments_outlined,
              ),

              const SizedBox(height: 12),

              const Text(
                'Note: These changes take effect immediately for all users.',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          onPressed: _isSaving ? null : _saveSettings,

          child: _isSaving
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'Apply Changes',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTile(
      String label,
      TimeOfDay time,
      Function(TimeOfDay) onPicked,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _pickTime(
          context,
          label.toUpperCase(),
          time,
          onPicked,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  Text(
                    time.format(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.schedule,
                    size: 18,
                    color: AppTheme.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}