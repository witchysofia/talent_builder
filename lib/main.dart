import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/talent_provider.dart';
import 'widgets/left_sidebar.dart';
import 'widgets/talent_canvas.dart';
import 'widgets/right_editor_panel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TalentProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talent Tree Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF3B82F6),
        fontFamily: 'Inter',
      ),
      home: const TalentBuilderHome(),
    );
  }
}

class TalentBuilderHome extends StatelessWidget {
  const TalentBuilderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const LeftSidebar(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.white10),
                ),
              ),
              child: const TalentCanvas(),
            ),
          ),
          const RightEditorPanel(),
        ],
      ),
    );
  }
}
