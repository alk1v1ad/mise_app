import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mise_app/main.dart';
import 'package:mise_app/product.dart';
import 'package:mise_app/recipe.dart';

void main() {
  late Directory hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('mise_app_test_');
    Hive.init(hiveDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(RecipeAdapter());
    }

    await Hive.openBox<Product>('products');
    await Hive.openBox<Recipe>('recipes');
  });

  tearDown(() async {
    await Hive.close();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  testWidgets('app starts on welcome screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Mise'), findsOneWidget);
  });
}
