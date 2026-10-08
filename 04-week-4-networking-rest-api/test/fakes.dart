import 'package:dio/dio.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/data/repositories/post_repository.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }

  @override
  Future<Post> fetchPost(int id) async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts/$id'),
        type: DioExceptionType.connectionError,
      );
    }
    return (items ?? const []).firstWhere(
      (post) => post.id == id,
      orElse: () => Post(userId: 1, id: id, title: 'Post $id', body: 'Isi'),
    );
  }

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    return fetchPosts();
  }
}

class FakeCommentRepository extends CommentRepository {
  FakeCommentRepository({this.items, this.statusCode}) : super(Dio());
  final List<Comment>? items;
  final int? statusCode;

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    if (statusCode != null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: statusCode,
        ),
      );
    }
    return items ?? const [];
  }
}
