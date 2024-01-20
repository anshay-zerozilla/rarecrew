import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rarecrew/models/task_model.dart';
import 'package:rarecrew/widgets/shared_button.dart';
import 'package:rarecrew/viewmodels/task_viewmodel.dart';

import '../views/home/edit_task_screen.dart'; // Import your TaskViewModel

class TaskItem extends StatelessWidget {
  final Task task;
  final TaskViewModel taskViewModel;

  TaskItem({Key? key, required this.task, required this.taskViewModel})
      : super(key: key);

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditTaskScreen(task: task),
                  ),
                );
              },
            ),
          if (!task.isSharedWithCurrentUser(auth.currentUser!.uid))
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Add your logic for deleting the task
                _showDeleteConfirmationDialog(context);
              },
            ),
          if (!task.isSharedWithCurrentUser(auth.currentUser!.uid))
          SharedButton(task: task),
        ],
      ),
    );
  }

  // Function to show a confirmation dialog before deleting the task
  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Delete the task using your TaskViewModel
                taskViewModel.deleteTask(task.id, auth.currentUser!.uid);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
