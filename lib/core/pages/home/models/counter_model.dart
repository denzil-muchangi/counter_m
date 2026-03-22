import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterModel extends ChangeNotifier {
  CounterModel() : super() {
    _loadPrefs();
  }

  int _value = 0;
  int _step = 1;

  int get value => _value;
  set value(int newValue) {
    _value = newValue >= 0 ? newValue : 0;
    _savePrefs();
    notifyListeners();
  }

  int get step => _step;
  set step(int newStep) {
    _step = newStep > 0 ? newStep : 1;
    _savePrefs();
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _value = prefs.getInt('counter_value') ?? 0;
    _step = prefs.getInt('counter_step') ?? 1;
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_value', _value);
    await prefs.setInt('counter_step', _step);
  }

  void increment() {
    _value += _step;
    notifyListeners();
    _savePrefs();
  }

  void reset() {
    _value = 0;
    notifyListeners();
    _savePrefs();
  }

  void decrement() {
    if (_value >= _step) {
      _value -= _step;
      notifyListeners();
      _savePrefs();
    }
  }
}
