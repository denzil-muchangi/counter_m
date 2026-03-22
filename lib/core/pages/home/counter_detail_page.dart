import 'dart:ui' as ui;
import 'package:counter_m/core/pages/home/controller/home_controller.dart';
import 'package:counter_m/core/pages/home/models/multi_counter_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class CounterDetailPage extends StatefulWidget {
  final HomeController controller;
  final String initialId;

  const CounterDetailPage({
    super.key,
    required this.controller,
    required this.initialId,
  });

  @override
  State<CounterDetailPage> createState() => _CounterDetailPageState();
}

class _CounterDetailPageState extends State<CounterDetailPage> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.controller.model.items.indexWhere(
      (item) => item.id == widget.initialId,
    );
    if (currentIndex == -1) currentIndex = 0;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _inc(CounterItem item) {
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);
    widget.controller.model.increment(item.id);
    widget.controller.model.updateActivity(item.id);
  }

  void _dec(CounterItem item) {
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);
    widget.controller.model.decrement(item.id);
  }

  void _reset(CounterItem item, BuildContext context) {
    HapticFeedback.lightImpact();
    Vibration.vibrate(duration: 50);
    widget.controller.model.reset(item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset counter!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Counter Detail'),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.controller.model.items.length,
          onPageChanged: (index) {
            setState(() => currentIndex = index);
            // Update activity
            widget.controller.model.updateActivity(
              widget.controller.model.items[index].id,
            );
          },
          itemBuilder: (context, index) {
            final item = widget.controller.model.items[index];
            return AnimatedBuilder(
              animation: widget.controller.model,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.8),
                        Theme.of(context).colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Name and Index
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: item.name,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  controller: TextEditingController(
                                    text: item.name,
                                  ),
                                  maxLines: 1,
                                  onSubmitted: (value) => widget
                                      .controller
                                      .model
                                      .updateName(item.id, value),
                                ),
                              ),
                              Text(
                                '${currentIndex + 1} / ${widget.controller.model.items.length}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Large Value
                          Semantics(
                            label: 'Count: ${item.value}',
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.95, end: 1.05),
                              duration: const Duration(milliseconds: 400),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: Text(
                                    '${item.value}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: item.value > 0
                                              ? Colors.green
                                              : Colors.white,
                                          fontWeight: FontWeight.w900,
                                          shadows: [
                                            Shadow(
                                              offset: const Offset(0, 4),
                                              blurRadius: 8,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Step
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Semantics(
                                label: 'Step size: ${item.step}',
                                child: Text(
                                  'Step: ${item.step}',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    final newStep =
                                        int.tryParse(value) ?? item.step;
                                    widget.controller.model.updateStep(
                                      item.id,
                                      newStep,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 64),
                          // Big Buttons Row 1
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Semantics(
                                label: 'Decrement',
                                child: GestureDetector(
                                  onTapDown: (_) => _dec(item),
                                  child: Container(
                                    width: screenWidth * 0.25,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Semantics(
                                label: 'Increment',
                                child: GestureDetector(
                                  onTapDown: (_) => _inc(item),
                                  child: Container(
                                    width: screenWidth * 0.25,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Big Buttons Row 2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Semantics(
                                label: 'Reset',
                                child: GestureDetector(
                                  onTapDown: (_) => _reset(item, context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.restart_alt,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
