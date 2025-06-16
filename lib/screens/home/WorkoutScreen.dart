import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fittrack/screens/create_routine.dart';
import 'package:fittrack/screens/profile_screen.dart';
import 'package:fittrack/models/RoutineModel.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final String uid;
  late final CollectionReference routinesRef;
  late Stream<QuerySnapshot> _routineStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User not logged in. You can handle logout or redirect here.
      // For now, just throw.
      throw Exception("User not logged in");
    }
    uid = user.uid;
    routinesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('routines');
    _routineStream = routinesRef.snapshots();
  }

  Future<void> _navigateToCreateRoutine() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEditRoutineScreen()),
    );
    if (created == true) {
      setState(() {}); // Refresh stream if needed
    }
  }

  Future<void> _navigateToEditRoutine(Routine routine) async {
    final edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEditRoutineScreen(routine: routine),
      ),
    );
    if (edited == true) {
      setState(() {});
    }
  }

  void _onMoreRoutineActions(Routine routine) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Routine"),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditRoutine(routine);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete Routine"),
              onTap: () async {
                Navigator.pop(context);
                await routinesRef.doc(routine.id).delete();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Routine deleted")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  int _currentIndex = 1; // Workout tab is active

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
    // Home tab not implemented, stay on WorkoutScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Workout",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "PRO",
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.person, color: Colors.black),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _routineStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          final routines = docs
              .map(
                (doc) =>
                    Routine.fromDoc(doc.id, doc.data() as Map<String, dynamic>),
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 16),
              const Text(
                "Quick Start",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.add, color: Colors.black, size: 28),
                  title: const Text(
                    'Start Empty Workout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // TODO: Handle empty workout start
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Routines",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined),
                    onPressed: _navigateToCreateRoutine,
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text("New Routine"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _navigateToCreateRoutine,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text("Explore"),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        // TODO: Implement Explore action
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                "My Routines (${routines.length})",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (routines.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No routines yet.\nTap 'New Routine' to create one!",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ...routines.map(
                (routine) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRoutineSummary(routine),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      // TODO: Start this routine (show detail or begin workout)
                                    },
                                    child: const Text("Start Routine"),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () => _onMoreRoutineActions(routine),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: "Workout",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
        onTap: _onTabTapped,
      ),
    );
  }

  // Helper to get routine summary from Firestore structure
  String _getRoutineSummary(Routine routine) {
    // If you stored exercises as a list of maps with "name" keys
    try {
      final exercises = routine.exercises;
      return exercises
          .map((rx) {
            final name = (rx.exercise['name'] ?? '').toString();
            return name;
          })
          .where((s) => s.isNotEmpty)
          .take(3)
          .join(', ');
    } catch (_) {
      return "";
    }
  }
}
