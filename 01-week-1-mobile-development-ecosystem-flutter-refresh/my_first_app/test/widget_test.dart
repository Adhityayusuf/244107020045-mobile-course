import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('profil mahasiswa tampil', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    expect(find.text('M.Adhitya Yusuf Al-Ayyubi'), findsOneWidget);
    expect(find.text('NIM 244107020045'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}
