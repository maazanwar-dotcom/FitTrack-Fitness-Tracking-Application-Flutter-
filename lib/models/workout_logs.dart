import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutLog {
  String id; // Firestore doc id
  String userId;
  DateTime date;
  int duration; // seconds
  double totalVolume;
  List<ExerciseLog> exercises;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.duration,
    required this.totalVolume,
    required this.exercises,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'totalVolume': totalVolume,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory WorkoutLog.fromMap(String id, Map<String, dynamic> map) {
    return WorkoutLog(
      id: id,
      userId: map['userId'],
      date: (map['date'] as Timestamp).toDate(),
      duration: map['duration'],
      totalVolume: (map['totalVolume'] as num).toDouble(),
      exercises: (map['exercises'] as List)
          .map((e) => ExerciseLog.fromMap(e))
          .toList(),
    );
  }
}

class ExerciseLog {
  String name;
  String notes;
  int restTimer; // seconds
  List<SetLog> sets;

  ExerciseLog({
    required this.name,
    required this.notes,
    required this.restTimer,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'notes': notes,
      'restTimer': restTimer,
      'sets': sets.map((s) => s.toMap()).toList(),
    };
  }

  factory ExerciseLog.fromMap(Map<String, dynamic> map) {
    return ExerciseLog(
      name: map['name'],
      notes: map['notes'],
      restTimer: map['restTimer'],
      sets: (map['sets'] as List).map((s) => SetLog.fromMap(s)).toList(),
    );
  }
}

class SetLog {
  double weight;
  int reps;
  bool completed;

  SetLog({required this.weight, required this.reps, required this.completed});

  Map<String, dynamic> toMap() {
    return {'weight': weight, 'reps': reps, 'completed': completed};
  }

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'],
      completed: map['completed'],
    );
  }
}
