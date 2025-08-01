import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/models.dart';
import 'package:spendly/spendly_provider.dart';
import 'package:spendly/edit_income_task_dialog.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull

class IncomeSourceDetailsPage extends StatefulWidget {
  final UpcomingIncome incomeSource;

  const IncomeSourceDetailsPage({super.key, required this.incomeSource});

  @override
  State<IncomeSourceDetailsPage> createState() =>
      _IncomeSourceDetailsPageState();
}

class _IncomeSourceDetailsPageState extends State<IncomeSourceDetailsPage> {
  void _addTask(String title, double amount) {
    final newTask = IncomeTask(
      incomeSourceId: widget.incomeSource.id!,
      title: title,
      amount: amount,
    );
    Provider.of<SpendlyProvider>(context, listen: false).addIncomeTask(widget.incomeSource.id!, newTask);
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Enter title'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Enter amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                _addTask(
                  titleController.text,
                  double.parse(amountController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spendlyProvider = Provider.of<SpendlyProvider>(context);
    // Use firstWhereOrNull to safely get the incomeSource, or null if it's been removed
    final incomeSource = spendlyProvider.upcomingIncomes.firstWhereOrNull((income) => income.id == widget.incomeSource.id);

    // If incomeSource is null, it means it has been removed, so pop the page
    if (incomeSource == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return const Scaffold(); // Return an empty scaffold while popping
    }

    final tasks = incomeSource.tasks ?? [];
    final totalAmount = tasks.fold(0.0, (sum, task) => sum + task.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(incomeSource.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: const Icon(Icons.task, color: Colors.orange, size: 40),
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          trailing: Text(
                            '৳${task.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditIncomeTaskDialog(incomeTask: task),
                            ); // No need to reload tasks, provider will notify
                          },
                        ),
                      );
                    },
                  ),
          ),
          Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Addition'),
                    content: const Text('Are you sure you want to add this income to your total?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              }
              return false;
            },
            onDismissed: (direction) async {
              print('Adding total amount to SpendlyProvider: ৳${totalAmount.toStringAsFixed(2)}');
              Provider.of<SpendlyProvider>(context, listen: false)
                  .addMoney(totalAmount, sourceDescription: 'from ${incomeSource.title}');
              // Delete tasks from provider, which will also sync to Firebase
              spendlyProvider.deleteUpcomingIncome(incomeSource.id!); 
              Navigator.of(context).pop(); // Pop the page after dismissal
            },
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    '৳${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}