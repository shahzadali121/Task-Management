import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:taskmangement/screens/splash%20Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'isCompleted': isCompleted};
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(title: map['title'], isCompleted: map['isCompleted']);
  }
}

class TaskHomeScreen extends StatefulWidget {
  const TaskHomeScreen({super.key});

  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      List<dynamic> decoded = jsonDecode(tasksJson);
      setState(() {
        tasks = decoded.map((e) => Task.fromMap(e)).toList();
      });
    }
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasksJson = jsonEncode(tasks.map((e) => e.toMap()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  void addTask(String title) {
    setState(() {
      tasks.add(Task(title: title));
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  void toggleComplete(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
    saveTasks();
  }

  void showAddTaskDialog() {
    String newTaskTitle = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter task title"),
          onChanged: (value) {
            newTaskTitle = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Add"),
            onPressed: () {
              if (newTaskTitle.trim().isNotEmpty) {
                addTask(newTaskTitle.trim());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add,color: Colors.white,),
            onPressed: showAddTaskDialog,
          )
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text(
          "No tasks yet. Add one!",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  tasks[index].isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: tasks[index].isCompleted ? Colors.green : Colors.grey,
                ),
                onPressed: () => toggleComplete(index),
              ),
              title: Text(
                tasks[index].title,
                style: TextStyle(
                  decoration: tasks[index].isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.blue),
                onPressed: () => deleteTask(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
