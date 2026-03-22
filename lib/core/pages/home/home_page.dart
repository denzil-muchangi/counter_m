import 'package:flutter/material.dart';
import 'controller/home_controller.dart';
import 'widgets/body/home_body.dart';
import 'widgets/buttons/counter_buttons.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.history), text: 'Recent'),
            Tab(icon: Icon(Icons.list), text: 'All'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: SafeArea(child: HomeBody(controller: controller)),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
        child: CounterButtons(controller: controller),
      ),
    );
  }
}
