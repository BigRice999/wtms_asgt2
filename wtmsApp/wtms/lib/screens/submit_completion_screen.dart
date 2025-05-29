import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class SubmitCompletionScreen extends StatefulWidget {
  final Task task;

  const SubmitCompletionScreen({super.key, required this.task});

  @override
  State<SubmitCompletionScreen> createState() => _SubmitCompletionScreenState();
}

class _SubmitCompletionScreenState extends State<SubmitCompletionScreen> {
  final TextEditingController _submissionController = TextEditingController();
  bool _submitting = false;

  Future<void> _submitWork() async {
    String submissionText = _submissionController.text;

    if (submissionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter submission details")),
      );
      return;
    }

    setState(() => _submitting = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? workerId = prefs.getString('worker_id');

    if (workerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker ID not found.")),
      );
      setState(() => _submitting = false); // NEW: reset flag
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("http://10.0.2.2/wtms_api/submit_work.php"),
        body: {
          'worker_id': workerId,
          'work_id': widget.task.id,
          'submission_text': submissionText,
        },
      );

      setState(() => _submitting = false);

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Submission successful!")),
          );
          Navigator.pop(context); // Back to task list screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Submission failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server error during submission")),
        );
      }
    } catch (e) {
      // NEW: handle offline / network errors gracefully
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection lost. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Task Completion")),
      body: Padding(
        padding: const EdgeInsets.all(30.0), // NEW: global padding = 30
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Task Title:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.task.title,
                style: const TextStyle(fontSize: 15)), // NEW: slightly larger

            const SizedBox(height: 60),
            const Text("What did you complete?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _submissionController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Enter your completion details here",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20), // NEW: bigger gap
            _submitting
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitWork,
                      child: const Text("Submit"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
