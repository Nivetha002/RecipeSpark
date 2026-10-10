import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ingredient_tile.dart';
import '../../recipes/data/recipe_catalog.dart';
import '../../recipes/screens/recipe_list_screen.dart';
import '../data/ingredient_catalog.dart';
import '../models/ingredient.dart';
import '../state/ingredient_selection_provider.dart';

class SelectIngredientsScreen extends StatefulWidget {
  const SelectIngredientsScreen({super.key});

  @override
  State<SelectIngredientsScreen> createState() =>
      _SelectIngredientsScreenState();
}

class _SelectIngredientsScreenState extends State<SelectIngredientsScreen> {
  final _controller = TextEditingController();
  String _query = '';
  IngredientGroup? _group; // null = All

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// "chicken, onion, tomato" + Enter adds all of them at once.
  void _submit(String text) {
    final parsed = IngredientCatalog.parseList(text);
    if (parsed.isEmpty) return;
    context
        .read<IngredientSelectionProvider>()
        .addAll(parsed.map((e) => e.id));
    _controller.clear();
    setState(() => _query = '');
  }

  void _findRecipes() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecipeListScreen(
          title: 'Matching Recipes',
          recipes: RecipeCatalog.all,
          onlyMatching: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<IngredientSelectionProvider>();
    final items = IngredientCatalog.search(_query, group: _group);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Ingredients',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text('Choose what you have in your kitchen',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (!selection.isEmpty)
                    TextButton(
                      onPressed: selection.clear,
                      child: const Text('Clear',
                          style: TextStyle(color: AppColors.orange)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: _submit,
                decoration: const InputDecoration(
                  hintText: 'Search or type: chicken, onion, tomato',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                ),
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  _FilterPill(
                    label: 'All',
                    selected: _group == null,
                    onTap: () => setState(() => _group = null),
                  ),
                  for (final g in IngredientGroup.values)
                    _FilterPill(
                      label: g.label,
                      selected: _group == g,
                      onTap: () => setState(() => _group = g),
                    ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('No ingredients found.',
                          style: TextStyle(color: AppColors.textMuted)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final ing = items[i];
                        return IngredientTile(
                          ingredient: ing,
                          selected: selection.isSelected(ing.id),
                          emojiSize: 38,
                          onTap: () => selection.toggle(ing.id),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.cream,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ElevatedButton(
                onPressed: selection.isEmpty ? null : _findRecipes,
                child: Text(selection.isEmpty
                    ? 'Select ingredients to continue'
                    : 'Find Recipes (${selection.count} selected)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.orange : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? AppColors.orange : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
