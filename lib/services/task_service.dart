import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rarecrew/models/task_model.dart';

import '../models/user_model.dart';

class TaskService {
  final StreamController<List<Task>> _tasksController = StreamController<List<Task>>.broadcast();
  final StreamController<List<Task>> _sharedTasksController = StreamController<List<Task>>.broadcast();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Task>> get tasksStream => _tasksController.stream;
  Stream<List<Task>> get sharedTasksStream => _sharedTasksController.stream;

  List<Task> sharedTasks = [];

  Future<void> initTask(String ownerId) async {
    _updateTasks(ownerId);
    _updateSharedTasks();
  }

  Stream<List<Task>> getTasks(String ownerId) {
    return _tasksController.stream;
  }

  Stream<List<Task>> getSharedTasks(String ownerId) {
    return _sharedTasksController.stream;
  }

  Future<void> addTask(Task task, String ownerId) async {
    await _firestore.collection('live').doc('tasks').collection(ownerId).add(task.toMap());
    _updateTasks(ownerId);

  }

  Future<void> editTask(Task task, String ownerId) async {
    await _firestore.collection('live').doc('tasks').collection(task.ownerId).doc(task.id).update(task.toMap());
    _updateTasks(task.ownerId);
    _updateSharedTasks();
  }


  Future<void> deleteTask(String taskId, String ownerId) async {
    print("taskid: $taskId");
    try {
      DocumentSnapshot snapshot = await _firestore.collection('live').doc('tasks').collection(ownerId).doc(taskId).get();
      print('Document path: live/tasks/$ownerId/$taskId');
      print('Document exists: ${snapshot.exists}');

      if (snapshot.exists) {
        await _firestore.collection('live').doc('tasks').collection(ownerId).doc(taskId).delete();
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
    _updateTasks(ownerId);
    _updateSharedTasks();
  }

  void _updateTasks(String ownerId) {
    _firestore.collection('live').doc('tasks').collection(ownerId).snapshots().listen(
          (QuerySnapshot snapshot) {
        final List<Task> tasks = snapshot.docs.map(
              (DocumentSnapshot doc) => Task.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        ).toList();
        _tasksController.add(List<Task>.unmodifiable(tasks));
      },
    );
  }

  Future<void> _updateSharedTasks() async {
    print('Starting _updateSharedTasks...');

    try {
      sharedTasks  = [];
      List<AppUser> users = await getAllUsers();

      CollectionReference liveCollectionRef = _firestore.collection('live');

      List<StreamSubscription<QuerySnapshot>> subscriptions = [];

      // Iterate through users
      for (AppUser user in users) {
        String userId = user.uid;

        CollectionReference tasksCollectionRef = liveCollectionRef.doc('tasks').collection(userId);
        print(tasksCollectionRef.path);

        tasksCollectionRef.snapshots().listen(
              (QuerySnapshot snapshot) {
            print('Received snapshot for _updateSharedTasks $userId. Number of documents: ${snapshot.docs.length}');

            for (QueryDocumentSnapshot doc in snapshot.docs) {
              if (doc.exists) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                print('Data Fields for Shared Task:');
                print('Current User: ${FirebaseAuth.instance.currentUser!.uid}');
                print('ID: ${doc.id}');
                print('Title: ${data["title"]}');
                print('Description: ${data["description"]}');
                print('Shared With: ${(data["sharedWith"] as List<dynamic>?)?.cast<String>() ?? []}');
                print('Owner ID: ${data["ownerId"]}');

                bool isShared = data.containsKey('sharedWith') &&
                    (data['sharedWith'] as List<dynamic>?)?.cast<String>()?.contains(FirebaseAuth.instance.currentUser!.uid) == true;

                print('Checking condition for sharedWith:');
                print('data.containsKey(\'sharedWith\'): ${data.containsKey('sharedWith')}');
                print('(data[\'sharedWith\'] as List<dynamic>?)?.cast<String>()?: ${(data['sharedWith'] as List<dynamic>?)?.cast<String>()}');
                print('user.uid: ${user.uid}');
                print('Result of the condition: $isShared');

                if (isShared) {
                  print('Document ${doc.id} has sharedWith field with current user\'s UUID: ${data['sharedWith']}');
                  // Process the document data and update your controller accordingly

                  // Example: Adding the task to a list of shared tasks
                  Task sharedTask = Task(
                      id: doc.id,
                      title: data["title"],
                      description: data["description"],
                      sharedWith: (data["sharedWith"] as List<dynamic>?)?.cast<String>() ?? [], ownerId:data["ownerId"]
                  );

                  print(sharedTask.toMap());
                  // Add the shared task to a list or perform other processing
                  if (!sharedTasks.contains(sharedTask)) {
                    sharedTasks.add(sharedTask);
                    print("shared tasks: $sharedTasks");
                    _sharedTasksController.add(List<Task>.unmodifiable(removeDuplicates(sharedTasks)));
                  }
                  print("added: ${sharedTask.toMap()}... list: ${sharedTasks.toSet().toList()}");
                } else {
                  print('Document ${doc.id} does not have sharedWith field or does not contain current user\'s UUID.');
                  // Handle the case where 'sharedWith' field is missing or does not match the current user's UUID
                }
              } else {
                print('Document ${doc.id} does not exist.');
                // Handle the case where the document does not exist
              }
            }
          },
          onDone: () {
            print('Done listening for _updateSharedTasks $userId...');
          },
          onError: (error) {
            print('Error in _updateSharedTasks $userId: $error');
          },
        );

      }

      // Wait for all subscriptions to complete
      await Future.wait(subscriptions.map((subscription) => subscription.cancel()));

      print('Finished setting up listeners for all users.');
    } catch (e) {
      print('Error in _updateSharedTasks: $e');
      // Handle the error, you might want to throw an exception or log it based on your use case.
    }
  }








  Future<void> shareTask(String taskId, String ownerId, List<AppUser> sharedWithUsers) async {
    List<String> sharedWithUserIds = sharedWithUsers.map((user) => user.uid).toList();
    await _firestore.collection('live').doc('tasks').collection(ownerId)
        .doc(taskId)
        .update({'sharedWith': sharedWithUserIds});

    _updateTasks(ownerId);
    _updateSharedTasks();
  }


  Future<List<AppUser>> getAllUsers() async {
    print('Starting to fetch user data...');
    List<AppUser> users = [];
    int numberOfUsersFetched = 0;

    try {
      print('Fetching user data from Firestore...');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("live").doc("users").collection("users").get();

      print('Number of user documents to fetch: ${querySnapshot.size}');

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        print('Processing user document...');
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

        print('User data found:');
        print('UID: ${data['uid']}');
        print('Email: ${data['email']}');
        print('Name: ${data['name']}');

        users.add(AppUser(
          uid: data['uid'],
          email: data['email'],
          name: data['name'],
        ));

        numberOfUsersFetched++;
      }

      print('User data fetched successfully. Number of users fetched: $numberOfUsersFetched');
    } catch (e) {
      print('Error fetching user data: $e');
    }

    print('Returning the list of users...');
    return users;
  }


  List<Task> removeDuplicates(List<Task> tasks) {
    // Create a map to store tasks based on their ids
    Map<String, Task> taskMap = {};

    // Iterate through the list and add tasks to the map, using the id as the key
    for (Task task in tasks) {
      taskMap[task.id] = task;
    }

    // Retrieve the unique tasks from the map
    List<Task> uniqueTaskList = taskMap.values.toList();

    return uniqueTaskList;
  }


}


