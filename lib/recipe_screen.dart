import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'recipe.dart';

class RecipeScreen extends StatefulWidget {
  final List<Product> products;

  const RecipeScreen({super.key, required this.products});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String recipe = 'Загрузка рецепта...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    generateRecipe();
  }

  Future<void> generateRecipe() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final productNames = widget.products.map((p) => p.name).toList();

    try {
      final response = await http.post(
        Uri.parse('https://mise-backend-m66q.onrender.com/recipe'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "products": productNames,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          recipe = data['recipe'];
          isLoading = false;
        });
      } else {
        setState(() {
          recipe = 'Ошибка сервера';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        recipe = 'Нет соединения с сервером';
        isLoading = false;
      });
    }
  }

  // 🔥 РАЗБОР РЕЦЕПТА
  Widget _buildRecipeContent() {
    final lines = recipe.split('\n');

    String title = '';
    List<String> ingredients = [];
    List<String> steps = [];

    String current = '';

    for (var line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('TITLE:')) {
        title = trimmed.replaceFirst('TITLE:', '').trim();
        current = '';
        continue;
      }

      if (trimmed.startsWith('INGREDIENTS')) {
        current = 'ingredients';
        continue;
      }

      if (trimmed.startsWith('STEPS')) {
        current = 'steps';
        continue;
      }

      if (current == 'ingredients' && trimmed.isNotEmpty) {
        ingredients.add(trimmed.replaceFirst('-', '').trim());
      }

      if (current == 'steps' && trimmed.isNotEmpty) {
        steps.add(trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), ''));
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6D3A3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
          ],

          if (ingredients.isNotEmpty) ...[
            const Text(
              'Ингредиенты',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...ingredients.map(
                  (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('• $e'),
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (steps.isNotEmpty) ...[
            const Text(
              'Инструкции',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${entry.key + 1}. '),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: _buildRecipeContent(),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: generateRecipe,
                    child: const Text('Другой'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final box = Hive.box<Recipe>('recipes');

                      box.add(
                        Recipe(
                          text: recipe,
                          createdAt: DateTime.now(),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сохранено')),
                      );
                    },
                    child: const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}