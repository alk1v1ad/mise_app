import 'package:flutter/material.dart';
import 'app_colors.dart';
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
  DateTime? selectedDate;


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
      selectedDate = d;
      dateController.text = "${d.day}.${d.month}.${d.year}";

      selectedCategory = widget.existingProduct!.category;
      quantityController.text = widget.existingProduct!.quantity;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    quantityController.dispose();
    super.dispose();
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
                  final now = DateTime.now();
                  final initialDate =
                      selectedDate != null && selectedDate!.isAfter(now)
                          ? selectedDate!
                          : now;
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: now,
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    selectedDate = pickedDate;
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
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color:
                      isSelected ? AppColors.background : Colors.black,
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
                    final name = nameController.text.trim();

                    if (name.isEmpty || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Заполни все поля'),
                        ),
                      );
                      return;
                    }


                    final product = Product(
                      name: name,
                      expirationDate: selectedDate!,
                      category: selectedCategory,
                      quantity: quantityController.text.trim(),
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
