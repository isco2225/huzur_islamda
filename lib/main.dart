import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'app/app.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(AppScreen());
}
