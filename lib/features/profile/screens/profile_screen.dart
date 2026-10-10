import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../navigation/navigation_controller.dart';
import '../../saved/state/favorites_provider.dart';
import '../../shopping/screens/shopping_list_screen.dart';
import '../../shopping/state/shopping_list_provider.dart';
import '../state/cooking_history_provider.dart';
import '../state/profile_provider.dart';
import 'cooking_history_screen.dart';
import 'help_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final history = context.watch<CookingHistoryProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final shopping = context.watch<ShoppingListProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => _push(context, const SettingsScreen()),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.orangeSoft,
                  child: Icon(Icons.person, size: 36, color: AppColors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.displayName,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text('Guest · data stays on this device',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Cooking Stats',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Stat(
                          icon: Icons.restaurant,
                          value: '${history.totalCooked}',
                          label: 'Recipes Cooked'),
                      _Stat(
                          icon: Icons.favorite,
                          value: '${favorites.count}',
                          label: 'Saved Recipes'),
                      _Stat(
                          icon: Icons.local_fire_department,
                          value: '${history.streak}',
                          label: 'Day Streak'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.bookmark_border,
                    label: 'My Saved Recipes',
                    onTap: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      context.read<NavigationController>().setIndex(2);
                    },
                  ),
                  _MenuTile(
                    icon: Icons.history,
                    label: 'Cooking History',
                    onTap: () => _push(context, const CookingHistoryScreen()),
                  ),
                  _MenuTile(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Shopping List',
                    trailingText: shopping.count == 0 ? null : '${shopping.count}',
                    onTap: () => _push(context, const ShoppingListScreen()),
                  ),
                  _MenuTile(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => _push(context, const SettingsScreen()),
                  ),
                  _MenuTile(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => _push(context, const HelpScreen()),
                  ),
                  _MenuTile(
                    icon: Icons.login,
                    label: 'Sign In',
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Accounts are not available yet'),
                        content: const Text(
                            'You are using RecipeSpark as a guest. Everything works without an account, and your data stays on this device.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: AppColors.orange),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.trailingText});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.textDark),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(trailingText!,
                  style: const TextStyle(
                      color: AppColors.orange, fontWeight: FontWeight.w700)),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      );
}
