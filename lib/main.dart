import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/providers/project_task_provider.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:time_tracking_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => TimeEntryProvider()),
        ChangeNotifierProvider(create: (ctx) => ProjectTaskProvider()),
      ],
      child: MaterialApp(
        title: 'Time Tracking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
