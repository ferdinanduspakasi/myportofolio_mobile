// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  testWidgets('menampilkan 3 InfoCard dengan identitas pemilik', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506602643'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Ferdinandus Pakasi'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text('PBP D'), findsOneWidget);
  });

  testWidgets('menampilkan 3 kartu aksi dengan warna yang berbeda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    final List<Color> colors = const MyHomePage().items
        .map((ItemHomepage item) => item.color)
        .toList();
    expect(colors.toSet().length, colors.length);
  });

  testWidgets('tidak overflow pada layar sempit 360x640', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    expect(tester.takeException(), isNull);
  });

  testWidgets('menekan Logout memunculkan SnackBar sesuai nama tombol', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
  });

  testWidgets('Tambah Proyek: dialog muncul dan Batal membatalkan aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Tambah Proyek dibatalkan.'), findsOneWidget);
  });

  testWidgets('Tambah Proyek: Lanjutkan melanjutkan aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tambah Proyek dilanjutkan. Formulir belum tersedia.'),
      findsOneWidget,
    );
  });
}
