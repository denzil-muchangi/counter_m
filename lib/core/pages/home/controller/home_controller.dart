import 'package:flutter/material.dart';
import '../models/multi_counter_model.dart';

class HomeController extends ChangeNotifier {
  final MultiCounterNotifier model = MultiCounterNotifier();

  void showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Counter'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g., Coffee, Pushups'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              model.addCounter(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void reorder(List<String> order) {
    model.reorderItems(order);
  }
}
