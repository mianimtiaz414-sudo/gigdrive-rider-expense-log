import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel {
  ExpenseModel({
    required this.id,
    required this.date,
    required this.earnings,
    required this.fuel,
    required this.otherRepairs,
    required this.mileage,
    this.synced = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double earnings;

  @HiveField(3)
  final double fuel;

  @HiveField(4)
  final double otherRepairs;

  @HiveField(5)
  final double mileage;

  @HiveField(6)
  bool synced;

  double get totalExpenses => fuel + otherRepairs;

  double get netProfit => earnings - totalExpenses;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'dateMillis': date.millisecondsSinceEpoch,
      'earnings': earnings,
      'fuel': fuel,
      'otherRepairs': otherRepairs,
      'mileage': mileage,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['dateMillis'] as int),
      earnings: (map['earnings'] as num).toDouble(),
      fuel: (map['fuel'] as num).toDouble(),
      otherRepairs: (map['otherRepairs'] as num).toDouble(),
      mileage: (map['mileage'] as num).toDouble(),
      synced: true,
    );
  }
}
