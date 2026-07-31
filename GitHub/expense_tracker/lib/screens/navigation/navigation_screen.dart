import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/app_colors.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  // Saari screens ki list jo tabs mein dikhengi
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ExpenseProvider>(context).isDarkMode;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.getCardBackground(isDark),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? Colors.white60 : Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
