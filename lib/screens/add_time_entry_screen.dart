import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/models/project.dart';
import 'package:time_tracking_app/models/task.dart';
import 'package:time_tracking_app/models/time_entry.dart';
import 'package:time_tracking_app/providers/project_task_provider.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  Project? _selectedProject;
  Task? _selectedTask;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _notes = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newEntry = TimeEntry(
        id: const Uuid().v4(),
        project: _selectedProject!,
        task: _selectedTask!,
        date: _selectedDate,
        duration: Duration(
          hours: _selectedTime.hour,
          minutes: _selectedTime.minute,
        ),
        notes: _notes,
      );
      Provider.of<TimeEntryProvider>(context, listen: false).addEntry(newEntry);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Time entry added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectTaskProvider = Provider.of<ProjectTaskProvider>(context);
    final projects = projectTaskProvider.projects;
    final tasks = projectTaskProvider.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (projects.isEmpty)
                Card(
                  color: Colors.orange.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No projects available. Please add projects first in the settings.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ),
              if (tasks.isEmpty)
                Card(
                  color: Colors.orange.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No tasks available. Please add tasks first in the settings.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Project>(
                initialValue: _selectedProject,
                items: projects
                    .map(
                      (project) => DropdownMenuItem(
                        value: project,
                        child: Text(project.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a project' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Task>(
                initialValue: _selectedTask,
                items: tasks
                    .map(
                      (task) =>
                          DropdownMenuItem(value: task, child: Text(task.name)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTask = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ? 'Please select a task' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Enter any notes about this time entry',
                ),
                maxLines: 3,
                onSaved: (value) {
                  _notes = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Date: ${DateFormat.yMd().format(_selectedDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Duration: ${_selectedTime.format(context)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedTime = pickedTime;
                                });
                              }
                            },
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: projects.isEmpty || tasks.isEmpty ? null : _submit,
                icon: const Icon(Icons.add),
                label: const Text('Add Entry'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
