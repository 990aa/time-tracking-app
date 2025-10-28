import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracking_app/models/project.dart';
import 'package:time_tracking_app/models/task.dart';

class ProjectTaskProvider with ChangeNotifier {
  List<Project> _projects = [];
  List<Task> _tasks = [];
  bool _isLoading = true;

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  ProjectTaskProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final projectsData = prefs.getString('projects');
      if (projectsData != null) {
        final decoded = json.decode(projectsData) as List;
        _projects = decoded.map((item) => Project.fromJson(item)).toList();
      }

      final tasksData = prefs.getString('tasks');
      if (tasksData != null) {
        final decoded = json.decode(tasksData) as List;
        _tasks = decoded.map((item) => Task.fromJson(item)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading projects/tasks: $e');
      }
      _projects = [];
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = json.encode(_projects.map((e) => e.toJson()).toList());
      await prefs.setString('projects', data);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving projects: $e');
      }
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = json.encode(_tasks.map((e) => e.toJson()).toList());
      await prefs.setString('tasks', data);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tasks: $e');
      }
    }
  }

  void addProject(Project project) {
    _projects.add(project);
    _saveProjects();
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    _saveProjects();
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    _saveTasks();
    notifyListeners();
  }
}
