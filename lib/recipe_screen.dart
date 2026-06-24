import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'parsed_recipe.dart';
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

    // 🔥 1. Копируем и сортируем по сроку
    final products = [...widget.products];

    products.sort(
          (a, b) => a.expirationDate.compareTo(b.expirationDate),
    );

    // 🔥 2. Группируем (УЖЕ отсортированные!)
    final meat = products.where((p) => p.category == 'Мясо').toList();
    final fish = products.where((p) => p.category == 'Рыба').toList();
    final veggies = products.where((p) => p.category == 'Овощи').toList();
    final other = products.where((p) =>
    p.category != 'Мясо' &&
        p.category != 'Рыба' &&
        p.category != 'Овощи'
    ).toList();

    final selected = <Product>[];

    // 🔥 3. Основа (самый СРОЧНЫЙ!)
    if (meat.isNotEmpty) {
      selected.add(meat.first);
    } else if (fish.isNotEmpty) {
      selected.add(fish.first);
    }

    // 🔥 4. Овощи (тоже по сроку)
    selected.addAll(veggies.take(2));

    // 🔥 5. Остальное (минимум)
    selected.addAll(other.take(2));

    // ❗ если вдруг вообще пусто
    if (selected.isEmpty && products.isNotEmpty) {
      selected.addAll(products.take(3));
    }

    // 🔥 6. Формируем строку для AI
    final productNames = selected.map((p) {
      final daysLeft =
          p.expirationDate.difference(DateTime.now()).inDays;

      return "${p.name} (${p.quantity}) [срок: $daysLeft дн.]";
    }).toList();

    try {
      final response = await http
          .post(
        Uri.parse('https://mise-backend-m66q.onrender.com/recipe'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "products": productNames,
        }),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          recipe = data['recipe'];
          isLoading = false;
        });
      } else {
        setState(() {
          recipe = 'Ошибка сервера (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        recipe = 'Сервер не отвечает (возможно, Render проснулся)';
        isLoading = false;
      });
    }
  }

  // 🔥 РАЗБОР РЕЦЕПТА
  Widget _buildRecipeContent() {
    final parsed = ParsedRecipe.fromText(recipe);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.recipeSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parsed.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),

          if (!parsed.isStructured) ...[
            Text(parsed.fallbackText),
          ] else ...[
            if (parsed.ingredients.isNotEmpty) ...[
              const Text(
                'Ингредиенты',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...parsed.ingredients.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text('• $e'),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (parsed.steps.isNotEmpty) ...[
              const Text(
                'Инструкции',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...parsed.steps.asMap().entries.map(
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
