import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/connection/local_db_paths.dart';

Future<String> resolvePakposDirectory({String? overrideDirectory}) async {
  if (overrideDirectory != null) {
    return p.join(overrideDirectory, 'pakpos');
  }
  final support = await getApplicationSupportDirectory();
  return p.join(support.path, 'pakpos');
}

/// Opens the local bootstrap database before a business is provisioned.
Future<AppDatabase> openLocalBootstrapDatabase({
  String? storageDirectoryOverride,
}) async {
  final dir = await resolvePakposDirectory(
    overrideDirectory: storageDirectoryOverride,
  );
  final filePath = p.join(dir, localBootstrapDatabaseFileName);
  return AppDatabase(_fileExecutor(filePath));
}

/// Opens a tenant database file for a provisioned business.
Future<AppDatabase> openBusinessDatabase({
  required String businessId,
  String? storageDirectoryOverride,
}) async {
  final dir = await resolvePakposDirectory(
    overrideDirectory: storageDirectoryOverride,
  );
  final filePath = p.join(dir, businessDatabaseFileName(businessId));
  return AppDatabase(_fileExecutor(filePath));
}

QueryExecutor _fileExecutor(String path) {
  return LazyDatabase(() async {
    final file = File(path);
    await file.parent.create(recursive: true);
    return NativeDatabase(file);
  });
}

/// In-memory database for automated tests.
AppDatabase openMemoryDatabase() {
  return AppDatabase(NativeDatabase.memory());
}

/// File-backed database in a temp directory (reopen tests).
AppDatabase openFileDatabase(String filePath) {
  return AppDatabase(LazyDatabase(() async => NativeDatabase(File(filePath))));
}
