import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  TaskStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    final tasks = provider.tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter =
          selectedStatus == null || task.status == selectedStatus;

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        centerTitle: true,
      ),

      // ➕ ADD TASK
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search tasks...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // 🔽 FILTER
          DropdownButton<TaskStatus>(
            hint: const Text("Filter by Status"),
            value: selectedStatus,
            items: TaskStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),

          // 📋 TASK LIST
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("No Tasks Found"))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      // 🔥 YOUR CARD CODE GOES HERE
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          title: Text(
                            task.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text(task.description),

                          leading: const Icon(Icons.task,
                              color: Colors.blue),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ✏️ EDIT
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TaskFormScreen(
                                              existingTask: task),
                                    ),
                                  );
                                },
                              ),

                              // ❌ DELETE
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  provider.deleteTask(task.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}