import 'package:flutter/material.dart';

import 'app.dart';
import 'data/content_repository.dart';
import 'data/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ProgressService.instance.init();
  final curriculum = await ContentRepository().load();

  runApp(TrilhaApp(curriculum: curriculum));
}
