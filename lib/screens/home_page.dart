import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//blueprint for task
class Task {
  final String id;
  final String name;
  final bool completed;

  Task({required this.id, required this.name, required this.completed});

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'] ?? '',
      completed: data['completed'] ?? false,
    );
  }
}

//Define a Task Service to handle Firestore operationss
class TaskService {
  //Firestore instance in an alias
  final FirebaseFirestore db = FirebaseFirestore.instance;

  //Future that returns a list of tasks using factory method defined in Task class
  Future<List<Task>> fetchTasks() async {
    //call get to retrieve all of the documents inside the collection
    final snapshot = await db.collection('tasks').orderBy('timestamp').get();
    //snapshot of all documents is being mapped to factory object template
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList();
  }

  //another asynchronous Future to add tasks to the firestore
  Future<String> addTask(String name) async {
    final newTask = {
      'name': name,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    };
    final docRef = await db.collection('tasks').add(newTask);
    return docRef.id;
  }

  //update task future
  Future<void> updateTask(String id, bool completed) async {
    await db.collection('tasks').doc(id).update({'completed': completed});
  }

  //Future is going to delete tasks
  Future<void> deleteTasks(String id) async {
    await db.collection('tasks').doc(id).delete();
  }
}

//create a task provider to manage state
class TaskProvider extends ChangeNotifier {
  final TaskService taskService = TaskService();
  List<Task> tasks = [];

  //populates tasks list/array with documents from database
  //notifies the root provider of stateful change
  Future<void> loadTasks() async {
    tasks = await taskService.fetchTasks();
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    //check to see if name is not empty or null
    if (name.trim().isNotEmpty) {
      //add the trimmed task name to the database
      final id = await taskService.addTask(name.trim());
      //adding the task name to the local list held in memory
      tasks.add(Task(id: id, name: name, completed: false));
      notifyListeners();
    }
  }

  Future<void> updateTask(int index, bool completed) async {
    //uses array index to find tasks
    final task = tasks[index];
    //update the task collection in the database by id, using bool for completed
    await taskService.updateTask(task.id, completed);
    //updating the local tasks list
    tasks[index] = Task(id: task.id, name: task.name, completed: completed);
    notifyListeners();
  }

  Future<void> removeTask(int index) async {
    //users arrav index to find tasks
    final task = tasks[index];
    //delete the task from the collection
    await taskService.deleteTasks(task.id);
    //remove the task from the local list
    tasks.removeAt(index);
    notifyListeners();
  }
}

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Image.asset('/rdplogo.png')),
            const Text('Daily Planner'),
          ],
        ),
      ),
    ); 
  }
}
