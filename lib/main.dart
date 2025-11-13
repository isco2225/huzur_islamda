import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:huzur_islamda/firebase_options.dart';
import 'package:logging/logging.dart';

import 'app/app.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(AppScreen());
}
