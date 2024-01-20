import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rarecrew/views/home/shared_task_list.dart';
import 'package:rarecrew/widgets/tab_controller_provider.dart';

import '../../models/task_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import 'task_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    TaskViewModel taskViewModel = Provider.of<TaskViewModel>(context, listen: false);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      int currentIndex = _tabController.index;
      print("tab changed: $currentIndex");
      Provider.of<TabControllerProvider>(context, listen: false).setIndex(currentIndex);
      taskViewModel.initTasks(_getCurrentUserId());
    });

    taskViewModel.initTasks(_getCurrentUserId());
  }

  @override
  void dispose() {
    // Dispose the TabController
    _tabController.dispose();
    super.dispose();
  }


// Helper method to get the current user's ID
  String _getCurrentUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void _signOut() async {
    try {
      await context.read<AuthViewModel>().signOut();
      Navigator.pushReplacementNamed(context, '/auth');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO App'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _signOut();
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          tabs: const [
            Tab(
              text: 'Personal Tasks',
            ),
            Tab(
              text: 'Shared Tasks',
            ),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          const TaskList(),
          SharedTaskList(),
        ],
      ),
      floatingActionButton: Consumer<TabControllerProvider>(
        builder: (context, tabControllerProvider, child) {
          return Visibility(
            visible: tabControllerProvider.currentIndex == 0,
            child: FloatingActionButton(
              onPressed: () {
                _showAddTaskDialog(context);
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }



  void _showAddTaskDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Task Title:'),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter task title',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Task Description:'),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter task description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                TaskViewModel taskViewModel = context.read<TaskViewModel>();
                FirebaseAuth auth = FirebaseAuth.instance;
                User? user = auth.currentUser;

                if (user != null) {
                  // Use the user's uid as the ownerId
                  taskViewModel.addTask(
                    Task(
                      title: titleController.text,
                      description: descriptionController.text,
                      ownerId: user.uid, id: '',
                    ),
                    user.uid,
                  );
                } else {
                  Navigator.pushReplacementNamed(context, "/auth");
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
