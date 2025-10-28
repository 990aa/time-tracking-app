import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracking_app/models/time_entry.dart';

class TimeEntryProvider with ChangeNotifier {
  List<TimeEntry> _entries = [];
  bool _isLoading = true;

  List<TimeEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  TimeEntryProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('entries');
      if (data != null) {
        final decoded = json.decode(data) as List;
        _entries = decoded.map((item) => TimeEntry.fromJson(item)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading entries: $e');
      }
      _entries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = json.encode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString('entries', data);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving entries: $e');
      }
    }
  }

  void addEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveEntries();
    notifyListeners();
  }

  void deleteEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    _saveEntries();
    notifyListeners();
  }
}
