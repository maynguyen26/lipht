class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final DateTime date;
  final List<ExerciseModel> exercises;
  final String? notes;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.exercises,
    this.notes,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e))
          .toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }
}

class ExerciseModel {
  final String name;
  final List<SetModel> sets;

  ExerciseModel({
    required this.name,
    required this.sets,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      name: json['name'],
      sets: (json['sets'] as List)
          .map((e) => SetModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}

class SetModel {
  final double weight;
  final int reps;
  final int? rpe; // Rate of Perceived Exertion (optional)

  SetModel({
    required this.weight,
    required this.reps,
    this.rpe,
  });

  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      weight: json['weight'].toDouble(),
      reps: json['reps'],
      rpe: json['rpe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
    };
  }
}