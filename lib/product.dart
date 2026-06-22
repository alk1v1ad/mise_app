import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime expirationDate;

  @HiveField(2)
  final String category;

  Product({
    required this.name,
    required this.expirationDate,
    required this.category,
  });
}