import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/main.dart';
import 'package:time_tracking_app/models/project.dart';
import 'package:time_tracking_app/models/task.dart';
import 'package:time_tracking_app/models/time_entry.dart';
import 'package:time_tracking_app/providers/project_task_provider.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:time_tracking_app/screens/add_time_entry_screen.dart';
import 'package:time_tracking_app/screens/home_screen.dart';
import 'package:time_tracking_app/screens/project_task_management_screen.dart';

void main() {
  group('MyApp Tests', () {
    testWidgets('MyApp creates and displays HomeScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Time Tracking'), findsOneWidget);
    });
  });

  group('HomeScreen Tests', () {
    testWidgets('HomeScreen has a title and a floating action button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
            ChangeNotifierProvider(create: (context) => ProjectTaskProvider()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Time Tracking'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('HomeScreen shows empty state when no entries',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
            ChangeNotifierProvider(create: (context) => ProjectTaskProvider()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No time entries yet.'), findsOneWidget);
    });

    testWidgets('HomeScreen has group/list toggle button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
            ChangeNotifierProvider(create: (context) => ProjectTaskProvider()),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Check if there's an action button in the app bar
      expect(find.byType(IconButton), findsWidgets);
    });
  });

  group('AddTimeEntryScreen Tests', () {
    testWidgets('AddTimeEntryScreen has all required fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
            ChangeNotifierProvider(create: (context) => ProjectTaskProvider()),
          ],
          child: const MaterialApp(home: AddTimeEntryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Time Entry'), findsOneWidget);
      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });
  });

  group('MainDrawer Tests', () {
    testWidgets('MainDrawer navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => TimeEntryProvider()),
            ChangeNotifierProvider(create: (context) => ProjectTaskProvider()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/management': (context) => const ProjectTaskManagementScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Time Tracker'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Manage Projects & Tasks'), findsOneWidget);
    });
  });

  group('ProjectTaskManagementScreen Tests', () {
    testWidgets('ProjectTaskManagementScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ProjectTaskManagementScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Projects & Tasks'), findsOneWidget);
      expect(find.text('What would you like to manage?'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
    });
  });

  group('TimeEntryProvider Tests', () {
    test('TimeEntryProvider initializes with empty entries', () {
      final provider = TimeEntryProvider();
      expect(provider.entries, isEmpty);
    });

    test('TimeEntryProvider adds entry', () async {
      final provider = TimeEntryProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final entry = TimeEntry(
        id: '1',
        project: Project(id: '1', name: 'Test Project'),
        task: Task(id: '1', name: 'Test Task'),
        date: DateTime.now(),
        duration: const Duration(hours: 2),
        notes: 'Test notes',
      );

      provider.addEntry(entry);
      expect(provider.entries.length, 1);
      expect(provider.entries.first.id, '1');
    });

    test('TimeEntryProvider deletes entry', () async {
      final provider = TimeEntryProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final entry = TimeEntry(
        id: '1',
        project: Project(id: '1', name: 'Test Project'),
        task: Task(id: '1', name: 'Test Task'),
        date: DateTime.now(),
        duration: const Duration(hours: 2),
        notes: 'Test notes',
      );

      provider.addEntry(entry);
      expect(provider.entries.length, 1);

      provider.deleteEntry('1');
      expect(provider.entries, isEmpty);
    });
  });

  group('Model Tests', () {
    test('Project serialization/deserialization', () {
      final project = Project(id: '1', name: 'Test Project');
      final json = project.toJson();
      final deserialized = Project.fromJson(json);

      expect(deserialized.id, project.id);
      expect(deserialized.name, project.name);
    });

    test('Task serialization/deserialization', () {
      final task = Task(id: '1', name: 'Test Task');
      final json = task.toJson();
      final deserialized = Task.fromJson(json);

      expect(deserialized.id, task.id);
      expect(deserialized.name, task.name);
    });

    test('TimeEntry serialization/deserialization', () {
      final entry = TimeEntry(
        id: '1',
        project: Project(id: '1', name: 'Test Project'),
        task: Task(id: '1', name: 'Test Task'),
        date: DateTime(2025, 10, 27),
        duration: const Duration(hours: 2),
        notes: 'Test notes',
      );

      final json = entry.toJson();
      final deserialized = TimeEntry.fromJson(json);

      expect(deserialized.id, entry.id);
      expect(deserialized.project.id, entry.project.id);
      expect(deserialized.task.id, entry.task.id);
      expect(deserialized.duration.inHours, entry.duration.inHours);
      expect(deserialized.notes, entry.notes);
    });
  });
}


