import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/models.dart';
import 'package:spendly/spendly_provider.dart';

class EditIncomeTaskDialog extends StatefulWidget {
  final IncomeTask incomeTask;

  const EditIncomeTaskDialog({super.key, required this.incomeTask});

  @override
  State<EditIncomeTaskDialog> createState() => _EditIncomeTaskDialogState();
}

class _EditIncomeTaskDialogState extends State<EditIncomeTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.incomeTask.title);
    _amountController = TextEditingController(text: widget.incomeTask.amount.toString());
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
      title: const Text('Edit Task'),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newTitle = _titleController.text.trim();
            final newAmount = double.tryParse(_amountController.text);

            if (newTitle.isNotEmpty && newAmount != null && newAmount > 0) {
              Provider.of<SpendlyProvider>(context, listen: false).editIncomeTask(
                widget.incomeTask,
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
