import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/maintenance.dart';
import '../widgets/expense_card.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const upcomingTasks = [
    Maintenance(
      title: 'Air Conditioner Service',
      location: 'Living Room',
      date: 'Aug 24',
      cost: 'Rs. 2,500',
      type: 'ac',
    ),
    Maintenance(
      title: 'Water Tank Cleaning',
      location: 'Roof',
      date: 'Aug 28',
      cost: 'Rs. 1,800',
      type: 'water',
    ),
  ];

  static const recentTasks = [
    Maintenance(
      title: 'Electrical Repair',
      location: 'Kitchen',
      date: 'Aug 18',
      cost: 'Rs. 3,200',
      type: 'electric',
      urgent: true,
    ),
    Maintenance(
      title: 'Deep Cleaning',
      location: 'Bedroom',
      date: 'Aug 15',
      cost: 'Rs. 1,500',
      type: 'cleaning',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            100,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildHomeCard(),
            const SizedBox(height: 20),
            _buildSummary(),
            const SizedBox(height: 25),
            const SectionTitle(
              title: 'Upcoming Maintenance',
            ),
            const SizedBox(height: 12),
            ...upcomingTasks.map(
                  (task) => MaintenanceCard(item: task),
            ),
            const SizedBox(height: 12),
            const ExpenseCard(),
            const SizedBox(height: 25),
            const SectionTitle(
              title: 'Recent Repairs',
            ),
            const SizedBox(height: 12),
            ...recentTasks.map(
                  (task) => MaintenanceCard(item: task),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTask(context);
        },
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Home Maintenance',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.darkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'MY HOME',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Green Valley House',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '4 Rooms  •  2 Floors',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.build_outlined,
            title: 'Due Soon',
            value: '04',
            color: AppColors.orange,
            background: AppColors.lightOrange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.warning_amber_rounded,
            title: 'Urgent',
            value: '01',
            color: AppColors.red,
            background: AppColors.lightRed,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.check_circle_outline_rounded,
            title: 'Completed',
            value: '12',
            color: AppColors.green,
            background: AppColors.lightGreen,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            5,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Maintenance Task',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Task name',
                  prefixIcon: const Icon(
                    Icons.build_outlined,
                    color: AppColors.green,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Save Task',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}