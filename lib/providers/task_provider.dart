import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final Box box = Hive.box('taskBox');

  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  void loadTasks() {
    final data = box.get('tasks', defaultValue: []);
    _tasks = (data as List).map((e) {
      return Task(
        id: e['id'],
        title: e['title'],
        description: e['description'],
        dueDate: DateTime.parse(e['dueDate']),
        status: TaskStatus.values[e['status']],
      );
    }).toList();

    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));

    _tasks.add(task);
    saveToHive();
    notifyListeners();
  }

  void updateTask(Task updatedTask) async {
    await Future.delayed(const Duration(seconds: 2));

    int index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    _tasks[index] = updatedTask;

    saveToHive();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    saveToHive();
    notifyListeners();
  }

  void saveToHive() {
    final data = _tasks.map((t) {
      return {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'dueDate': t.dueDate.toIso8601String(),
        'status': t.status.index,
      };
    }).toList();

    box.put('tasks', data);
  }
}