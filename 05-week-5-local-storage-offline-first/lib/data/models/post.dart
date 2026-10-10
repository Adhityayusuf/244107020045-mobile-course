import 'dart:convert';

/// Model ringkas untuk cache-first read endpoint `GET /posts` (JSONPlaceholder).
/// Disimpan sebagai JSON di tabel `cached_posts`.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  String toJsonString() => jsonEncode({
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      });

  /// Dipakai untuk memuat kembali dari string JSON di tabel cache.
  Post copyFromCache(String payload) {
    final map =
        (jsonDecode(payload) as Map<String, dynamic>? ?? const {});
    return Post.fromJson(map);
  }
}
