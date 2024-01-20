import 'package:flutter/material.dart';
import 'package:rarecrew/models/task_model.dart';
import 'package:rarecrew/services/task_service.dart';

import '../models/user_model.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  Stream<List<Task>> get tasksStream => _taskService.tasksStream;
  Stream<List<Task>> get sharedTasksStream => _taskService.sharedTasksStream;

  void initTasks(String ownerId) {
    _taskService.initTask(ownerId);
  }

  void addTask(Task task, String ownerId) {
    _taskService.addTask(task, ownerId);
  }

  void editTask(Task task, String ownerId) {
    _taskService.editTask(task, ownerId);
  }

  void deleteTask(String taskId, String ownerId) {
    _taskService.deleteTask(taskId, ownerId);
  }

  Stream<List<Task>> getTasks(String ownerId) {
    return _taskService.getTasks(ownerId);
  }

  Stream<List<Task>> getSharedTasks(String ownerId) {
    return _taskService.getSharedTasks(ownerId);
  }

  Future<void> shareTask(String taskId, String ownerId, List<AppUser> sharedWithUserIds) async {
    await _taskService.shareTask(taskId, ownerId, sharedWithUserIds);
  }

  Future<List<AppUser>> getAllUsers() async {
    return _taskService.getAllUsers();
  }
}
