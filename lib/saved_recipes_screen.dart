import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return ListTile(
                title: Text(
                  recipe.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${recipe.createdAt.day}.${recipe.createdAt.month}.${recipe.createdAt.year}',
                ),

                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Рецепт'),
                      content: SingleChildScrollView(
                        child: Text(recipe.text),
                      ),
                    ),
                  );
                },

                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Удалить рецепт?'),
                        content: const Text('Это действие нельзя отменить'),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}