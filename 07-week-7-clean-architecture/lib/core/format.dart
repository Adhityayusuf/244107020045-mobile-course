/// Helper formatting murni (tanpa widget) agar bisa diunit-test.
///
/// Dipindah dari `NoteTile` supaya presentation bebas logika formatting
/// (Refactoring Challenge #2).
///
/// Presisi sengaja menit (`yyyy-MM-dd HH:mm`) dalam zona lokal: cukup untuk
/// label "Diperbarui" dan membuat test deterministik tanpa detik.
String formatNoteTime(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
