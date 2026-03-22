import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../controller/home_controller.dart';
import '../../models/multi_counter_model.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.controller});

  final HomeController controller;

  void _inc(String id, BuildContext context) {
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);
    controller.model.increment(id);
  }

  void _dec(String id, BuildContext context) {
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);
    controller.model.decrement(id);
  }

  void _reset(String id, BuildContext context) {
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);
    controller.model.reset(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset counter!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCounterCard(CounterItem item, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.04,
      vertical: 16,
    );
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
      padding: responsivePadding,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Delete
            Semantics(
              label: 'Counter name: ${item.name}',
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Edit counter name',
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: item.name,
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        controller: TextEditingController(text: item.name),
                        maxLines: 1,
                        onSubmitted: (value) =>
                            controller.model.updateName(item.id, value),
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Delete counter',
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.model.deleteCounter(item.id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Value
            Semantics(
              label: 'Count: ${item.value}',
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1.1),
                duration: const Duration(milliseconds: 400),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Text(
                      '${item.value}',
                      style: textTheme.headlineLarge?.copyWith(
                        color: item.value > 0 ? Colors.green : Colors.white,
                        fontWeight: item.value > 0
                            ? FontWeight.w900
                            : FontWeight.bold,
                        fontSize: item.value > 0 ? 48 : 40,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Step
            Row(
              children: [
                Semantics(
                  label: 'Step size: ${item.step}',
                  child: Text(
                    'Step: ${item.step}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: Semantics(
                    label: 'Change step size',
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'step',
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (value) {
                        final newStep = int.tryParse(value) ?? item.step;
                        controller.model.updateStep(item.id, newStep);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // History
            if (item.history.isNotEmpty) ...[
              Semantics(
                label: 'Recent history',
                child: const Text(
                  'Recent:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  itemCount: item.history.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Colors.white24, height: 1),
                  itemBuilder: (context, i) {
                    final entry = item.history[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            label: 'Delta ${entry.delta}',
                            child: Text(
                              '${entry.delta > 0 ? '+' : ''}${entry.delta}',
                              style: TextStyle(
                                color: entry.delta > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Time ${_formatTime(entry.time)}',
                            child: Text(
                              _formatTime(entry.time),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            // Mini buttons
            const SizedBox(height: 12),
            Semantics(
              label: 'Counter controls',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Semantics(
                    label: 'Decrement',
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: '${item.id}_dec',
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      onPressed: () => _dec(item.id, context),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Increment',
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: '${item.id}_inc',
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      onPressed: () => _inc(item.id, context),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Reset',
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: '${item.id}_reset',
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                      onPressed: () => _reset(item.id, context),
                      child: const Icon(
                        Icons.restart_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.model,
      builder: (context, child) {
        if (controller.model.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_chart, size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  'No counters yet',
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap + to add your first counter',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.model.items.length,
          itemBuilder: (context, i) =>
              _buildCounterCard(controller.model.items[i], context),
        );
      },
    );
  }
}
