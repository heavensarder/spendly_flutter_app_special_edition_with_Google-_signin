import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/models.dart';
import 'package:spendly/spendly_provider.dart';

class AddSpendPlanDialog extends StatefulWidget {
  const AddSpendPlanDialog({super.key});

  @override
  State<AddSpendPlanDialog> createState() => _AddSpendPlanDialogState();
}

class _AddSpendPlanDialogState extends State<AddSpendPlanDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Spend Plan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g., Rent, Utilities',
            ),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter planned amount',
            ),
          ),
          ListTile(
            title: Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
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
            final title = _titleController.text.trim();
            final amount = double.tryParse(_amountController.text);

            if (title.isNotEmpty && amount != null && amount > 0) {
              final newPlan = SpendPlan(
                title: title,
                amount: amount,
                date: _selectedDate,
              );
              Provider.of<SpendlyProvider>(context, listen: false).addSpendPlan(newPlan);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid title, amount, and date.')),
              );
            }
          },
          child: const Text('Add Plan'),
        ),
      ],
    );
  }
}
