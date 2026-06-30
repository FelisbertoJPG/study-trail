import 'package:flutter/material.dart';

import 'models/subject.dart';
import 'screens/subjects_screen.dart';
import 'theme/app_theme.dart';

class TrilhaApp extends StatelessWidget {
  final Curriculum curriculum;

  const TrilhaApp({super.key, required this.curriculum});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo de Estudos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: SubjectsScreen(curriculum: curriculum),
    );
  }
}
