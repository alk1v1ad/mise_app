import 'package:flutter/material.dart';
import 'product.dart';

class AddProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  String selectedCategory = 'Другое';

  final List<String> categories = [
    'Мясо',
    'Рыба',
    'Овощи',
    'Фрукты',
    'Молочка',
    'Крупы',
    'Сладкое',
    'Напитки',
    'Другое',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingProduct != null) {
      nameController.text = widget.existingProduct!.name;

      final d = widget.existingProduct!.expirationDate;
      dateController.text = "${d.day}.${d.month}.${d.year}";

      selectedCategory = widget.existingProduct!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить продукт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Название
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название продукта',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // Количество
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Количество (например: 200г, 2 шт)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // 🔹 Дата
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Срок годности',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    dateController.text =
                    "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";
                  }
                },
              ),

              const SizedBox(height: 16),

              // 🔹 Категория
              const Text(
                'Категория',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),



              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: const Color(0xFF808000),
                    labelStyle: TextStyle(
                      color:
                      isSelected ? const Color(0xFFD2B48C) : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 🔹 Кнопка
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final date = dateController.text;

                    if (name.isEmpty || date.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Заполни все поля'),
                        ),
                      );
                      return;
                    }

                    final parts = date.split('.');
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);

                    final product = Product(
                      name: name,
                      expirationDate: DateTime(year, month, day),
                      category: selectedCategory,
                      quantity: quantityController.text,
                    );

                    Navigator.pop(context, product);
                  },
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}