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
          onDismissed: (direction) {
            provider.deleteEntry(entry.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
          },
          background: Container(color: Colors.red),
          child: ListTile(
            title: Text('${entry.project.name} - ${entry.task.name}'),
            subtitle: Text(
              '${DateFormat.yMd().format(entry.date)} - ${entry.notes}',
            ),
            trailing: Text(
              '${entry.duration.inHours}h ${entry.duration.inMinutes.remainder(60)}m',
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

    return ListView.builder(
      itemCount: groupedEntries.length,
      itemBuilder: (ctx, index) {
        final projectName = groupedEntries.keys.elementAt(index);
        final projectEntries = groupedEntries[projectName]!;
        final totalDuration = projectEntries.fold(
          const Duration(),
          (sum, entry) => sum + entry.duration,
        );

        return ExpansionTile(
          title: Text(
            '$projectName (${totalDuration.inHours}h ${totalDuration.inMinutes.remainder(60)}m)',
          ),
          children: projectEntries
              .map(
                (entry) => ListTile(
                  title: Text(entry.task.name),
                  subtitle: Text(
                    '${DateFormat.yMd().format(entry.date)} - ${entry.notes}',
                  ),
                  trailing: Text(
                    '${entry.duration.inHours}h ${entry.duration.inMinutes.remainder(60)}m',
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
