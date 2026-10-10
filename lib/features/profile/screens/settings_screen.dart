import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../shopping/state/shopping_list_provider.dart';
import '../state/cooking_history_provider.dart';
import '../state/profile_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name =
      TextEditingController(text: context.read<ProfileProvider>().name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _confirm(String title, String message, VoidCallback onYes) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) onYes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: AppColors.cream),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Display name', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileProvider>().setName(_name.text);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Name saved')));
            },
            child: const Text('Save name'),
          ),
          const SizedBox(height: 28),
          Text('Your data', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Everything is stored on this device only.',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear cooking history'),
            onTap: () => _confirm(
              'Clear cooking history?',
              'This also resets your cooked count and streak.',
              () => context.read<CookingHistoryProvider>().clear(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Clear shopping list'),
            onTap: () => _confirm(
              'Clear shopping list?',
              'All items will be removed.',
              () => context.read<ShoppingListProvider>().clear(),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('RecipeSpark 1.0.0',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
