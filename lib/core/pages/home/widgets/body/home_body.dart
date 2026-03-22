import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../controller/home_controller.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.model,
      builder: (context, child) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Step: ${controller.model.step}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'new',
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onSubmitted: (value) {
                              final newStep =
                                  int.tryParse(value) ?? controller.model.step;
                              controller.model.step = newStep;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'You have pushed the button this many times:',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.2),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          '${controller.model.value}',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: controller.model.value > 0
                                    ? Colors.green
                                    : Colors.white,
                                fontWeight: controller.model.value > 0
                                    ? FontWeight.w900
                                    : FontWeight.bold,
                                fontSize: controller.model.value > 0 ? 72 : 56,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
