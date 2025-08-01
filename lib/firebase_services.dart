import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spendly/models.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Sign-in cancelled by user.'; // User cancelled the sign-in
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return null; // Success, no error message
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return 'Account already exists with a different sign-in method.';
      } else if (e.code == 'invalid-credential') {
        return 'Invalid Google credential. Please try again.';
      } else if (e.code == 'user-disabled') {
        return 'This user account has been disabled.';
      } else if (e.code == 'operation-not-allowed') {
        return 'Google Sign-In is not enabled for this Firebase project.';
      }
      return 'Sign-in failed: ${e.message}';
    } catch (e) {
      return 'An unknown error occurred: ${e.toString()}';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> syncToFirebase(String userId, double baseTotalAmount, bool addSpendPlanToggle, List<SpendPlan> spendPlans, List<HistoryItem> history, List<UpcomingIncome> upcomingIncomes) async {
    print('FirebaseServices: Syncing data...');
    final userDoc = _firestore.collection('users').doc(userId);

    await userDoc.set({
      'baseTotalAmount': baseTotalAmount,
      'addSpendPlanToggle': addSpendPlanToggle,
    });

    print('  - Synced baseTotalAmount: $baseTotalAmount');
    print('  - Synced addSpendPlanToggle: $addSpendPlanToggle');

    // Sync spend plans
    for (var plan in spendPlans) {
      await userDoc.collection('spend_plans').doc(plan.id.toString()).set(plan.toMap());
      print('  - Synced SpendPlan: ${plan.title}');
    }

    // Sync history
    for (var item in history) {
      await userDoc.collection('history_items').doc(item.id.toString()).set(item.toMap());
      print('  - Synced HistoryItem: ${item.description}');
    }

    // Sync upcoming incomes and their tasks
    for (var income in upcomingIncomes) {
      await userDoc.collection('upcoming_incomes').doc(income.id.toString()).set(income.toMap());
      print('  - Synced UpcomingIncome: ${income.title}');
      if (income.tasks != null) {
        for (var task in income.tasks!) {
          await userDoc.collection('upcoming_incomes').doc(income.id.toString()).collection('tasks').doc(task.id.toString()).set(task.toMap());
          print('    - Synced Task: ${task.title}');
        }
      }
    }
    print('FirebaseServices: Sync complete.');
  }

  Future<Map<String, dynamic>> getFromFirebase(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final userDocSnapshot = await userDoc.get();
    final spendPlansSnapshot = await userDoc.collection('spend_plans').get();
    final historySnapshot = await userDoc.collection('history_items').get();
    final upcomingIncomesSnapshot = await userDoc.collection('upcoming_incomes').get();

    final spendPlans = spendPlansSnapshot.docs.map((doc) => SpendPlan.fromMap(doc.data())).toList();
    final history = historySnapshot.docs.map((doc) => HistoryItem.fromMap(doc.data())).toList();
    final upcomingIncomes = <UpcomingIncome>[];

    for (var incomeDoc in upcomingIncomesSnapshot.docs) {
      final income = UpcomingIncome.fromMap(incomeDoc.data());
      final tasksSnapshot = await userDoc.collection('upcoming_incomes').doc(income.id.toString()).collection('tasks').get();
      income.tasks = tasksSnapshot.docs.map((taskDoc) => IncomeTask.fromMap(taskDoc.data())).toList();
      upcomingIncomes.add(income);
    }

    return {
      'baseTotalAmount': userDocSnapshot.data()?['baseTotalAmount'] ?? 0.0,
      'addSpendPlanToggle': userDocSnapshot.data()?['addSpendPlanToggle'] ?? false,
      'spendPlans': spendPlans,
      'history': history,
      'upcomingIncomes': upcomingIncomes,
    };
  }
}
