import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rarecrew/views/auth_screen.dart';
import 'package:rarecrew/widgets/tab_controller_provider.dart';

import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthViewModel()),
        ChangeNotifierProvider.value(value: TaskViewModel()),
        ChangeNotifierProvider.value(value: TabControllerProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      initialRoute: '/auth', // Set the initial route
      routes: {
        '/': (context) => HomeScreen(), // Home screen
        '/auth': (context) => AuthScreen(), // Authentication screen
      },
    );
  }
}
