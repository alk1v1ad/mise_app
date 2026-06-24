import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_colors.dart';
import 'add_product_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'product.dart';
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
        scaffoldBackgroundColor: AppColors.background,

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionHandleColor: AppColors.primary,
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
          surface: AppColors.background,
          onPrimary: AppColors.background,
          onSurface: Colors.black,
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.black),
        ),

        canvasColor: AppColors.background,
        cardColor: AppColors.background,

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
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
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.background,
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

  Future<void> editProduct(Product product) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          existingProduct: product,
        ),
      ),
    );

    if (!mounted || updated is! Product) return;

    product
      ..name = updated.name
      ..expirationDate = updated.expirationDate
      ..category = updated.category
      ..quantity = updated.quantity;

    await product.save();

    if (!mounted) return;
    setState(sortProducts);
  }

  Future<void> deleteProduct(Product product) async {
    await product.delete();

    if (!mounted) return;
    setState(() {
      products.remove(product);
    });
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
            Icon(Icons.inventory_2, size: 64, color: AppColors.emptyState),
            SizedBox(height: 16),
            Text(
              'Список продуктов пуст',
              style:
              TextStyle(fontSize: 18, color: AppColors.emptyState),
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
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: getColor(product),
                      size: 12,
                    ),
                    title: Text(product.name),
                    subtitle: Text('до ${formatDate(product.expirationDate)}'),

                    onTap: () => editProduct(product),

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
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await deleteProduct(product);
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
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: getColor(product),
                      size: 12,
                    ),
                    title: Text(product.name),
                    subtitle: Text('до ${formatDate(product.expirationDate)}'),

                    onTap: () => editProduct(product),

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
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await deleteProduct(product);
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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );

          if (result != null && result is Product) {
            await box.add(result);
            if (!mounted) return;
            setState(() {
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
