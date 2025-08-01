import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:spendly/models.dart';
import 'package:spendly/spendly_provider.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  List<HistoryItem> _filterHistory(List<HistoryItem> history) {
    if (_startDate == null || _endDate == null) {
      return history;
    }
    return history.where((item) =>
        item.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        item.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = picked;
      });
    }
  }

  Future<void> _generatePdf(List<HistoryItem> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Spendly Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              if (_startDate != null && _endDate != null)
                pw.Text('Date Range: ${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Description', 'Amount', 'Date', 'Type'],
                  ...data.map((item) => [
                    item.description,
                    '৳${item.amount.toStringAsFixed(2)}',
                    item.date.toLocal().toString().split(' ')[0],
                    item.type,
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final spendlyProvider = Provider.of<SpendlyProvider>(context);
    final history = spendlyProvider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.today, color: Colors.blueAccent),
              title: const Text('Today\'s Report'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                setState(() {
                  _startDate = DateTime.now();
                  _endDate = DateTime.now();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtered for Today')),
                );
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.green),
              title: const Text('This Week'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                setState(() {
                  final now = DateTime.now();
                  _startDate = now.subtract(Duration(days: now.weekday - 1));
                  _endDate = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtered for This Week')),
                );
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.orange),
              title: const Text('This Month'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                setState(() {
                  _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
                  _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filtered for This Month')),
                );
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.date_range, color: Colors.purple),
              title: Text(
                _startDate == null || _endDate == null
                    ? 'Select Date Range'
                    : '${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectDateRange(context),
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.calendar_view_day, color: Colors.teal),
              title: const Text('Select a Single Day'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectSingleDate(context),
            ),
          ),
          const SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () => _generatePdf(_filterHistory(history)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Export as PDF', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}