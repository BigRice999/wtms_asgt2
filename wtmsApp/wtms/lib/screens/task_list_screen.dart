import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'submit_completion_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String workerId;
  const TaskListScreen({super.key, required this.workerId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  // Fetch tasks assigned to the current worker from backend API.
  // Sends a POST request to the server with worker_id,
  // decodes the JSON response, and updates the UI with task list.
  Future<void> _fetchTasks() async {
    try {
      // print outgoing request for debugging
      debugPrint("📤 Sending request with worker_id: ${widget.workerId}");

      // send POST request to backend PHP API
      final response = await http.post(
        Uri.parse("http://10.0.2.2/wtms_api/get_works.php"),
        body: {'worker_id': widget.workerId},
      );

      // print response details for troubleshooting
      debugPrint("📥 Response code: ${response.statusCode}");
      debugPrint("📦 Response body: ${response.body}");

      // decode Json and map to Task object if requested successfully
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        debugPrint("✅ Decoded JSON: $data");

        setState(() {
          _tasks = data.map((e) => Task.fromJson(e)).toList();
          _loading = false;
        });

      } else {
        throw Exception('Failed to load tasks');
      }

    } catch (e) {
      setState(() => _loading = false);
      debugPrint("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading tasks: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Assigned Tasks"),
        backgroundColor: const Color.fromARGB(255, 255, 237, 149),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text("No tasks assigned."))
              : Padding( // NEW: global padding=30
                  padding: const EdgeInsets.all(30.0),
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 20), // NEW: nicer spacing
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20), // NEW: uniform padding
                          title: Text(task.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0), // NEW: gap
                            child: Text(task.description),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // NEW: due-date in red
                              Text("Due: ${task.dueDate}",
                                  style: const TextStyle(color: Colors.red)),
                              Text("Status: ${task.status}"),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SubmitCompletionScreen(task: task),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
