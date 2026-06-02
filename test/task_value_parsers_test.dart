import 'package:flutter_test/flutter_test.dart';
import 'package:offline_pdf_tool/src/core/utils/task_value_parsers.dart';

void main() {
  test('parsePositiveIntList parses comma-separated values', () {
    expect(parsePositiveIntList('1, 3,5'), equals(const [1, 3, 5]));
  });

  test('parsePositiveIntList rejects invalid input', () {
    expect(
      () => parsePositiveIntList('abc'),
      throwsA(isA<FormatException>()),
    );
  });
}
