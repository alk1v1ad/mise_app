import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime expirationDate;

  @HiveField(2)
  String category;

  @HiveField(3)
  String quantity;

  Product({
    required this.name,
    required this.expirationDate,
    required this.category,
    required this.quantity,
  });
}
