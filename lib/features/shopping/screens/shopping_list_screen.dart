import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../ingredients/data/ingredient_catalog.dart';
import '../state/shopping_list_provider.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = context.watch<ShoppingListProvider>();
    final items = list.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        backgroundColor: AppColors.cream,
        actions: [
          if (items.any((e) => e.checked))
            TextButton(
                onPressed: list.clearChecked, child: const Text('Clear checked')),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🛒', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 12),
                    Text('Your list is empty',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text(
                      'Open a recipe and tap "Add to shopping list" to add the ingredients you are missing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final info = IngredientCatalog.byId(item.ingredientId);
                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.checked,
                      activeColor: AppColors.orange,
                      onChanged: (_) => list.toggle(item.ingredientId),
                    ),
                    title: Text(
                      '${info?.emoji ?? ''} ${info?.name ?? item.ingredientId}',
                      style: TextStyle(
                        decoration:
                            item.checked ? TextDecoration.lineThrough : null,
                        color: item.checked ? AppColors.textMuted : null,
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => list.remove(item.ingredientId),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
