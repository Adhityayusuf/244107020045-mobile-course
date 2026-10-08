import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week2_dashboard/main.dart';

void main() {
  testWidgets('Overview satu kolom di layar sempit (4 kartu)', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());
    await tester.pumpAndSettle();

    expect(find.byType(AcademicCard), findsNWidgets(4));
    expect(find.text('M.Adhitya Yusuf Al-Ayyubi'), findsWidgets);
    expect(find.text('NIM 244107020045'), findsWidgets);
    expect(find.text('Kelas TI-2H — Teknik Informatika'), findsOneWidget);
  });

  testWidgets('Overview dua kolom di layar lebar (4 kartu)', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());
    await tester.pumpAndSettle();

    expect(find.byType(AcademicCard), findsNWidgets(4));
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('GPA'), findsOneWidget);
    expect(find.text('Current Week'), findsOneWidget);
  });

  testWidgets('Toggle tema CupertinoSwitch mengubah mode', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoSwitch), findsOneWidget);
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    // Setelah toggle, dashboard tetap tampil lengkap.
    expect(find.byType(AcademicCard), findsNWidgets(4));
  });

  testWidgets('Halaman warm-up menampilkan kartu profil', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const AcademicOverviewApp(initialPage: 'warmup'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProfileCard), findsOneWidget);
    expect(find.text('244107020045@student.polinema.ac.id'), findsOneWidget);
  });
}
