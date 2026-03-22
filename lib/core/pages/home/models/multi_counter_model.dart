import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogEntry {
  final DateTime time;
  final int delta;

  LogEntry({required this.time, required this.delta});

  Map<String, dynamic> toJson() => {
    'time': time.millisecondsSinceEpoch,
    'delta': delta,
  };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
    time: DateTime.fromMillisecondsSinceEpoch(json['time']),
    delta: json['delta'],
  );
}

class CounterItem {
  final String id;
  String name;
  int value;
  int step;
  List<LogEntry> history;
  DateTime? lastActive;

  CounterItem({
    required this.id,
    required this.name,
    required this.value,
    required this.step,
    required this.history,
    this.lastActive,
  });

  CounterItem copyWith({
    String? name,
    int? value,
    int? step,
    List<LogEntry>? history,
    DateTime? lastActive,
  }) {
    return CounterItem(
      id: id,
      name: name ?? this.name,
      value: value ?? this.value,
      step: step ?? this.step,
      history: history ?? this.history,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'value': value,
    'step': step,
    'history': history.map((e) => e.toJson()).toList(),
    'lastActive': lastActive?.millisecondsSinceEpoch,
  };

  factory CounterItem.fromJson(Map<String, dynamic> json) => CounterItem(
    id: json['id'],
    name: json['name'],
    value: json['value'] ?? 0,
    step: json['step'] ?? 1,
    history:
        (json['history'] as List<dynamic>?)
            ?.map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    lastActive: json['lastActive'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['lastActive'])
        : null,
  );
}

class MultiCounterNotifier extends ChangeNotifier {
  List<CounterItem> _items = [];
  List<CounterItem> get items => _items;

  MultiCounterNotifier() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('counters_data');
    if (data != null) {
      try {
        final List<dynamic> list = jsonDecode(data);
        _items = list.map((e) => CounterItem.fromJson(e)).toList();
        _items = _items
            .map(
              (item) =>
                  item.copyWith(lastActive: item.lastActive ?? DateTime.now()),
            )
            .toList();
        // Migrate old single if no items
        if (_items.isEmpty) {
          final oldValue = prefs.getInt('counter_value') ?? 0;
          final oldStep = prefs.getInt('counter_step') ?? 1;
          if (oldValue > 0 || oldStep > 1) {
            _items.add(
              CounterItem(
                id: 'default_${DateTime.now().millisecondsSinceEpoch}',
                name: 'Default',
                value: oldValue,
                step: oldStep,
                history: [],
              ),
            );
          }
        }
      } catch (e) {
        // Invalid JSON, start fresh
      }
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('counters_data', data);
    // Clean old keys post-migration
    await prefs.remove('counter_value');
    await prefs.remove('counter_step');
  }

  void addCounter(String name) {
    if (name.trim().isEmpty) return;
    final newItem = CounterItem(
      id: 'counter_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
      name: name.trim(),
      value: 0,
      step: 1,
      history: [],
      lastActive: DateTime.now(),
    );
    _items.add(newItem);
    _logChange(newItem.id, 0); // Initial log?
    notifyListeners();
    _savePrefs();
  }

  void increment(String id, {bool log = true}) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      final step = _items[index].step;
      _items[index] = _items[index].copyWith(
        value: _items[index].value + step,
        lastActive: DateTime.now(),
      );
      if (log) _logChange(id, step);
      notifyListeners();
      _savePrefs();
    }
  }

  void decrement(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1 && _items[index].value >= _items[index].step) {
      final step = _items[index].step;
      _items[index] = _items[index].copyWith(
        value: _items[index].value - step,
        lastActive: DateTime.now(),
      );
      _logChange(id, -step);
      notifyListeners();
      _savePrefs();
    }
  }

  void reset(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      final oldValue = _items[index].value;
      _items[index] = _items[index].copyWith(
        value: 0,
        lastActive: DateTime.now(),
      );
      _logChange(id, -oldValue);
      notifyListeners();
      _savePrefs();
    }
  }

  void updateStep(String id, int newStep) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        step: newStep > 0 ? newStep : 1,
        lastActive: DateTime.now(),
      );
      notifyListeners();
      _savePrefs();
    }
  }

  void updateName(String id, String newName) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        name: newName,
        lastActive: DateTime.now(),
      );
      notifyListeners();
      _savePrefs();
    }
  }

  void deleteCounter(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    _savePrefs();
  }

  void updateActivity(String id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(lastActive: DateTime.now());
      notifyListeners();
      _savePrefs();
    }
  }

  List<CounterItem> get recentItems {
    return List.from(items)
      ..sort(
        (a, b) => (b.lastActive ?? DateTime(1900)).compareTo(
          a.lastActive ?? DateTime(1900),
        ),
      )
      ..take(5).toList();
  }

  List<CounterItem> get allItems {
    return List.from(items)..sort((a, b) => a.name.compareTo(b.name));
  }

  void reorderItems(List<String> newOrder) {
    final orderedMap = <String, CounterItem>{
      for (var item in items) item.id: item,
    };
    _items = newOrder
        .map((id) => orderedMap[id]!)
        .whereType<CounterItem>()
        .toList();
    notifyListeners();
    _savePrefs();
  }

  void _logChange(String id, int delta) {
    final now = DateTime.now();
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _items[index].history.insert(
        0,
        LogEntry(time: now, delta: delta),
      ); // Recent first
      if (_items[index].history.length > 50) {
        // Limit
        _items[index].history = _items[index].history.take(50).toList();
      }
    }
  }
}
