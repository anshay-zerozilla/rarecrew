import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/task_item.dart';

class SharedTaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        return Consumer<TaskViewModel>(
          builder: (context, taskViewModel, child) {
            return StreamBuilder<List<Task>>(
              stream: taskViewModel.sharedTasksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No shared tasks available.'));
                  } else {
                    List<Task> sharedTasks = snapshot.data!;
                    return ListView.builder(
                      itemCount: sharedTasks.length,
                      itemBuilder: (context, index) {
                        return TaskItem(task: sharedTasks[index], taskViewModel: taskViewModel,);
                      },
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: Text('Shared task stream closed.'));
                }
              },
            );
          },
        );

      },
    );
  }
}
