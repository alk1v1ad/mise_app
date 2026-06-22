import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'recipe.dart';
import 'dart:convert';

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
    try {
      final decoded = jsonDecode(widget.recipeText);

      final title = decoded['title'] ?? '';
      final ingredients =
      List<String>.from(decoded['usedIngredients'] ?? []);

      return AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
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
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
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
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  ...ingredients.take(3).map((e) => Text('• $e')),

                  if (ingredients.length > 3)
                    const Text('...'),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }
}

class _RecipeDetailPage extends StatelessWidget {
  final String recipeText;

  const _RecipeDetailPage({required this.recipeText});

  @override
  Widget build(BuildContext context) {
    final decoded = jsonDecode(recipeText);

    final title = decoded['title'] ?? '';
    final ingredients =
    List<String>.from(decoded['usedIngredients'] ?? []);
    final steps =
    List<String>.from(decoded['steps'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ингредиенты',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...ingredients.map((e) => Text('• $e')),

            const SizedBox(height: 20),

            const Text(
              'Шаги',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...steps.asMap().entries.map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('${e.key + 1}. ${e.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}