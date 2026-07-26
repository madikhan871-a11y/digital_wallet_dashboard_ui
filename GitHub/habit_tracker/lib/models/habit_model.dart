class Habit {
  int? id;
  String title;
  String description;
  bool isCompleted;

  // NEW
  int streak;
  String? lastCompletedDate;

  Habit({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.streak = 0,
    this.lastCompletedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'streak': streak,
      'lastCompletedDate': lastCompletedDate,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      streak: map['streak'] ?? 0,
      lastCompletedDate: map['lastCompletedDate'],
    );
  }
}