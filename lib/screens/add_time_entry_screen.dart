import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/models/project.dart';
import 'package:time_tracking_app/models/task.dart';
import 'package:time_tracking_app/models/time_entry.dart';
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

  // Dummy data for projects and tasks
  final List<Project> _projects = [
    Project(id: '1', name: 'Project A'),
    Project(id: '2', name: 'Project B'),
  ];
  final List<Task> _tasks = [
    Task(id: '1', name: 'Task 1'),
    Task(id: '2', name: 'Task 2'),
  ];

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Project>(
                initialValue: _selectedProject,
                items: _projects
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
                decoration: const InputDecoration(labelText: 'Project'),
                validator: (value) =>
                    value == null ? 'Please select a project' : null,
              ),
              DropdownButtonFormField<Task>(
                initialValue: _selectedTask,
                items: _tasks
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
                decoration: const InputDecoration(labelText: 'Task'),
                validator: (value) =>
                    value == null ? 'Please select a task' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                onSaved: (value) {
                  _notes = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat.yMd().format(_selectedDate)}',
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
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Time: ${_selectedTime.format(context)}'),
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
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
