import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/food_image.dart';
import '../../profile/state/cooking_history_provider.dart';
import '../data/recipe_catalog.dart';
import '../models/recipe.dart';

/// One step at a time, with progress, tips and a completion state.
class CookingScreen extends StatefulWidget {
  final String recipeId;
  const CookingScreen({super.key, required this.recipeId});

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  int _index = 0;
  bool _done = false;

  void _finish(Recipe recipe) {
    if (_done) return;
    setState(() => _done = true);
    context.read<CookingHistoryProvider>().record(recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = RecipeCatalog.byId(widget.recipeId);
    if (recipe == null || recipe.steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No cooking steps available.')),
      );
    }
    final total = recipe.steps.length;

    return Scaffold(
      body: SafeArea(
        child: _done
            ? _Completed(
                recipe: recipe,
                onDone: () => Navigator.of(context).pop(),
                onAgain: () => setState(() {
                  _done = false;
                  _index = 0;
                }),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Step ${_index + 1} of $total',
                                  style: Theme.of(context).textTheme.titleLarge),
                              Text(recipe.steps[_index].title,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(
                      children: [
                        for (var i = 0; i < total; i++)
                          Expanded(
                            child: Container(
                              height: 6,
                              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
                              decoration: BoxDecoration(
                                color: i <= _index
                                    ? AppColors.orange
                                    : AppColors.orangeSoft,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FoodImage(
                            url: recipe.imageUrl,
                            asset: recipe.imageAsset,
                            emoji: recipe.emoji,
                            width: double.infinity,
                            height: 170,
                            radius: 20,
                            emojiSize: 72,
                          ),
                          const SizedBox(height: 18),
                          Text(recipe.steps[_index].title,
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(recipe.steps[_index].description,
                              style: const TextStyle(fontSize: 18, height: 1.45)),
                          if (recipe.steps[_index].tip != null) ...[
                            const SizedBox(height: 16),
                            _ProTip(text: recipe.steps[_index].tip!),
                          ],
                          const SizedBox(height: 20),
                          Text('All steps',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (var i = 0; i < total; i++)
                            _StepTile(
                              number: i + 1,
                              title: recipe.steps[i].title,
                              state: i < _index
                                  ? _StepState.done
                                  : (i == _index
                                      ? _StepState.current
                                      : _StepState.upcoming),
                              onTap: () => setState(() => _index = i),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              shape: const StadiumBorder(),
                              foregroundColor: AppColors.orange,
                              side: const BorderSide(color: AppColors.orange),
                            ),
                            onPressed: _index == 0
                                ? null
                                : () => setState(() => _index--),
                            child: const Text('Previous Step'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => _index == total - 1
                                ? _finish(recipe)
                                : setState(() => _index++),
                            child: Text(
                                _index == total - 1 ? 'Finish Cooking' : 'Next Step'),
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

class _ProTip extends StatelessWidget {
  final String text;
  const _ProTip({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.orangeSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, color: AppColors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pro Tip',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.orangeDeep)),
                  const SizedBox(height: 2),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      );
}

enum _StepState { done, current, upcoming }

class _StepTile extends StatelessWidget {
  final int number;
  final String title;
  final _StepState state;
  final VoidCallback onTap;
  const _StepTile(
      {required this.number,
      required this.title,
      required this.state,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final current = state == _StepState.current;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: current
                  ? AppColors.orange
                  : (state == _StepState.done
                      ? AppColors.matchGreenSoft
                      : AppColors.orangeSoft),
              child: state == _StepState.done
                  ? const Icon(Icons.check, size: 16, color: AppColors.matchGreen)
                  : Text('$number',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: current ? Colors.white : AppColors.orangeDeep)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                      color: state == _StepState.upcoming
                          ? AppColors.textMuted
                          : AppColors.textDark)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Completed extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onDone;
  final VoidCallback onAgain;
  const _Completed(
      {required this.recipe, required this.onDone, required this.onAgain});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 12),
              Text('Well done!', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'You finished cooking ${recipe.name}. It has been added to your cooking history.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onDone, child: const Text('Done')),
              const SizedBox(height: 8),
              TextButton(onPressed: onAgain, child: const Text('Cook again')),
            ],
          ),
        ),
      );
}
