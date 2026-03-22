import 'package:flutter/material.dart';
import '../../controller/home_controller.dart';

class CounterButtons extends StatelessWidget {
  const CounterButtons({super.key, required this.controller});

  final HomeController controller;

  void _decrementCounter(BuildContext context) {
    if (controller.model.value > 0) {
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
            onPressed: controller.incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 30),
          FloatingActionButton(
            onPressed: controller.resetCounter,
            tooltip: 'Reset to Zero',
            child: const Icon(Icons.restart_alt),
          ),
          const SizedBox(width: 30),
          FloatingActionButton(
            onPressed: () => _decrementCounter(context),
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
