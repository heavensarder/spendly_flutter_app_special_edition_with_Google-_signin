import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/spendly_provider.dart';

class AddMoneyDialog extends StatefulWidget {
  const AddMoneyDialog({super.key});

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Money'),
      content: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Amount',
          hintText: 'Enter amount to add',
        ),
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
            if (amount != null && amount > 0) {
              Provider.of<SpendlyProvider>(context, listen: false).addMoney(amount);
              Navigator.of(context).pop();
            } else {
              // Show an error or a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount.')),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
