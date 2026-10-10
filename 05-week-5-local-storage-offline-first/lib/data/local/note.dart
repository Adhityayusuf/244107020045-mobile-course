/// Model catatan. Kolom `dirty` menandai catatan yang belum tersinkron
/// ke server; dipakai untuk antrean sinkronisasi + badge UI.
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

  Note copyWith({String? body}) {
    return Note(
      id: id,
      title: title,
      body: body ?? this.body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'updated_at': updatedAt.toIso8601String(),
        'dirty': dirty ? 1 : 0,
      };

  /// Mapping defensif: field yang hilang tidak membuat aplikasi crash.
  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: (map['id'] as num?)?.toInt(),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      dirty: ((map['dirty'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}
