import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../controller/home_controller.dart';

class CounterButtons extends StatelessWidget {
  const CounterButtons({super.key, required this.controller});

  final HomeController controller;

  void _decrementCounter(BuildContext context) {
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);
    if (controller.model.value >= controller.model.step) {
      controller.decrementCounter();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot go below zero!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'inc',
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo.shade500,
            elevation: 12,
            tooltip: 'Increment',
            onPressed: () {
              HapticFeedback.lightImpact();
              Vibration.vibrate(duration: 50);
              controller.incrementCounter();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 30),
          FloatingActionButton(
            heroTag: 'reset',
            foregroundColor: Colors.white,
            backgroundColor: Colors.purple.shade500,
            elevation: 12,
            tooltip: 'Reset to Zero',
            onPressed: () {
              HapticFeedback.lightImpact();
              Vibration.vibrate(duration: 50);
              final oldValue = controller.model.value;
              controller.resetCounter();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Reset to zero!'),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      controller.model.value = oldValue;
                    },
                  ),
                ),
              );
            },
            child: const Icon(Icons.restart_alt),
          ),
          const SizedBox(width: 30),
          FloatingActionButton(
            heroTag: 'dec',
            foregroundColor: Colors.white,
            backgroundColor: Colors.pink.shade500,
            elevation: 12,
            tooltip: 'Decrement',
            onPressed: () => _decrementCounter(context),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
