import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/providers.dart';

import 'fakes.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang', () {
    final comment = Comment.fromJson({'id': 3, 'postId': 1});
    expect(comment.id, 3);
    expect(comment.name, '');
    expect(comment.email, '');
  });

  test('friendlyErrorMessage untuk 404', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/comments'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/comments'),
        statusCode: 404,
      ),
    );
    expect(friendlyErrorMessage(err), contains('404'));
  });

  test('provider komentar sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        commentRepositoryProvider.overrideWithValue(
          FakeCommentRepository(items: [
            const Comment(
              postId: 1,
              id: 1,
              name: 'Andi',
              email: 'andi@contoh.id',
              body: 'Bagus!',
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final comments = await container.read(commentsOfPostProvider(1).future);
    expect(comments.length, 1);
    expect(comments.first.name, 'Andi');
  });
}
