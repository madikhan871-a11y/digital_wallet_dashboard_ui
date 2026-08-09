import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/user_model.dart';
import 'providers/app_provider.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/fines_management_screen.dart';
import 'screens/admin/occupancy_report_screen.dart';
import 'screens/admin/seat_management_screen.dart';
import 'screens/admin/student_approvals_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/pending_approval_screen.dart';
import 'screens/auth/rejected_account_screen.dart';
import 'screens/student/my_reservations_screen.dart';
import 'screens/student/notifications_screen.dart';
import 'screens/student/student_booking_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_navbar.dart';
import 'widgets/header_bar.dart';

const String supabaseUrl = 'https://doswjlypfbdjdedtaazn.supabase.co';
const String supabaseAnonKey = 'sb_publishable_SSzzyUVyjO8ti9i_KMhYoA_-eVBWbn5';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const SeatReserveApp(),
    ),
  );
}

class SeatReserveApp extends StatelessWidget {
  const SeatReserveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seat Reserve',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Ensure initial authentication state / session load happens cleanly after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.secondary),
            ),
          );
        }

        final user = provider.currentUser;

        if (user == null) {
          return LoginScreen(
            onLoginSuccess: () {
              provider.refreshData();
            },
          );
        }

        // Student Approval Status Guard
        if (user.role == UserRole.student) {
          if (user.status == UserStatus.pending) {
            return const PendingApprovalScreen();
          } else if (user.status == UserStatus.rejected) {
            return const RejectedAccountScreen();
          }
        }

        return const MainShellScreen();
      },
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final user = provider.currentUser;

    if (user == null) return const SizedBox.shrink();

    final bool isAdmin = user.role == UserRole.admin;

    final List<Map<String, dynamic>> navItems = isAdmin
        ? [
      {
        'title': 'Dashboard',
        'icon': Icons.dashboard,
        'screen': AdminDashboardScreen(
          onNavigate: (index) => setState(() => _currentIndex = index),
        ),
      },
      {
        'title': 'Approvals',
        'icon': Icons.check_circle_outline,
        'screen': const StudentApprovalsScreen(),
      },
      {
        'title': 'Seats',
        'icon': Icons.event_seat,
        'screen': const SeatManagementScreen(),
      },
      {
        'title': 'Fines',
        'icon': Icons.payments_outlined,
        'screen': const FinesManagementScreen(),
      },
      {
        'title': 'Reports',
        'icon': Icons.bar_chart,
        'screen': const OccupancyReportScreen(),
      },
    ]
        : [
      {
        'title': 'Book Seat',
        'icon': Icons.event_seat,
        'screen': const StudentBookingScreen(),
      },
      {
        'title': 'My Seats',
        'icon': Icons.bookmark_outline,
        'screen': const MyReservationsScreen(),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_none,
        'screen': const NotificationsScreen(),
      },
    ];

    // Prevent RangeError if navigation items list size changes due to role update
    if (_currentIndex >= navItems.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: HeaderBar(title: navItems[_currentIndex]['title'] as String),
      body: IndexedStack(
        index: _currentIndex,
        children: navItems.map<Widget>((e) => e['screen'] as Widget).toList(),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        items: navItems,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}