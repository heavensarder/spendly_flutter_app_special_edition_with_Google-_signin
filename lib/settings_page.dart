import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/report_page.dart';
import 'package:spendly/spendly_provider.dart';
import 'package:spendly/about_page.dart';
import 'package:spendly/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'upcoming_income_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final spendlyProvider = Provider.of<SpendlyProvider>(context);
    final user = _firebaseServices.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null)
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40, // Make the image larger
                      backgroundImage: NetworkImage(user.photoURL ?? ''),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.displayName ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.email ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          if (user == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final errorMessage = await _firebaseServices.signInWithGoogle();
                        if (errorMessage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Successfully signed in')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        }
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      icon: Image.asset('assets/images/google_logo.png', height: 24.0), // Using a local asset
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
            ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: const Text('Upcoming Income'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UpcomingIncomePage()),
                );
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.lightBlue),
              title: const Text('Generate Report'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.restore, color: Colors.redAccent),
              title: const Text('Reset Data'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
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
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          spendlyProvider.resetData();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10.0),
          Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: const Text('About'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ),
          if (user != null)
            const SizedBox(height: 10.0),
          if (user != null)
            ElevatedButton(
              onPressed: () async {
                await _firebaseServices.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out')),
                );
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
        ],
      ),
    );
  }
}
