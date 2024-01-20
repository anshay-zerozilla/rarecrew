// edit_task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Import Provider
import 'package:rarecrew/models/task_model.dart';
import 'package:rarecrew/viewmodels/task_viewmodel.dart';  // Import your TaskViewModel

class EditTaskScreen extends StatefulWidget {
  final Task task;

  EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);

    // Add onChanged listeners to the controllers
    titleController.addListener(_saveChanges);
    descriptionController.addListener(_saveChanges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Title:'),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter task title',
              ),
            ),
            SizedBox(height: 16),
            Text('Task Description:'),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter task description',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to save the changes
  void _saveChanges() {
    // Update the task with new values from the controllers
    Task updatedTask = Task(
      title: titleController.text,
      description: descriptionController.text,
      ownerId: widget.task.ownerId,
      sharedWith: widget.task.sharedWith,
      id: widget.task.id,
    );

    // Access the TaskViewModel using Provider
    TaskViewModel taskViewModel = Provider.of<TaskViewModel>(context, listen: false);

    // Call the editTask method in the TaskViewModel to save the updated task
    taskViewModel.editTask(updatedTask, widget.task.ownerId);
  }

  @override
  void dispose() {
    // Dispose the controllers to avoid memory leaks
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
