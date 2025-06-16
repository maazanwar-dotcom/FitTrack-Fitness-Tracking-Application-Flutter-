import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/RoutineModel.dart';

class RoutineFirestoreService {
  static String get uid => FirebaseAuth.instance.currentUser!.uid;
  static final routinesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('routines');

  static Future<void> addRoutine(Routine routine) async {
    await routinesRef.add(routine.toMap());
  }

  static Future<void> updateRoutine(Routine routine) async {
    await routinesRef.doc(routine.id).set(routine.toMap());
  }

  static Future<List<Routine>> fetchRoutines() async {
    final snapshot = await routinesRef.get();
    return snapshot.docs
        .map(
          (doc) => Routine.fromDoc(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<void> deleteRoutine(String id) async {
    await routinesRef.doc(id).delete();
  }
}
