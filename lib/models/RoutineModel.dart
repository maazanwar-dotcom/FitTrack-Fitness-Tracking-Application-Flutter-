class Routine {
  final String id;
  final String title;
  final List<RoutineExercise> exercises;

  Routine({required this.id, required this.title, required this.exercises});

  Map<String, dynamic> toMap() => {
    'title': title,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };

  factory Routine.fromDoc(String id, Map<String, dynamic> doc) => Routine(
    id: id,
    title: doc['title'],
    exercises:
        (doc['exercises'] as List<dynamic>?)
            ?.map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class RoutineExercise {
  final Map<String, dynamic> exercise; // serialized
  final List<Map<String, dynamic>> sets; // each: {kg, reps}

  RoutineExercise({required this.exercise, required this.sets});

  Map<String, dynamic> toMap() => {'exercise': exercise, 'sets': sets};

  factory RoutineExercise.fromMap(Map<String, dynamic> map) => RoutineExercise(
    exercise: Map<String, dynamic>.from(map['exercise']),
    sets:
        (map['sets'] as List<dynamic>?)
            ?.map((s) => Map<String, dynamic>.from(s))
            .toList() ??
        [],
  );
}
