import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatMate Unit Tests', () {
    test('Basic arithmetic test', () {
      expect(2 + 2, equals(4));
      expect(10 - 5, equals(5));
      expect(3 * 4, equals(12));
      expect(15 / 3, equals(5));
    });

    test('String manipulation test', () {
      expect('MatMate'.length, equals(7));
      expect('calculator'.toUpperCase(), equals('CALCULATOR'));
    });

    test('List operations test', () {
      final numbers = [1, 2, 3, 4, 5];
      expect(numbers.length, equals(5));
      expect(numbers.first, equals(1));
      expect(numbers.last, equals(5));
    });
  });
}
