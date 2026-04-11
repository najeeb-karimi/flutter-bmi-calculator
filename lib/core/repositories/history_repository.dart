import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:bmi_calculator/models/bmi_entry.dart';

class HistoryRepository {
  HistoryRepository(this._prefs);

  static const String _historyKey = 'bmi_history_v1';
  static const int _maxEntries = 500;

  final SharedPreferences _prefs;

  Future<List<BmiEntry>> loadEntries() async {
    final raw = _prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    final entries = decoded
        .whereType<Map>()
        .map((item) => BmiEntry.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    return List.unmodifiable(_normalizeEntries(entries));
  }

  Future<void> saveEntries(List<BmiEntry> entries) async {
    final normalizedEntries = _normalizeEntries(entries);
    await _prefs.setString(
      _historyKey,
      jsonEncode(normalizedEntries.map((entry) => entry.toMap()).toList()),
    );
  }

  Future<void> appendEntry(BmiEntry entry) async {
    final entries = await loadEntries();
    await saveEntries([...entries, entry]);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await loadEntries();
    await saveEntries(entries.where((entry) => entry.id != id).toList());
  }

  Future<void> clearEntries() async {
    await _prefs.remove(_historyKey);
  }

  List<BmiEntry> _normalizeEntries(List<BmiEntry> entries) {
    final normalizedEntries = [...entries]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (normalizedEntries.length <= _maxEntries) {
      return normalizedEntries;
    }

    return normalizedEntries.sublist(
      normalizedEntries.length - _maxEntries,
    );
  }
}
