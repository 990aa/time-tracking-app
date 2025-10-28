import 'package:flutter/material.dart';
import 'package:time_tracking_app/widgets/main_drawer.dart';

class ProjectTaskManagementScreen extends StatelessWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Projects & Tasks')),
      drawer: const MainDrawer(),
      body: const Center(
        child: Text('Management screen for projects and tasks.'),
      ),
    );
  }
}
