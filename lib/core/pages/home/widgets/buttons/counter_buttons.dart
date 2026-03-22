import 'package:flutter/material.dart';
import '../../controller/home_controller.dart';

class CounterButtons extends StatelessWidget {
  const CounterButtons({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all((screenWidth * 0.04).clamp(8.0, 16.0)),
      child: FloatingActionButton.extended(
        heroTag: 'add_counter',
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 12,
        tooltip: 'Add New Counter',
        onPressed: () => controller.showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Counter'),
      ),
    );
  }
}
