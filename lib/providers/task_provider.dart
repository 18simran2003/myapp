import 'package:myapp/services/task_services.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/tasks.dart';
import 'package:flutter/material.dart';

// create a task provider to manange state
class TaskProvider extends ChangeNotifier {
  final TaskService taskService = TaskService();
  List<Task> tasks = [];

  //polulates tasks list/array with documents form database 
  // notifies the root provideer of stateful change
  Future<void> loadTasks() async {
    tasks = await taskService.fetchTask();
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    // check to see if name is not empty
    if (name.trim().isNotEmpty) {
      // add the trimmed task name to the database
      final id = await taskService.addTask(name);
      // adding the task name to the local list held in memory
      tasks.add(Task(id: id, name: name, completed: false));
      notifyListeners();
    }
  }

  Future<void> updateTask(int index, bool completed) async {
    // uses array index to find tasks
    final task = tasks[index];
    // update the task collection in the database by id, using bool for completed
    await taskService.updateTask(task.id, completed);
    // updating the local tasks list
    tasks[index] = Task(id: task.id, name: task.name, completed: completed);
    notifyListeners();
  }

  Future<void> removeTask(int index) async {
    // uses array index to find the task
    final task = tasks[index];
    // delete the task form the collection
    await taskService.deleteTasks(task.id);

    // remote the task form from the local in memory
    tasks.removeAt(index);
    notifyListeners();
  }
}