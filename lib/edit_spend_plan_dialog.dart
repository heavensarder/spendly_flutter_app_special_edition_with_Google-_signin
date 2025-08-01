import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/models.dart';
import 'package:spendly/spendly_provider.dart';

class EditSpendPlanDialog extends StatefulWidget {
  final SpendPlan spendPlan;

  const EditSpendPlanDialog({super.key, required this.spendPlan});

  @override
  State<EditSpendPlanDialog> createState() => _EditSpendPlanDialogState();
}

class _EditSpendPlanDialogState extends State<EditSpendPlanDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.spendPlan.title);
    _amountController = TextEditingController(text: widget.spendPlan.amount.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Spend Plan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
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
            final newTitle = _titleController.text.trim();
            final newAmount = double.tryParse(_amountController.text);

            if (newTitle.isNotEmpty && newAmount != null && newAmount > 0) {
              Provider.of<SpendlyProvider>(context, listen: false).editSpendPlan(
                widget.spendPlan,
                newTitle,
                newAmount,
              );
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid title and amount.')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
