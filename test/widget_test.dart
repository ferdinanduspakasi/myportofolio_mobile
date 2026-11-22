// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

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

  testWidgets('menampilkan kartu aksi dengan warna yang berbeda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Tambah Pendidikan'), findsOneWidget);
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

  testWidgets(
    'kartu Tambah Pendidikan membuka formulir dan tombol kembali pulang',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Tambah Pendidikan'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationFormPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsNothing);
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'drawer membuka form Education dan Home kembali ke halaman utama',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Add Project'), findsOneWidget);
      await tester.tap(find.text('Add Education'));
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsOneWidget);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsNothing);
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'form menolak nama institusi dan bidang studi kosong atau spasi',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Institusi'),
        '   ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Bidang Studi'),
        '',
      );
      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Bidang studi tidak boleh kosong!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('form menolak URL logo selain http dan https', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Institusi'),
      'Universitas Indonesia',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Bidang Studi'),
      'Ilmu Komputer',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL Logo Institusi'),
      'ftp://example.com/logo.png',
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Masukkan URL logo valid dengan http atau https.'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'URL logo valid menampilkan pratinjau dan URL kosong menyembunyikannya',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

      final Finder logoField = find.widgetWithText(
        TextFormField,
        'URL Logo Institusi',
      );
      await tester.enterText(logoField, 'https://example.com/logo.png');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      expect(find.text('Pratinjau logo institusi'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('education-logo-preview-image')),
        findsOneWidget,
      );

      await tester.enterText(logoField, '');
      await tester.pump();

      expect(find.text('Pratinjau logo institusi'), findsNothing);
    },
  );

  testWidgets('form menampilkan ringkasan input valid di dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama Institusi'),
      'Universitas Indonesia',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Bidang Studi'),
      'Ilmu Komputer',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'URL Logo Institusi'),
      'https://example.com/logo.png',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi (opsional)'),
      'Program sarjana',
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Education successfully added!'), findsOneWidget);
    expect(find.text('Institution: Universitas Indonesia'), findsOneWidget);
    expect(find.text('Degree: Bachelor\'s'), findsOneWidget);
    expect(find.text('Field of Study: Ilmu Komputer'), findsOneWidget);
    expect(find.text('Logo URL: https://example.com/logo.png'), findsOneWidget);
    expect(find.text('Description: Program sarjana'), findsOneWidget);
    expect(find.text('End Date: -'), findsOneWidget);
  });

  testWidgets('form Education dapat digulir pada layar ponsel', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.reset);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    final Finder institutionField = find.widgetWithText(
      TextFormField,
      'Nama Institusi',
    );
    await tester.ensureVisible(institutionField);
    await tester.showKeyboard(institutionField);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));

    expect(tester.takeException(), isNull);
    expect(find.text('Simpan'), findsOneWidget);
  });
}
