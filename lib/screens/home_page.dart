import 'dart:ffi'; // Import FFI (not used here)
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore DB
import 'package:flutter/material.dart'; // Flutter UI
import 'package:provider/provider.dart'; // State management
import 'package:table_calendar/table_calendar.dart'; // Calendar widget
import 'package:myapp/models/tasks.dart'; // Task model
import 'package:myapp/services/task_service.dart'; // Task services
import 'package:myapp/providers/task_provider.dart'; // Task provider

// This is a Home Page screen
class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  //  It's a field for controller input
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load tasks the task when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This is a Main app layout
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Logo
            Expanded(child: Image.asset('assets/rdplogo.png', height: 80)),
            //  text
            const Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      //It is a Page body
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Calendar
                  TableCalendar(
                    calendarFormat: CalendarFormat.month,
                    focusedDay: DateTime.now(),
                    firstDay: DateTime(2025),
                    lastDay: DateTime(2026),
                  ),

                  //
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      return buildTaskItem(
                        taskProvider.tasks,
                        taskProvider.removeTask,
                        taskProvider.updateTask,
                      );
                    },
                  ),

                  //We are Adding new task section
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      return buildAddTaskSection(nameController, () async {
                        // Add new task
                        await taskProvider.addTask(nameController.text);
                        nameController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(), // Side menu
    );
  }
}

//This is a Section for adding tasks
Widget buildAddTaskSection(nameController, addTask) {
  return Container(
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      children: [
        // Input field task name
        Expanded(
          child: Container(
            child: TextField(
              maxLength: 32,
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Add Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),

        // Adding a task button
        ElevatedButton(
          onPressed: addTask, // onPressed: When we clicked add task
          child: Text('Add Task'),
        ),
      ],
    ),
  );
}

//Build and Display task items
Widget buildTaskItem(
  List<Task> tasks, // Listing a tasks function
  Function(int) removeTasks, // removing a task function
  Function(int, bool) updateTask, // update function (mark complete/incomplete)
) {
  return ListView.builder(
    shrinkWrap: true, // Preventing a taking full screen space
    physics:
        const NeverScrollableScrollPhysics(), //we scrolling inside the parent
    itemCount: tasks.length, // task number
    itemBuilder: (context, index) {
      final task = tasks[index]; // Current task
      final isEven = index % 2 == 0; // For background color

      return Padding(
        padding: EdgeInsets.all(1.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: isEven ? Colors.blue : Colors.green,
          leading: Icon(
            // Check icon if completed, else empty circle
            task.completed ? Icons.check_circle : Icons.circle_outlined,
          ),
          title: Text(
            task.name, // Task name text
            style: TextStyle(
              // when it  completed, strike through text
              decoration: task.completed ? TextDecoration.lineThrough : null,
              fontSize: 22,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mark complete and also incomplete
              Checkbox(
                value: task.completed,
                // checkbox clicked updates task status
                onChanged: (value) => {updateTask(index, value!)},
              ),
              // Delete button
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => removeTasks(index), // onPressed: removing task
              ),
            ],
          ),
        ),
      );
    },
  );
}
