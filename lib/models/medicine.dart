import '../core/constants.dart';

class Medicine {
  final String id;
  final String name;
  final String quantity;
  final TimingRule timingRule;
  final MealTime mealTime;
  final int notificationHour;
  final int notificationMinute;
  DateTime? lastTakenDate;
  final List<String> images;
  final String? displayImagePath;
  // Use a List that can be modified
  final List<DateTime> logs;

  Medicine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.timingRule,
    required this.mealTime,
    required this.notificationHour,
    required this.notificationMinute,
    this.lastTakenDate,
    this.images = const [],
    this.displayImagePath,
    List<DateTime>? logs,
  }) : logs = logs ?? [];

  bool get isTakenToday {
    if (lastTakenDate == null) return false;
    final now = DateTime.now();
    return lastTakenDate!.year == now.year &&
        lastTakenDate!.month == now.month &&
        lastTakenDate!.day == now.day;
  }

  // Helper for JSON persistence
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'timingRule': timingRule.index,
        'mealTime': mealTime.index,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'lastTakenDate': lastTakenDate?.toIso8601String(),
        'images': images,
        'displayImagePath': displayImagePath,
        'logs': logs.map((log) => log.toIso8601String()).toList(),
      };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      timingRule: TimingRule.values[json['timingRule']],
      mealTime: MealTime.values[json['mealTime']],
      notificationHour: json['notificationHour'],
      notificationMinute: json['notificationMinute'],
      lastTakenDate: json['lastTakenDate'] != null 
          ? DateTime.parse(json['lastTakenDate']) 
          : null,
      images: List<String>.from(json['images'] ?? []),
      displayImagePath: json['displayImagePath'],
      logs: (json['logs'] as List?)
          ?.map((item) => DateTime.parse(item))
          .toList(),
    );
  }
}