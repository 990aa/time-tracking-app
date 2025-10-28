import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracking_app/models/time_entry.dart';
import 'package:time_tracking_app/providers/time_entry_provider.dart';
import 'package:time_tracking_app/screens/add_time_entry_screen.dart';
import 'package:time_tracking_app/widgets/main_drawer.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGrouped = false;

  @override
  Widget build(BuildContext context) {
    final timeEntryProvider = Provider.of<TimeEntryProvider>(context);
    final entries = timeEntryProvider.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
        actions: [
          IconButton(
            icon: Icon(_isGrouped ? Icons.list : Icons.group_work),
            onPressed: () {
              setState(() {
                _isGrouped = !_isGrouped;
              });
            },
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: entries.isEmpty
          ? const Center(child: Text('No time entries yet.'))
          : _isGrouped
          ? _buildGroupedView(entries)
          : _buildListView(entries, timeEntryProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const AddTimeEntryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(List<TimeEntry> entries, TimeEntryProvider provider) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (ctx, index) {
        final entry = entries[index];
        return Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            provider.deleteEntry(entry.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entry deleted')),
            );
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(entry.project.name[0].toUpperCase()),
              ),
              title: Text('${entry.project.name} - ${entry.task.name}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat.yMd().format(entry.date)),
                  if (entry.notes.isNotEmpty) Text(entry.notes),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${entry.duration.inHours}h ${entry.duration.inMinutes.remainder(60)}m',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Entry'),
                          content: const Text(
                            'Are you sure you want to delete this time entry?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                provider.deleteEntry(entry.id);
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Entry deleted'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedView(List<TimeEntry> entries) {
    final groupedEntries = groupBy(
      entries,
      (TimeEntry entry) => entry.project.name,
    );

    if (groupedEntries.isEmpty) {
      return const Center(
        child: Text('No time entries yet.'),
      );
    }

    return ListView.builder(
      itemCount: groupedEntries.length,
      itemBuilder: (ctx, index) {
        final projectName = groupedEntries.keys.elementAt(index);
        final projectEntries = groupedEntries[projectName]!;
        final totalDuration = projectEntries.fold(
          const Duration(),
          (sum, entry) => sum + entry.duration,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            leading: CircleAvatar(
              child: Text(projectName[0].toUpperCase()),
            ),
            title: Text(
              projectName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Total: ${totalDuration.inHours}h ${totalDuration.inMinutes.remainder(60)}m',
            ),
            children: projectEntries
                .map(
                  (entry) => ListTile(
                    contentPadding: const EdgeInsets.only(
                      left: 72,
                      right: 16,
                      top: 4,
                      bottom: 4,
                    ),
                    title: Text(entry.task.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat.yMd().format(entry.date)),
                        if (entry.notes.isNotEmpty) Text(entry.notes),
                      ],
                    ),
                    trailing: Text(
                      '${entry.duration.inHours}h ${entry.duration.inMinutes.remainder(60)}m',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
