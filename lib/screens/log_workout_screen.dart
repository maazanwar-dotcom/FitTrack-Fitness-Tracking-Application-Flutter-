import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../models/RoutineModel.dart';

class LogWorkoutScreen extends StatefulWidget {
  final Routine routine;
  const LogWorkoutScreen({super.key, required this.routine});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  late DateTime startTime;
  late Timer _timer;
  int duration = 0;
  bool _saving = false;
  List<_ExerciseLog> _exercises = [];
  Map<String, List<_PrevSet>> _prevSets = {}; // exerciseName -> list of sets

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _exercises = widget.routine.exercises
        .map((rx) => _ExerciseLog.fromRoutine(rx))
        .toList();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => duration++);
    });
    _fetchPreviousLogs();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final e in _exercises) {
      for (final c in e.setControllers) {
        for (final controller in c) {
          controller.dispose();
        }
      }
    }
    super.dispose();
  }

  double get totalVolume {
    double v = 0;
    for (final e in _exercises) {
      for (final s in e.sets) {
        if (s.completed && s.kg != null && s.reps != null)
          v += (s.kg!) * (s.reps!);
      }
    }
    return v;
  }

  int get totalSets =>
      _exercises.fold(0, (p, e) => p + e.sets.where((s) => s.completed).length);

  Future<void> _fetchPreviousLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final histSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workout_history')
        .orderBy('date', descending: true)
        .get();

    Map<String, List<_PrevSet>> prev = {};
    for (final e in _exercises) {
      for (final doc in histSnap.docs) {
        final exercises = (doc['exercises'] as List?) ?? [];
        final prevExercise = exercises.firstWhere(
          (ex) => ex['name'] == e.name,
          orElse: () => null,
        );
        if (prevExercise != null) {
          final sets = (prevExercise['sets'] as List?) ?? [];
          prev[e.name] = List.generate(sets.length, (i) {
            final s = sets[i];
            return _PrevSet(
              kg: (s['kg'] as num?)?.toDouble(),
              reps: (s['reps'] as num?)?.toInt(),
            );
          });
          break;
        }
      }
    }
    setState(() {
      _prevSets = prev;
    });
  }

  Future<void> _saveWorkout() async {
    setState(() => _saving = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final data = {
      'userId': user.uid,
      'routineId': widget.routine.id,
      'routineTitle': widget.routine.title,
      'date': Timestamp.fromDate(startTime),
      'duration': duration,
      'totalVolume': totalVolume,
      'exercises': _exercises.map((e) => e.toMap()).toList(),
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workout_history')
        .add(data);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _discardWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure you want to discard this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Discard Workout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) Navigator.pop(context, false);
  }

  Future<void> _addExercise() async {
    final TextEditingController ctrl = TextEditingController();
    final added = await showDialog<_ExerciseLog>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Exercise'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Exercise name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(
                ctx,
                _ExerciseLog(
                  name: ctrl.text.trim(),
                  notes: '',
                  restTimerSecs: 90,
                  sets: [SetLog()],
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (added != null) setState(() => _exercises.add(added));
    await _fetchPreviousLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _discardWorkout),
        title: const Text('Log Workout', style: TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {}, // Could show a global timer if needed
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: _saving ? null : _saveWorkout,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Finish'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top summary bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryTile(label: "Duration", value: "${duration}s"),
                _SummaryTile(
                  label: "Volume",
                  value: "${totalVolume.toStringAsFixed(1)} kg",
                ),
                _SummaryTile(label: "Sets", value: "$totalSets"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, idx) => _ExerciseCard(
                exercise: _exercises[idx],
                previousSets: _prevSets[_exercises[idx].name] ?? [],
                onChanged: (updated) =>
                    setState(() => _exercises[idx] = updated),
                onAddSet: () => setState(() => _exercises[idx].addSet()),
                onRestTimerPressed: (setIdx) async {
                  final newRest = await showModalBottomSheet<int>(
                    context: context,
                    builder: (ctx) => _RestTimerPicker(
                      initial: _exercises[idx].restTimerSecs,
                    ),
                  );
                  if (newRest != null)
                    setState(() => _exercises[idx].restTimerSecs = newRest);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _discardWorkout,
                    child: const Text(
                      'Discard Workout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addExercise,
                    child: const Text('+ Add Exercise'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label, value;
  const _SummaryTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final _ExerciseLog exercise;
  final List<_PrevSet> previousSets;
  final ValueChanged<_ExerciseLog> onChanged;
  final VoidCallback onAddSet;
  final void Function(int setIdx) onRestTimerPressed;
  const _ExerciseCard({
    required this.exercise,
    required this.previousSets,
    required this.onChanged,
    required this.onAddSet,
    required this.onRestTimerPressed,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  List<Timer?> _restTimers = [];
  List<int> _restRemaining = [];

  @override
  void initState() {
    super.initState();
    _restTimers = List.filled(widget.exercise.sets.length, null);
    _restRemaining = List.filled(widget.exercise.sets.length, 0);
  }

  @override
  void didUpdateWidget(covariant _ExerciseCard oldWidget) {
    if (widget.exercise.sets.length != _restTimers.length) {
      _restTimers.length = widget.exercise.sets.length;
      _restRemaining.length = widget.exercise.sets.length;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onCheckSet(int idx, bool? value) {
    setState(() {
      widget.exercise.sets[idx].completed = value ?? false;
      widget.onChanged(widget.exercise);
    });
    if (value == true) {
      _restTimers[idx]?.cancel();
      _restRemaining[idx] = widget.exercise.restTimerSecs;
      _restTimers[idx] = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          if (_restRemaining[idx] > 0) {
            _restRemaining[idx]--;
          }
          if (_restRemaining[idx] == 0) {
            t.cancel();
            FlutterRingtonePlayer().playNotification();
          }
        });
      });
    } else {
      _restTimers[idx]?.cancel();
      _restRemaining[idx] = 0;
    }
  }

  @override
  void dispose() {
    for (final t in _restTimers) {
      t?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sets = widget.exercise.sets;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(
                widget.exercise.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextField(
                decoration: const InputDecoration(
                  hintText: "Add notes here...",
                ),
                controller: widget.exercise.notesController,
                onChanged: (v) {
                  widget.exercise.notes = v;
                  widget.onChanged(widget.exercise);
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {}, // future: menu
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4),
              child: TextButton.icon(
                onPressed: () => widget.onRestTimerPressed(0),
                icon: const Icon(Icons.timer_outlined, size: 18),
                label: Text(
                  "Rest Timer: ${widget.exercise.restTimerSecs ~/ 60}min ${widget.exercise.restTimerSecs % 60}s",
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: const [
                  SizedBox(
                    width: 24,
                    child: Text(
                      "SET",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      "PREVIOUS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 60,
                    child: Text(
                      "KG",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      "REPS",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      "✔",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      "REST",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(sets.length, (setIdx) {
              final set = sets[setIdx];
              final prev = (setIdx < widget.previousSets.length)
                  ? widget.previousSets[setIdx]
                  : null;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                child: Row(
                  children: [
                    SizedBox(width: 24, child: Text("${setIdx + 1}")),
                    SizedBox(
                      width: 70,
                      child: Text(
                        prev != null && prev.kg != null && prev.reps != null
                            ? "${prev.kg!.toStringAsFixed(1)} x ${prev.reps}"
                            : "-",
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: widget.exercise.setControllers[setIdx][0],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        onChanged: (val) {
                          set.kg = double.tryParse(val);
                          widget.onChanged(widget.exercise);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: widget.exercise.setControllers[setIdx][1],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                        onChanged: (val) {
                          set.reps = int.tryParse(val);
                          widget.onChanged(widget.exercise);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: set.completed,
                        onChanged: (val) => _onCheckSet(setIdx, val),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: _restRemaining[setIdx] > 0
                          ? Text(
                              "${_restRemaining[setIdx] ~/ 60}:${(_restRemaining[setIdx] % 60).toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 6),
              child: TextButton(
                onPressed: widget.onAddSet,
                child: const Text('+ Add Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestTimerPicker extends StatefulWidget {
  final int initial;
  const _RestTimerPicker({required this.initial});
  @override
  State<_RestTimerPicker> createState() => _RestTimerPickerState();
}

class _RestTimerPickerState extends State<_RestTimerPicker> {
  late int timeSecs;
  @override
  void initState() {
    super.initState();
    timeSecs = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Rest Timer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 36,
              scrollController: FixedExtentScrollController(
                initialItem: (timeSecs ~/ 5) - 12,
              ), // e.g. 60s = 12th
              onSelectedItemChanged: (i) =>
                  setState(() => timeSecs = (i + 12) * 5),
              children: List.generate(60, (i) {
                final s = (i + 12) * 5;
                return Text('${s ~/ 60}min ${s % 60}s');
              }),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, timeSecs),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// --- Model helpers for this screen only ---

class _ExerciseLog {
  final String name;
  String notes;
  int restTimerSecs; // mutable for simplicity
  List<SetLog> sets;
  late List<List<TextEditingController>> setControllers;
  late TextEditingController notesController;

  _ExerciseLog({
    required this.name,
    required this.notes,
    required this.restTimerSecs,
    required this.sets,
  }) {
    notesController = TextEditingController(text: notes);
    setControllers = sets
        .map(
          (set) => [
            TextEditingController(text: set.kg?.toString() ?? ''),
            TextEditingController(text: set.reps?.toString() ?? ''),
          ],
        )
        .toList();
  }

  factory _ExerciseLog.fromRoutine(RoutineExercise rx) {
    final sets = rx.sets.map((s) {
      return SetLog(
        kg: double.tryParse(s['kg'].toString()),
        reps: int.tryParse(s['reps'].toString()),
      );
    }).toList();
    return _ExerciseLog(
      name: rx.exercise['name'] ?? 'Exercise',
      notes: '',
      restTimerSecs: 90,
      sets: sets,
    );
  }

  void addSet() {
    sets.add(SetLog());
    setControllers.add([TextEditingController(), TextEditingController()]);
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'notes': notes,
    'restTimer': restTimerSecs,
    'sets': sets.map((s) => s.toMap()).toList(),
  };
}

class SetLog {
  double? kg;
  int? reps;
  bool completed;
  SetLog({this.kg, this.reps, this.completed = false});

  Map<String, dynamic> toMap() => {
    'kg': kg,
    'reps': reps,
    'completed': completed,
  };
}

class _PrevSet {
  final double? kg;
  final int? reps;
  _PrevSet({this.kg, this.reps});
}
