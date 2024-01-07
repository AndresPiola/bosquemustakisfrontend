 
import 'package:bosquemustakisfrontend/login_screenOld.dart';
 import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
  

main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
 
 
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // Set default `_initialized` and `_error` state to false
 
  bool _initialized = true;
  bool _error = false;

 

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed

    // Show a loader until FlutterFire is initialized
    if (_error) {
      return MaterialApp(
          title: 'Mustakis Audit Tool',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
              appBar: AppBar(
            title: const Text('Loading'),
          )));
    }
    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return MaterialApp(
          title: 'Mustakis Audit Tool',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
              appBar: AppBar(
            title: const Text('Loafing'),
          )));
    }

    return MaterialApp(
      title: 'Mustakis Audit Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:   LoginScreenEmail()
    );
  }
}
 