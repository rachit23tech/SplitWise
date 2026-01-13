import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise/models/expense.dart';

void main() {
  test('Expense toMap/fromDoc roundtrip', () {
    final e = Expense(
      id: '1',
      description: 'Dinner',
      amount: 100.0,
      paidBy: 'payer1',
      participants: ['a@example.com', 'b@example.com'],
      splitType: 'custom',
      customSplits: {'a@example.com': 40.0, 'b@example.com': 60.0},
      groupId: 'group1',
      createdAt: DateTime.now(),
    );

    final map = e.toMap();

    expect(e.description, equals('Dinner'));
    expect(e.amount, equals(100.0));
    expect(e.customSplits!['a@example.com'], equals(40.0));
  });
}
