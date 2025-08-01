import 'package:flutter/material.dart';
import 'package:spendly/models.dart';
import 'package:spendly/database_helper.dart';
import 'package:spendly/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SpendlyProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseServices _firebaseServices = FirebaseServices();
  double _baseTotalAmount = 0.0;
  List<SpendPlan> _spendPlans = [];
  List<HistoryItem> _history = [];
  List<UpcomingIncome> _upcomingIncomes = [];
  bool _addSpendPlanToggle = false;
  bool _isLoggedIn = false;

  final _syncMessageController = StreamController<String>.broadcast();
  Stream<String> get syncMessages => _syncMessageController.stream;

  SpendlyProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _isLoggedIn = true;
        _loadFromFirebase(user.uid);
      } else {
        _isLoggedIn = false;
        _loadFromLocal();
      }
    });
  }

  @override
  void dispose() {
    _syncMessageController.close();
    super.dispose();
  }

  Future<void> _loadFromLocal() async {
    final appData = await _dbHelper.getAppData();
    if (appData != null) {
      _baseTotalAmount = appData['baseTotalAmount'] ?? 0.0;
      _addSpendPlanToggle = (appData['addSpendPlanToggle'] ?? 0) == 1;
    }
    _spendPlans = await _dbHelper.getSpendPlans();
    _history = await _dbHelper.getHistoryItems();
    _upcomingIncomes = await _dbHelper.getUpcomingIncomes();
    notifyListeners();
  }

  Future<void> _loadFromFirebase(String userId) async {
    // Clear local data to prevent conflicts
    await _dbHelper.clearAllData();
    _baseTotalAmount = 0.0;
    _spendPlans = [];
    _history = [];
    _upcomingIncomes = [];
    _addSpendPlanToggle = false;

    final data = await _firebaseServices.getFromFirebase(userId);
    _baseTotalAmount = data['baseTotalAmount'];
    _addSpendPlanToggle = data['addSpendPlanToggle'];
    _spendPlans = data['spendPlans'];
    _history = data['history'];
    _upcomingIncomes = data['upcomingIncomes'];

    // Save the fetched data to the local database
    await _dbHelper.insertAppData(_baseTotalAmount, _addSpendPlanToggle);
    for (var plan in _spendPlans) {
      await _dbHelper.insertSpendPlan(plan);
    }
    for (var item in _history) {
      await _dbHelper.insertHistoryItem(item);
    }
    for (var income in _upcomingIncomes) {
      await _dbHelper.insertUpcomingIncome(income);
      if (income.tasks != null) {
        for (var task in income.tasks!) {
          await _dbHelper.insertIncomeTask(task);
        }
      }
    }

    notifyListeners();
    _syncMessageController.add('Data loaded from cloud.');
  }

  Future<void> _syncData() async {
    final user = _firebaseServices.getCurrentUser();
    if (user != null) {
      print('Syncing data to Firebase for user: ${user.uid}');
      await _firebaseServices.syncToFirebase(user.uid, _baseTotalAmount, _addSpendPlanToggle, _spendPlans, _history, _upcomingIncomes);
      _syncMessageController.add('Data synced to cloud.');
    } else {
      print('User not logged in, not syncing data.');
    }
  }

  double get _spendPlansTotal {
    return _spendPlans.fold(0.0, (sum, plan) => sum + plan.amount);
  }

  double get totalAmount {
    if (_addSpendPlanToggle) {
      return _baseTotalAmount - _spendPlansTotal;
    } else {
      return _baseTotalAmount;
    }
  }

  List<UpcomingIncome> get upcomingIncomes => _upcomingIncomes;
  List<SpendPlan> get spendPlans => _spendPlans;
  List<HistoryItem> get history => _history;
  bool get addSpendPlanToggle => _addSpendPlanToggle;

  void addMoney(double amount, {String? sourceDescription}) async {
    _baseTotalAmount += amount;
    notifyListeners(); // Notify UI immediately

    final description = sourceDescription != null ? 'Added Money ' + sourceDescription : 'Added Money';
    final historyItem = HistoryItem(description: description, amount: amount, date: DateTime.now(), type: 'add');
    final id = await _dbHelper.insertHistoryItem(historyItem);
    historyItem.id = id;
    _history.add(historyItem);
    await _dbHelper.insertAppData(_baseTotalAmount, _addSpendPlanToggle);
    await _syncData();
    // No need to notify again, history will be updated on next load if needed
  }

  void instantSpend(double amount, String description) async {
    _baseTotalAmount -= amount;
    notifyListeners();

    final historyItem = HistoryItem(description: description, amount: amount, date: DateTime.now(), type: 'instant');
    final id = await _dbHelper.insertHistoryItem(historyItem);
    historyItem.id = id;
    _history.add(historyItem);
    await _dbHelper.insertAppData(_baseTotalAmount, _addSpendPlanToggle);
    await _syncData();
  }

  void addSpendPlan(SpendPlan plan) async {
    _spendPlans.add(plan);
    notifyListeners();

    final id = await _dbHelper.insertSpendPlan(plan);
    plan.id = id;
    await _syncData();
  }

  void addUpcomingIncome(UpcomingIncome income) async {
    income.tasks = []; // Initialize tasks list for new income
    _upcomingIncomes.add(income);
    notifyListeners();

    final id = await _dbHelper.insertUpcomingIncome(income);
    income.id = id;
    await _syncData();
  }

  void addIncomeTask(int incomeSourceId, IncomeTask task) async {
    for (var income in _upcomingIncomes) {
      if (income.id == incomeSourceId) {
        income.tasks ??= [];
        income.tasks!.add(task);
        notifyListeners();
        break;
      }
    }

    final id = await _dbHelper.insertIncomeTask(task);
    task.id = id;
    await _syncData();
  }

  void confirmSpendPlan(SpendPlan plan) async {
    _baseTotalAmount -= plan.amount;
    _spendPlans.remove(plan);
    notifyListeners();

    final historyItem = HistoryItem(description: plan.title, amount: plan.amount, date: DateTime.now(), type: 'plan');
    await _dbHelper.deleteSpendPlan(plan.id!); // Assuming id is not null after insertion
    final id = await _dbHelper.insertHistoryItem(historyItem);
    historyItem.id = id;
    _history.add(historyItem);
    await _dbHelper.insertAppData(_baseTotalAmount, _addSpendPlanToggle);
    await _syncData();
  }

  void editSpendPlan(SpendPlan oldPlan, String newTitle, double newAmount) async {
    final index = _spendPlans.indexOf(oldPlan);
    if (index != -1) {
      _spendPlans[index].title = newTitle;
      _spendPlans[index].amount = newAmount;
      notifyListeners();
      await _dbHelper.updateSpendPlan(_spendPlans[index]);
      await _syncData();
    }
  }

  void editIncomeTask(IncomeTask oldTask, String newTitle, double newAmount) async {
    for (var incomeSource in _upcomingIncomes) {
      if (incomeSource.id == oldTask.incomeSourceId) {
        if (incomeSource.tasks != null) {
          final taskIndex = incomeSource.tasks!.indexWhere((task) => task.id == oldTask.id);
          if (taskIndex != -1) {
            incomeSource.tasks![taskIndex].title = newTitle;
            incomeSource.tasks![taskIndex].amount = newAmount;
            notifyListeners();
            break;
          }
        }
      }
    }

    oldTask.title = newTitle;
    oldTask.amount = newAmount;

    await _dbHelper.updateIncomeTask(oldTask);
    await _syncData();
  }

  void toggleAddSpendPlan(bool value) async {
    _addSpendPlanToggle = value;
    notifyListeners();
    await _dbHelper.insertAppData(_baseTotalAmount, _addSpendPlanToggle);
    await _syncData();
  }

  void resetData() async {
    _baseTotalAmount = 0.0;
    _spendPlans = [];
    _history = [];
    _upcomingIncomes = []; // Clear upcoming incomes on reset
    _addSpendPlanToggle = false;
    notifyListeners();
    await _dbHelper.clearAllData();
    await _syncData();
  }

  void deleteUpcomingIncome(int id) async {
    _upcomingIncomes.removeWhere((income) => income.id == id);
    notifyListeners();
    await _dbHelper.deleteUpcomingIncome(id);
    await _dbHelper.deleteIncomeTasks(id);
    await _syncData();
  }

  void setTotalAmount(double newAmount) async {
    _baseTotalAmount = newAmount;
    notifyListeners();
    await _dbHelper.insertAppData(_baseTotalAmount, _addSpendPlanToggle);
    await _syncData();
  }
}
