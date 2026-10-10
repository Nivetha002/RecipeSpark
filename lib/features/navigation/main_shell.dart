import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../assistant/assistant_screen.dart';
import '../explore/explore_screen.dart';
import '../home/screens/home_screen.dart';
import '../saved/saved_screen.dart';
import 'navigation_controller.dart';

/// Bottom navigation: Home, Explore, Saved, Assistant.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    return Scaffold(
      body: IndexedStack(
        index: nav.index,
        children: const [
          HomeScreen(),
          ExploreScreen(),
          SavedScreen(),
          AssistantScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.index,
        onDestinationSelected: nav.setIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.orangeSoft,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.orange),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.orange),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark, color: AppColors.orange),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy, color: AppColors.orange),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}
