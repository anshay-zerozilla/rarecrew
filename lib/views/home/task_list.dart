import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/task_item.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        return StreamBuilder<List<Task>>(
          stream: taskViewModel.tasksStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
              // No data state
              return Center(child: Text('No tasks available.'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              // Loading state
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Error state
              return Center(child: Text('Error: ${snapshot.error}'));
            }  else {
              // Data available
              List<Task> tasks = snapshot.data!;
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskItem(task: tasks[index], taskViewModel: taskViewModel,);
                },
              );
            }
          },
        );
      },
    );
  }
}

