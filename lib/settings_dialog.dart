import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/report_page.dart';
import 'package:spendly/spendly_provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Generate Report'),
            onTap: () {
              Navigator.of(context).pop(); // Close settings dialog
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ReportPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Reset Data'),
            onTap: () {
              Navigator.of(context).pop(); // Close settings dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Reset'),
                  content: const Text('Are you sure you want to reset all data? This action cannot be undone.'),
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
                        Provider.of<SpendlyProvider>(context, listen: false).resetData();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Spendly',
                applicationVersion: '1.0',
                applicationLegalese: 'Developed by Heaven Sarder',
              );
            },
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
          child: const Text('Close'),
        ),
      ],
    );
  }
}
