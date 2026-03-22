import 'package:flutter/foundation.dart';
import '../models/counter_model.dart';

class HomeController extends ChangeNotifier {
  final CounterModel model = CounterModel();

  void incrementCounter() {
    model.increment();
  }

  void resetCounter() {
    model.reset();
  }

  void decrementCounter() {
    model.decrement();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }
}
