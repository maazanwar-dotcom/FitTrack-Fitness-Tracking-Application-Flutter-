import 'package:flutter/material.dart';

// Dummy routine data structure for UI demonstration
class Routine {
  final String title;
  final String summary;
  Routine({required this.title, required this.summary});
}

// Replace with your real navigation function to CreateRoutineScreen
void navigateToCreateRoutine(BuildContext context) {
  // Navigator.push(context, MaterialPageRoute(builder: (_) => CreateRoutineScreen()));
  // TODO: Implement this with your route
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final List<Routine> routines = [
    Routine(
      title: "Chest + Tricep",
      summary:
          "Bench Press (Barbell), Incline Bench Press (Dumbbell), Chest Fly (Machine)",
    ),
    Routine(
      title: "Leg day",
      summary:
          "Hack Squat (Machine), Leg Extension (Machine), Lunge (Dumbbell)",
    ),
    Routine(
      title: "Shoulders",
      summary: "Overhead Press, Lateral Raise, Front Raise",
    ),
    Routine(
      title: "Back + Biceps",
      summary: "Pull Up, Barbell Row, Bicep Curl",
    ),
  ];

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
                  color: Colors.yellow[700],
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
      body: ListView(
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
                onPressed: () {
                  // Optionally: create a new routine (same as 'New Routine')
                  navigateToCreateRoutine(context);
                },
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
                  onPressed: () {
                    navigateToCreateRoutine(context);
                  },
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
                        routine.summary,
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
                                  // TODO: Start this routine
                                },
                                child: const Text("Start Routine"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {
                              // TODO: More actions (edit, delete, etc.)
                            },
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Workout tab is active
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
        onTap: (index) {
          // TODO: Implement navigation between tabs
        },
      ),
    );
  }
}
