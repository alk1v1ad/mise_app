import 'dart:convert';

class ParsedRecipe {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String fallbackText;
  final bool isStructured;

  const ParsedRecipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.fallbackText,
    required this.isStructured,
  });

  factory ParsedRecipe.fromText(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return ParsedRecipe.fallback(text);
      }

      final title = _readString(decoded['title']);
      final ingredients = _readStringList(
        decoded['usedIngredients'] ?? decoded['ingredients'],
      );
      final steps = _readStringList(decoded['steps']);

      if (title.isEmpty && ingredients.isEmpty && steps.isEmpty) {
        return ParsedRecipe.fallback(text);
      }

      return ParsedRecipe(
        title: title.isEmpty ? textPreview(text) : title,
        ingredients: ingredients,
        steps: steps,
        fallbackText: text,
        isStructured: true,
      );
    } catch (_) {
      return ParsedRecipe.fallback(text);
    }
  }

  factory ParsedRecipe.fallback(String text) {
    return ParsedRecipe(
      title: textPreview(text),
      ingredients: const [],
      steps: const [],
      fallbackText: text,
      isStructured: false,
    );
  }

  static String textPreview(String text) {
    final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return 'Р РµС†РµРїС‚';
    if (normalized.length <= 80) return normalized;
    return '${normalized.substring(0, 80)}...';
  }

  static String _readString(Object? value) {
    if (value is String) return value.trim();
    return '';
  }

  static List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }

    return const [];
  }
}
