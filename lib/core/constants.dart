// lib/core/constants.dart

enum MealTime {
  breakfast,
  lunch,
  snacks,
  tea,
  dinner,
}

enum TimingRule {
  beforeMeal,
  duringMeal,
  afterMeal,
}

// These extensions make it super easy to display clean text in the UI
extension MealTimeExtension on MealTime {
  String get displayName {
    switch (this) {
      case MealTime.breakfast: return "Breakfast";
      case MealTime.lunch: return "Lunch";
      case MealTime.snacks: return "Snacks";
      case MealTime.tea: return "Tea";
      case MealTime.dinner: return "Dinner";
    }
  }
}

extension TimingRuleExtension on TimingRule {
  String get displayName {
    switch (this) {
      case TimingRule.beforeMeal: return "Before Meal";
      case TimingRule.duringMeal: return "During Meal";
      case TimingRule.afterMeal: return "After Meal";
    }
  }
}