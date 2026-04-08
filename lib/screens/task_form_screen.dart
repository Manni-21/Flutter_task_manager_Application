import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'dart:math';

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;

  const TaskFormScreen({super.key, this.existingTask});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // 🔹 Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // 🔹 Status
  TaskStatus selectedStatus = TaskStatus.todo;

  bool isLoading = false;

  // 🔹 Initialize (for Edit mode)
  @override
  void initState() {
    super.initState();

    if (widget.existingTask != null) {
      titleController.text = widget.existingTask!.title;
      descriptionController.text = widget.existingTask!.description;
      selectedStatus = widget.existingTask!.status;
    }
  }

  // 🔹 Save or Update Task
  void saveTask() async {
    if (isLoading) return;

    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final task = Task(
      id: widget.existingTask?.id ?? Random().nextDouble().toString(),
      title: titleController.text,
      description: descriptionController.text,
      dueDate: DateTime.now(),
      status: selectedStatus,
    );

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.existingTask != null) {
      // ✏️ UPDATE TASK
      provider.updateTask(task);
    } else {
      // ➕ ADD TASK
      await provider.addTask(task);
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask != null ? "Edit Task" : "Add Task"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Description
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 🔽 Status Dropdown
            DropdownButtonFormField<TaskStatus>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: "Select Status",
                border: OutlineInputBorder(),
              ),
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),

            const SizedBox(height: 25),

            // 🔹 Save Button
            ElevatedButton(
              onPressed: isLoading ? null : saveTask,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.existingTask != null
                      ? "Update Task"
                      : "Save Task"),
            ),
          ],
        ),
      ),
    );
  }
}