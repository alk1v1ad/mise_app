import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_colors.dart';
import 'parsed_recipe.dart';
import 'recipe.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Recipe>('recipes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранённые рецепты'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Recipe> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Рецептов пока нет'),
            );
          }

          final recipes = box.values.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return _RecipeCard(
                recipeText: recipe.text,
                date: recipe.createdAt,
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Удалить рецепт?'),
                      content:
                      const Text('Это действие нельзя отменить'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {
                            recipe.delete();
                            Navigator.pop(context);
                          },
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _RecipeCard extends StatefulWidget {
  final String recipeText;
  final DateTime date;
  final VoidCallback onDelete;

  const _RecipeCard({
    required this.recipeText,
    required this.date,
    required this.onDelete,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    final parsed = ParsedRecipe.fromText(widget.recipeText);
    final previewIngredients = parsed.ingredients.take(3).toList();

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => scale = 0.97),
        onTapUp: (_) => setState(() => scale = 1),
        onTapCancel: () => setState(() => scale = 1),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 250),
              pageBuilder: (_, animation, __) => FadeTransition(
                opacity: animation,
                child: _RecipeDetailPage(
                  recipeText: widget.recipeText,
                ),
              ),
            ),
          );
        },
        child: Card(
          color: AppColors.recipeSurface,
          surfaceTintColor: Colors.transparent,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: AppColors.recipeBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        parsed.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: widget.onDelete,
                    )
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  '${widget.date.day}.${widget.date.month}.${widget.date.year}',
                  style: const TextStyle(color: AppColors.mutedText),
                ),

                const SizedBox(height: 10),

                if (previewIngredients.isNotEmpty) ...[
                  ...previewIngredients.map((e) => Text('• $e')),
                  if (parsed.ingredients.length > previewIngredients.length)
                    const Text('...'),
                ] else
                  Text(
                    parsed.fallbackText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeDetailPage extends StatelessWidget {
  final String recipeText;

  const _RecipeDetailPage({required this.recipeText});

  @override
  Widget build(BuildContext context) {
    final parsed = ParsedRecipe.fromText(recipeText);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(parsed.title),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!parsed.isStructured) ...[
              Text(parsed.fallbackText),
            ] else ...[
              ...parsed.ingredients.map((e) => Text('• $e')),
              if (parsed.ingredients.isNotEmpty && parsed.steps.isNotEmpty)
                const SizedBox(height: 20),
              ...parsed.steps.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${e.key + 1}. ${e.value}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
