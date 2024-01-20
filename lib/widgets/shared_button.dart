import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../viewmodels/task_viewmodel.dart';

class SharedButton extends StatelessWidget {
  final Task task;

  const SharedButton({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Show the multi-select dialog and get selected users
        List<AppUser>? selectedUsers = await _showMultiSelectDialog(context);

        if (selectedUsers != null && selectedUsers.isNotEmpty) {
          // Add your logic to share the task with selected users
          // For simplicity, I'm just printing the task and selected users here
          print('Sharing Task: ${task.title}, ${task.description}');
          print('Selected Users: ${selectedUsers.map((user) => user.toString()).join(', ')}');

          // Call the shareTask method from your TaskViewModel
          context.read<TaskViewModel>().shareTask(task.id, FirebaseAuth.instance.currentUser!.uid, selectedUsers);
        }
      },
      child: const Text('Share'),
    );
  }

  Future<List<AppUser>?> _showMultiSelectDialog(BuildContext context) async {
    // Get the list of all users
    List<AppUser> allUsers = await Provider.of<TaskViewModel>(context, listen: false).getAllUsers();
    allUsers.forEach((user) {
      if (user != null) {
        print('User ID: ${user.uid}');
      }
    });

    // Initialize a set to keep track of selected users
    Set<AppUser> selectedUsers = {};

    return showDialog<List<AppUser>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Users to Share With'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: allUsers.where((user) => user?.uid != FirebaseAuth.instance.currentUser?.uid).map((user) {
                    return CheckboxListTile(
                      title: Text(user?.name ?? ""),
                      value: selectedUsers.contains(user),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null) {
                            if (value) {
                              selectedUsers.add(user);
                            } else {
                              selectedUsers.remove(user);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(selectedUsers.toList());
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
