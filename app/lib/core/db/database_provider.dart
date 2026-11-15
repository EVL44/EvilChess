import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The app's local database. Tests override it with an in-memory one.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
