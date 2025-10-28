import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/providers/project_task_provider.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'dart:convert';

class LocalStorageScreen extends StatelessWidget {
  const LocalStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timeEntryProvider = Provider.of<TimeEntryProvider>(context);
    final projectTaskProvider = Provider.of<ProjectTaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage Data'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStorageSection(
              'Time Entries',
              timeEntryProvider.entries.isEmpty
                  ? 'Empty - No time entries stored'
                  : jsonEncode(
                      timeEntryProvider.entries.map((e) => e.toJson()).toList(),
                    ),
              timeEntryProvider.entries.isEmpty
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              timeEntryProvider.entries.isEmpty,
            ),
            const SizedBox(height: 24),
            _buildStorageSection(
              'Projects',
              projectTaskProvider.projects.isEmpty
                  ? 'Empty - No projects stored'
                  : jsonEncode(
                      projectTaskProvider.projects
                          .map((p) => p.toJson())
                          .toList(),
                    ),
              projectTaskProvider.projects.isEmpty
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              projectTaskProvider.projects.isEmpty,
            ),
            const SizedBox(height: 24),
            _buildStorageSection(
              'Tasks',
              projectTaskProvider.tasks.isEmpty
                  ? 'Empty - No tasks stored'
                  : jsonEncode(
                      projectTaskProvider.tasks.map((t) => t.toJson()).toList(),
                    ),
              projectTaskProvider.tasks.isEmpty
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              projectTaskProvider.tasks.isEmpty,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(
    String title,
    String data,
    Color bgColor,
    bool isEmpty,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEmpty ? Icons.inbox : Icons.storage,
                  color: isEmpty
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEmpty
                        ? Colors.orange.shade900
                        : Colors.green.shade900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? Colors.orange.shade200
                        : Colors.green.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEmpty ? 'EMPTY' : 'FILLED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isEmpty
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isEmpty
                      ? Colors.orange.shade300
                      : Colors.green.shade300,
                ),
              ),
              child: SelectableText(
                data,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: isEmpty ? Colors.grey.shade700 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
