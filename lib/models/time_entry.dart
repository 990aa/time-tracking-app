import 'package:time_tracking_app/models/project.dart';
import 'package:time_tracking_app/models/task.dart';

class TimeEntry {
  String id;
  Project project;
  Task task;
  DateTime date;
  Duration duration;
  String notes;

  TimeEntry({
    required this.id,
    required this.project,
    required this.task,
    required this.date,
    required this.duration,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project': project.toJson(),
      'task': task.toJson(),
      'date': date.toIso8601String(),
      'duration': duration.inSeconds,
      'notes': notes,
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      project: Project.fromJson(json['project']),
      task: Task.fromJson(json['task']),
      date: DateTime.parse(json['date']),
      duration: Duration(seconds: json['duration']),
      notes: json['notes'],
    );
  }
}
