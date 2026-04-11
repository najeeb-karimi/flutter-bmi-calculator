import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/utils/unit_converter.dart';
import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.loadEntries,
    required this.onDeleteEntry,
    required this.onClearHistory,
  });

  final Future<List<BmiEntry>> Function() loadEntries;
  final Future<void> Function(String id) onDeleteEntry;
  final Future<void> Function() onClearHistory;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<BmiEntry> _entries = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final loadedEntries = await widget.loadEntries();
    if (!mounted) return;
    setState(() {
      _entries = [...loadedEntries.reversed];
      _isLoading = false;
    });
  }

  Future<void> _deleteEntry(BmiEntry entry) async {
    await widget.onDeleteEntry(entry.id);
    if (!mounted) return;
    setState(() {
      _entries = _entries.where((item) => item.id != entry.id).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History entry deleted.'),
      ),
    );
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear history?'),
          content: const Text(
            'This will permanently remove all saved BMI entries.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear all'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    await widget.onClearHistory();
    if (!mounted) return;
    setState(() {
      _entries = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: _confirmClearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? const Center(
                    child: Text('No saved BMI results yet.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Dismissible(
                        key: ValueKey(entry.id),
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.delete_outline,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          _deleteEntry(entry);
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(
                              'BMI ${entry.bmiValue.toStringAsFixed(1)} - ${entry.categoryLabel}',
                            ),
                            subtitle: Text(
                              '${_formatDate(context, entry.createdAt)}\n${_measurementSummary(entry)}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => HistoryDetailScreen(entry: entry),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

String _formatDate(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(value);
  final time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(value),
    alwaysUse24HourFormat: true,
  );
  return '$date, $time';
}

String _measurementSummary(BmiEntry entry) {
  final isMetric = entry.unitUsed == MeasurementUnit.metric;
  final height = isMetric ? entry.heightCm : UnitConverter.cmToIn(entry.heightCm);
  final weight = isMetric ? entry.weightKg : UnitConverter.kgToLb(entry.weightKg);
  final heightUnit = isMetric ? 'cm' : 'in';
  final weightUnit = isMetric ? 'kg' : 'lb';
  return 'Height ${height.toStringAsFixed(1)} $heightUnit - Weight ${weight.toStringAsFixed(1)} $weightUnit';
}
