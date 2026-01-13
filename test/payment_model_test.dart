import 'package:flutter_test/flutter_test.dart';
import 'package:splitwise/models/payment.dart';

void main() {
  test('Payment toMap roundtrip', () {
    final p = Payment(from: 'u1', to: 'u2', amount: 25.5, date: DateTime.now());
    final m = p.toMap();

    expect(p.from, equals('u1'));
    expect(p.to, equals('u2'));
    expect(p.amount, equals(25.5));
  });
}
