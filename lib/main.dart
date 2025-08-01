import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendly/spendly_provider.dart';
import 'package:spendly/add_money_dialog.dart';
import 'package:spendly/instant_spend_dialog.dart';
import 'package:spendly/add_spend_plan_dialog.dart';
import 'package:spendly/edit_spend_plan_dialog.dart';
import 'package:spendly/settings_page.dart'; // Changed from settings_dialog.dart
import 'package:spendly/models.dart';
import 'package:spendly/splash_screen.dart';
import 'package:spendly/edit_total_amount_dialog.dart';

import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpendlyProvider(),
      child: MaterialApp(
        title: 'Spendly',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFF898AC4, <int, Color>{
            50: Color(0xFFE7E8F2),
            100: Color(0xFFC3C4E0),
            200: Color(0xFFA2AADB),
            300: Color(0xFF898AC4),
            400: Color(0xFF7374B0),
            500: Color(0xFF5D5E9C),
            600: Color(0xFF474888),
            700: Color(0xFF313274),
            800: Color(0xFF1B1C60),
            900: Color(0xFF05064C),
          }),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF898AC4),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF898AC4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Slightly rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Minimal padding
              textStyle: const TextStyle(fontSize: 14), // Smaller text
              elevation: 0, // No shadow
              minimumSize: Size.zero, // Allow button to shrink to child size
              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
              alignment: Alignment.center, // Center the text
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            shadowColor: Color(0xFFA2AADB),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? _syncMessageSubscription;

  @override
  void initState() {
    super.initState();
    _syncMessageSubscription = Provider.of<SpendlyProvider>(context, listen: false)
        .syncMessages
        .listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  @override
  void dispose() {
    _syncMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF2E0),
      appBar: AppBar(
        title: Image.asset(
          'assets/images/topbar_icon.png',
          height: 40, // Adjust height as needed
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Amount Section
            Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Consumer<SpendlyProvider>(
                builder: (context, spendlyProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '৳${spendlyProvider.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: spendlyProvider.totalAmount < 0 ? Colors.red : Color(0xFF898AC4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Add Spend Plan', style: TextStyle(fontSize: 16)),
                            Switch(
                              value: spendlyProvider.addSpendPlanToggle,
                              onChanged: (value) {
                                spendlyProvider.toggleAddSpendPlan(value);
                              },
                              activeColor: Color(0xFF898AC4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Consumer<SpendlyProvider>(
                builder: (context, spendlyProvider, child) {
                  bool isAmountZero = spendlyProvider.totalAmount == 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const AddMoneyDialog(),
                            );
                          },
                          child: const Text('Add Money'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isAmountZero
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const InstantSpendDialog(),
                                  );
                                },
                          style: isAmountZero
                              ? ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.withOpacity(0.5),
                                )
                              : null,
                          child: const Text('Instant Spend'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isAmountZero
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const AddSpendPlanDialog(),
                                  );
                                },
                          style: isAmountZero
                              ? ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.withOpacity(0.5),
                                )
                              : null,
                          child: const Text('Spend Plan'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Tabbed Interface (Spend Plan & History)
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      height: 50, // Set a fixed height for the tab bar
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for the tab bar container
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners for the container
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab, // Make indicator span the full tab width
                        indicator: BoxDecoration(
                          color: Color(0xFF898AC4), // Indicator color
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners for the indicator
                        ),
                        labelColor: Colors.white, // White text for selected tab
                        unselectedLabelColor: Color(0xFF898AC4), // Primary color for unselected tab
                        labelStyle: TextStyle(fontWeight: FontWeight.bold), // Bold text for selected tab
                        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal), // Normal text for unselected tab
                        tabs: const [
                          Tab(text: 'Spend Plan'),
                          Tab(text: 'History'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Card(
                            child: Consumer<SpendlyProvider>(
                              builder: (context, spendlyProvider, child) {
                                return ListView.builder(
                                  itemCount: spendlyProvider.spendPlans.length,
                                  itemBuilder: (context, index) {
                                    final plan = spendlyProvider.spendPlans[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                                        ),
                                      ),
                                      child: Dismissible(
                                        key: Key(plan.title + plan.amount.toString()),
                                        background: Container(color: Colors.green, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.check, color: Colors.white)),
                                        secondaryBackground: Container(color: Colors.blue, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.edit, color: Colors.white)),
                                        confirmDismiss: (direction) async {
                                          if (direction == DismissDirection.startToEnd) {
                                            // Swipe to confirm
                                            return await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text("Confirm"),
                                                  content: const Text("Are you sure you want to execute this spend plan?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        spendlyProvider.confirmSpendPlan(plan);
                                                        Navigator.of(context).pop(true);
                                                      },
                                                      child: const Text("Confirm"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else if (direction == DismissDirection.endToStart) {
                                            // Swipe to edit
                                            showDialog(
                                              context: context,
                                              builder: (context) => EditSpendPlanDialog(spendPlan: plan),
                                            );
                                            return false;
                                          }
                                          return false;
                                        },
                                        child: ListTile(
                                          title: Text(plan.title, style: TextStyle(color: Colors.black)), // Black for spend plan
                                          subtitle: Text('৳${plan.amount.toStringAsFixed(2)} - ${plan.date.toLocal().toString().split(' ')[0]}'),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Card(
                            child: Consumer<SpendlyProvider>(
                              builder: (context, spendlyProvider, child) {
                                return ListView.builder(
                                  itemCount: spendlyProvider.history.length,
                                  itemBuilder: (context, index) {
                                    final item = spendlyProvider.history[index];
                                    Color itemColor;
                                    switch (item.type) {
                                      case 'add':
                                        itemColor = Colors.green;
                                        break;
                                      case 'instant':
                                        itemColor = Colors.red;
                                        break;
                                      case 'plan':
                                        itemColor = Colors.red; // Red for plan in history
                                        break;
                                      default:
                                        itemColor = Colors.black; // Default color
                                    }
                                    return ListTile(
                                      title: Text(item.description),
                                      subtitle: Text(
                                        '৳${item.amount.toStringAsFixed(2)} - ${item.date.toLocal().toString().split(' ')[0]} (${item.type})',
                                        style: TextStyle(color: itemColor),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Copyright © Heaven Sarder ${DateTime.now().year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}