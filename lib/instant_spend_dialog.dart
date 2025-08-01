import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/spendly_provider.dart';

class InstantSpendDialog extends StatefulWidget {
  const InstantSpendDialog({super.key});

  @override
  State<InstantSpendDialog> createState() => _InstantSpendDialogState();
}

class _InstantSpendDialogState extends State<InstantSpendDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Instant Spend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter amount to deduct',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'e.g., Coffee, Groceries',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.lightBlue, // Minimal color
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Minimal padding
            textStyle: const TextStyle(fontSize: 14), // Smaller text
            minimumSize: Size.zero, // Allow button to shrink to child size
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
            alignment: Alignment.center, // Center the text
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            final description = _descriptionController.text.trim();

            if (amount != null && amount > 0 && description.isNotEmpty) {
              Provider.of<SpendlyProvider>(context, listen: false).instantSpend(amount, description);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount and description.')),
              );
            }
          },
          child: const Text('Spend'),
        ),
      ],
    );
  }
}
