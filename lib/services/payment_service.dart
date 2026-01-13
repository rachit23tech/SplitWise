import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> settleUp(Payment payment) async {
    await _db.collection('payments').add(payment.toMap());
  }
}
