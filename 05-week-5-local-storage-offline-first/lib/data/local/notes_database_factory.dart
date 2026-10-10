import 'package:sqflite/sqflite.dart' as sqflite;
// Web-only: factory ini tidak diakses di VM (jaga `kIsWeb`), aman untuk test.
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as web;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Menyiapkan [sqflite.databaseFactory] agar `openDatabase` bisa dipakai di
/// platform web (sqlite3 wasm via `sqflite_common_ffi_web`).
///
/// - Native (Android/desktop): factory bawaan sqflite sudah tersedia, no-op.
/// - Web: `databaseFactory` diisi factory wasm.
///
/// Dipanggil sekali dari `main()` sebelum memakai repository lokal.
Future<void> initializeDatabaseFactory() async {
  if (!kIsWeb) return; // native: factory bawaan sudah tersedia
  sqflite.databaseFactory = web.databaseFactoryFfiWebNoWebWorker;
}
