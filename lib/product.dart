import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime expirationDate;

  Product({
    required this.name,
    required this.expirationDate,
  });
}