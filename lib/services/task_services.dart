import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/tasks.dart';

// define a task service to handle firestore operations
class TaskService {
  // firestore instnace in a alias
  final FirebaseFirestore db = FirebaseFirestore.instance;
  // future returns a list of tasks using factory method defined in task class
  Future<List<Task>> fetchTask() async {
    // call get to retreve all of the documents inside the collections
    final snapshot = await db.collection('tasks').orderBy('timestamp').get();

    // snapshot of all documents is being mapped to factory object template
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList();
  }
}
