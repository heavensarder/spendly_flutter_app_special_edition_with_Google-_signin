import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/spendly_provider.dart';

class EditTotalAmountDialog extends StatefulWidget {
  final double currentAmount;

  const EditTotalAmountDialog({super.key, required this.currentAmount});

  @override
  State<EditTotalAmountDialog> createState() => _EditTotalAmountDialogState();
}

class _EditTotalAmountDialogState extends State<EditTotalAmountDialog> {
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.currentAmount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Total Amount'),
      content: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'New Total Amount',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newAmount = double.tryParse(_amountController.text);
            if (newAmount != null) {
              Provider.of<SpendlyProvider>(context, listen: false).setTotalAmount(newAmount);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount.')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
