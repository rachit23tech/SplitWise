import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/payment_service.dart';
import '../models/payment.dart';

class SettleUpScreen extends StatefulWidget {
  final List<Map<String, String>> members;

  const SettleUpScreen({super.key, required this.members});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  final PaymentService _paymentService = PaymentService();
  String? fromUser;
  String? toUser;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fromUser = FirebaseAuth.instance.currentUser!.uid;
  }

  void _settle() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (fromUser == null || toUser == null || amount <= 0) return;

    final payment = Payment(
      from: fromUser!,
      to: toUser!,
      amount: amount,
      date: DateTime.now(),
    );

    await _paymentService.settleUp(payment);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settle Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: fromUser,
              decoration: const InputDecoration(labelText: "From"),
              items: widget.members.map((m) {
                return DropdownMenuItem(
                  value: m['uid'],
                  child: Text(m['name']!),
                );
              }).toList(),
              onChanged: (val) => setState(() => fromUser = val),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: toUser,
              decoration: const InputDecoration(labelText: "To"),
              items: widget.members.map((m) {
                return DropdownMenuItem(
                  value: m['uid'],
                  child: Text(m['name']!),
                );
              }).toList(),
              onChanged: (val) => setState(() => toUser = val),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _settle,
              child: const Text("Settle Payment"),
            ),
          ],
        ),
      ),
    );
  }
}
