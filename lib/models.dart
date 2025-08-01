class SpendPlan {
  int? id;
  String title;
  double amount;
  DateTime date;

  SpendPlan({this.id, required this.title, required this.amount, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory SpendPlan.fromMap(Map<String, dynamic> map) {
    return SpendPlan(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}

class HistoryItem {
  int? id;
  String description;
  double amount;
  DateTime date;
  String type; // 'instant' or 'plan'

  HistoryItem({this.id, required this.description, required this.amount, required this.date, required this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'type': type,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: map['type'],
    );
  }
}

class UpcomingIncome {
  int? id;
  String title;
  List<IncomeTask>? tasks; // Added tasks property

  UpcomingIncome({this.id, required this.title, this.tasks});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory UpcomingIncome.fromMap(Map<String, dynamic> map) {
    return UpcomingIncome(
      id: map['id'],
      title: map['title'],
      // tasks will be loaded separately
    );
  }
}

class IncomeTask {
  int? id;
  int incomeSourceId;
  String title;
  double amount;

  IncomeTask({this.id, required this.incomeSourceId, required this.title, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'incomeSourceId': incomeSourceId,
      'title': title,
      'amount': amount,
    };
  }

  factory IncomeTask.fromMap(Map<String, dynamic> map) {
    return IncomeTask(
      id: map['id'],
      incomeSourceId: map['incomeSourceId'],
      title: map['title'],
      amount: map['amount'],
    );
  }
}
