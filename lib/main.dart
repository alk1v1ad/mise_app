import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_product_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'welcome_screen.dart';
import 'recipe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Product>('products');
  await Hive.openBox<Recipe>('recipes');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Huninn',
        scaffoldBackgroundColor: const Color(0xFFD2B48C),

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF808000),
          selectionHandleColor: Color(0xFF808000),
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF808000),
          primary: const Color(0xFF808000),
          background: const Color(0xFFD2B48C),
          surface: const Color(0xFFD2B48C),
          onPrimary: const Color(0xFFD2B48C),
          onSurface: Colors.black,
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF808000)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF808000), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.black),
        ),

        canvasColor: const Color(0xFFD2B48C),
        cardColor: const Color(0xFFD2B48C),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD2B48C),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF808000),
            foregroundColor: const Color(0xFFD2B48C),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      home: const WelcomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  final box = Hive.box<Product>('products');

  @override
  void initState() {
    super.initState();
    products = box.values.cast<Product>().toList();
    sortProducts();
  }

  void sortProducts() {
    products.sort(
          (a, b) => a.expirationDate.compareTo(b.expirationDate),
    );
  }

  Color getColor(Product product) {
    final now = DateTime.now();
    final diff = product.expirationDate.difference(now).inDays;

    if (diff <= 0) return Colors.red;
    if (diff <= 3) return Colors.orange;
    return Colors.green;
  }

  String formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> generateRecipe() async {
    final apiKey = 'API_KEY';

    final productNames = products.map((p) => p.name).join(', ');

    final response = await http.post(
      Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "llama3.1-8b",
        "messages": [
          {
            "role": "user",
            "content": "Придумай простой рецепт из этих продуктов: $productNames"
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'];

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Рецепт'),
          content: SingleChildScrollView(child: Text(text)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка генерации рецепта')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mise'),
      ),
      body: products.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, size: 64, color: Color(0xFFA0522D)),
            SizedBox(height: 16),
            Text(
              'Список продуктов пуст',
              style:
              TextStyle(fontSize: 18, color: Color(0xFFA0522D)),
            ),
          ],
        ),
      )
          : Builder(
        builder: (context) {
          final now = DateTime.now();

          final urgent = products.where((p) {
            final diff = p.expirationDate.difference(now).inDays;
            return diff <= 3;
          }).toList();

          final normal = products.where((p) {
            final diff = p.expirationDate.difference(now).inDays;
            return diff > 3;
          }).toList();

          return ListView(
            children: [
              if (urgent.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Скоро испортится',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                ...urgent.map((product) {
                  final index = products.indexOf(product);

                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: getColor(product),
                      size: 12,
                    ),
                    title: Text(product.name),
                    subtitle: Text('до ${formatDate(product.expirationDate)}'),

                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductScreen(
                            existingProduct: product,
                          ),
                        ),
                      );

                      if (updated != null && updated is Product) {
                        setState(() {
                          final key = box.keyAt(index);
                          box.put(key, updated);
                          products[index] = updated;
                          sortProducts();
                        });
                      }
                    },

                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Удалить?'),
                            content: const Text('Ты уверен?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    final key = box.keyAt(index);
                                    box.delete(key);
                                    products.removeAt(index);
                                  });
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
                }),
              ],

              if (normal.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Остальное',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...normal.map((product) {
                  final index = products.indexOf(product);

                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: getColor(product),
                      size: 12,
                    ),
                    title: Text(product.name),
                    subtitle: Text('до ${formatDate(product.expirationDate)}'),

                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductScreen(
                            existingProduct: product,
                          ),
                        ),
                      );

                      if (updated != null && updated is Product) {
                        setState(() {
                          final key = box.keyAt(index);
                          box.put(key, updated);
                          products[index] = updated;
                          sortProducts();
                        });
                      }
                    },

                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Удалить?'),
                            content: const Text('Ты уверен?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    final key = box.keyAt(index);
                                    box.delete(key);
                                    products.removeAt(index);
                                  });
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
                }),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF808000),
        foregroundColor: const Color(0xFFD2B48C),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );

          if (result != null && result is Product) {
            setState(() {
              box.add(result);
              products.add(result);
              sortProducts();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}