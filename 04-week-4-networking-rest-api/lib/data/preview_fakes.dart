import 'dart:async';

import 'package:dio/dio.dart';

import 'models/comment.dart';
import 'models/post.dart';
import 'repositories/comment_repository.dart';
import 'repositories/post_repository.dart';

/// Repository palsu untuk screenshot dokumentasi yang deterministik
/// (dipakai hanya saat URL memakai `?demo=...`, bukan alur normal).
class FakePostRepository extends PostRepository {
  FakePostRepository({
    this.items = const [],
    this.pages = const {},
    this.throwError = false,
    this.hang = false,
  }) : super(Dio());

  final List<Post> items;
  final Map<int, List<Post>> pages;
  final bool throwError;
  final bool hang;

  Never _fail() {
    throw DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.connectionError,
    );
  }

  @override
  Future<List<Post>> fetchPosts() async {
    if (hang) return Completer<List<Post>>().future;
    if (throwError) _fail();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (throwError) _fail();
    return items;
  }

  @override
  Future<Post> fetchPost(int id) async {
    if (throwError) _fail();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return items.firstWhere(
      (post) => post.id == id,
      orElse: () => Post(userId: 1, id: id, title: 'Post $id', body: 'Isi post $id.'),
    );
  }

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    if (throwError) _fail();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return pages[page] ?? [];
  }
}

class FakeCommentRepository extends CommentRepository {
  FakeCommentRepository({this.items = const [], this.throwError = false})
      : super(Dio());

  final List<Comment> items;
  final bool throwError;

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionError,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return items;
  }
}

List<Post> demoPosts(int count, {int startId = 1}) {
  return List.generate(
    count,
    (i) => Post(
      userId: 1,
      id: startId + i,
      title: 'Judul post ${startId + i}',
      body: 'Isi ringkas post ${startId + i} dari API dummy.',
    ),
  );
}

List<Comment> demoComments(int postId) {
  return List.generate(
    2,
    (i) => Comment(
      postId: postId,
      id: i + 1,
      name: 'Komentator ${i + 1}',
      email: 'user${i + 1}@contoh.id',
      body: 'Komentar ke-${i + 1} untuk post $postId.',
    ),
  );
}
