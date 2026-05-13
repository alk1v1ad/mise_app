import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 1)
class Recipe extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  DateTime createdAt;

  Recipe({
    required this.text,
    required this.createdAt,
  });
}