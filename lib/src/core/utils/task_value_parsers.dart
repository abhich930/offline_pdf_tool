List<int> parsePositiveIntList(String raw) {
  final values = raw
      .split(',')
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .where((value) => value > 0)
      .toList();

  if (values.isEmpty) {
    throw const FormatException('Enter one or more positive numbers separated by commas.');
  }

  return values;
}
