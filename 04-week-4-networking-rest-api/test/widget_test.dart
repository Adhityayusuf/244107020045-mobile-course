import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/main.dart';
import 'package:week4_api/widgets/post_tile.dart';

import 'fakes.dart';

void main() {
  testWidgets('PostTile menampilkan judul, isi, dan id post', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PostTile(
            post: Post(userId: 1, id: 7, title: 'Judul uji', body: 'Isi uji'),
          ),
        ),
      ),
    );

    expect(find.text('Judul uji'), findsOneWidget);
    expect(find.text('Isi uji'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('daftar penuh menampilkan data dari repository palsu',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: [
              const Post(userId: 1, id: 1, title: 'Post A', body: 'Isi A'),
              const Post(userId: 1, id: 2, title: 'Post B', body: 'Isi B'),
            ]),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Halaman awal adalah paged; pindah ke daftar penuh.
    await tester.tap(find.byTooltip('Daftar penuh'));
    await tester.pumpAndSettle();

    expect(find.text('Post A'), findsOneWidget);
    expect(find.text('Post B'), findsOneWidget);
  });

  testWidgets('PagedPostPage menampilkan data dari repository palsu',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(items: [
              const Post(userId: 1, id: 1, title: 'Paged A', body: 'Isi A'),
            ]),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paged A'), findsOneWidget);
    expect(find.text('Semua data termuat.'), findsOneWidget);
  });
}
