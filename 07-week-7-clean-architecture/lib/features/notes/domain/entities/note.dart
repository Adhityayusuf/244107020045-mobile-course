/// Entity catatan: objek bisnis MURNI.
///
/// Tanpa import Flutter, tanpa `toMap`/`fromMap`/`toJson` (mapping hanya
/// ada di model pada layer data). Kolom `dirty` menandai catatan yang
/// belum tersinkron ke server.
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
