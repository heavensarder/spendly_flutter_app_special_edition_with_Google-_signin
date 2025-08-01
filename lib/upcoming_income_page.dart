import 'package:flutter/material.dart';
import 'package:spendly/database_helper.dart';
import 'package:spendly/models.dart';
import 'package:spendly/income_source_details_page.dart';
import 'package:provider/provider.dart';
import 'package:spendly/spendly_provider.dart';

class UpcomingIncomePage extends StatefulWidget {
  const UpcomingIncomePage({super.key});

  @override
  State<UpcomingIncomePage> createState() => _UpcomingIncomePageState();
}

class _UpcomingIncomePageState extends State<UpcomingIncomePage> {
  final dbHelper = DatabaseHelper.instance;

  void _addIncomeSource(String title) async {
    final newIncomeSource = UpcomingIncome(title: title);
    final spendlyProvider = Provider.of<SpendlyProvider>(context, listen: false);
    spendlyProvider.addUpcomingIncome(newIncomeSource);
  }

  void _showAddIncomeSourceDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Income Source'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Enter title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addIncomeSource(titleController.text);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Income'),
      ),
      body: Consumer<SpendlyProvider>(
        builder: (context, spendlyProvider, child) {
          final incomeSources = spendlyProvider.upcomingIncomes;
          return incomeSources.isEmpty
              ? const Center(
                  child: Text(
                    'No income sources yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: incomeSources.length,
                  itemBuilder: (context, index) {
                    final incomeSource = incomeSources[index];
                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 40),
                        title: Text(
                          incomeSource.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IncomeSourceDetailsPage(incomeSource: incomeSource),
                          ),
                        ),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Income Source'),
                              content: Text('Are you sure you want to delete "${incomeSource.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    spendlyProvider.deleteUpcomingIncome(incomeSource.id!); // Delete the income source
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeSourceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
