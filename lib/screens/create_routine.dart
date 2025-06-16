import 'package:fittrack/models/ExcerciseModel.dart';
import 'package:fittrack/models/RoutineModel.dart';
import 'package:fittrack/screens/excercises/excercise_list_screen.dart';
import 'package:fittrack/services/RoutineFirestoreService.dart';
import 'package:flutter/material.dart';

class CreateEditRoutineScreen extends StatefulWidget {
  final Routine? routine; // If null, it's a new routine

  const CreateEditRoutineScreen({Key? key, this.routine}) : super(key: key);

  @override
  State<CreateEditRoutineScreen> createState() =>
      _CreateEditRoutineScreenState();
}

class _CreateEditRoutineScreenState extends State<CreateEditRoutineScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<_RoutineExerciseEntry> _routineExercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.routine != null) {
      _titleController.text = widget.routine!.title;
      for (final rx in widget.routine!.exercises) {
        _routineExercises.add(
          _RoutineExerciseEntry(
            exercise: Exercise.fromJson(rx.exercise),
            sets: rx.sets
                .map(
                  (s) => {
                    'kg': s['kg'].toString(),
                    'reps': s['reps'].toString(),
                  },
                )
                .toList(),
          ),
        );
      }
    }
  }

  void _addExercise() async {
    final Exercise? selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExerciseListScreen()),
    );
    if (selected != null) {
      setState(() {
        _routineExercises.add(
          _RoutineExerciseEntry(
            exercise: selected,
            sets: [
              {'kg': '', 'reps': ''},
            ],
          ),
        );
      });
    }
  }

  void _addSet(int index) {
    setState(() {
      _routineExercises[index].sets.add({'kg': '', 'reps': ''});
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _routineExercises.removeAt(index);
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _routineExercises[exerciseIndex].sets.removeAt(setIndex);
    });
  }

  Future<void> _saveRoutine() async {
    if (_titleController.text.trim().isEmpty || _routineExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and at least one exercise required'),
        ),
      );
      return;
    }
    final routine = Routine(
      id: widget.routine?.id ?? '',
      title: _titleController.text.trim(),
      exercises: _routineExercises
          .map(
            (re) => RoutineExercise(
              exercise: re.exercise.toJson(),
              sets: re.sets
                  .map((s) => {'kg': s['kg'], 'reps': s['reps']})
                  .toList(),
            ),
          )
          .toList(),
    );
    if (widget.routine == null) {
      await RoutineFirestoreService.addRoutine(routine);
    } else {
      await RoutineFirestoreService.updateRoutine(routine);
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final hasExercises = _routineExercises.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        title: Text(
          widget.routine == null ? "Create Routine" : "Edit Routine",
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            child: const Text(
              "Save",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              decoration: const InputDecoration(
                hintText: "Routine title",
                border: InputBorder.none,
              ),
            ),
            if (!hasExercises)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Get started by adding an exercise to your routine.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add exercise"),
                        onPressed: _addExercise,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasExercises)
              Expanded(
                child: ListView.separated(
                  itemCount: _routineExercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, i) {
                    final entry = _routineExercises[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fitness_center, size: 26),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.exercise.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[300],
                                  ),
                                  onPressed: () => _removeExercise(i),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: const [
                                Text(
                                  "SET",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 36),
                                Text(
                                  "KG",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 36),
                                Text(
                                  "REPS",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            ...List.generate(entry.sets.length, (j) {
                              final set = entry.sets[j];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      child: Text('${j + 1}'),
                                    ),
                                    const SizedBox(width: 24),
                                    SizedBox(
                                      width: 60,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: "-",
                                          isDense: true,
                                        ),
                                        onChanged: (val) => set['kg'] = val,
                                        controller: TextEditingController(
                                          text: set['kg'],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    SizedBox(
                                      width: 60,
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: "-",
                                          isDense: true,
                                        ),
                                        onChanged: (val) => set['reps'] = val,
                                        controller: TextEditingController(
                                          text: set['reps'],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red[200],
                                        size: 20,
                                      ),
                                      onPressed: entry.sets.length > 1
                                          ? () => _removeSet(i, j)
                                          : null,
                                    ),
                                  ],
                                ),
                              );
                            }),
                            OutlinedButton.icon(
                              onPressed: () => _addSet(i),
                              icon: const Icon(Icons.add),
                              label: const Text("Add Set"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (hasExercises)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add exercise"),
                onPressed: _addExercise,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper for screen state
class _RoutineExerciseEntry {
  final Exercise exercise;
  final List<Map<String, String>> sets; // each: {kg, reps}
  _RoutineExerciseEntry({required this.exercise, required this.sets});
}
