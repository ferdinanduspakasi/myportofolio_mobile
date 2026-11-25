import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Widget educationForm() {
  return ChangeNotifierProvider(
    create: (context) => AuthState(ApiClient()),
    child: const MaterialApp(home: EducationFormPage()),
  );
}

void main() {
  testWidgets('menampilkan 3 InfoCard dengan identitas pemilik', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: ApiClient()));

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
    await tester.pumpWidget(MyApp(apiClient: ApiClient()));

    expect(find.text('Lihat Pengalaman'), findsOneWidget);
    expect(find.text('Tambah Pengalaman'), findsOneWidget);
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

    await tester.pumpWidget(MyApp(apiClient: ApiClient()));

    expect(tester.takeException(), isNull);
  });

  testWidgets('daftar dan detail Experience dapat dibuka tanpa login', (
    WidgetTester tester,
  ) async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.path, '/api/v1/experiences/');
      expect(request.headers['authorization'], isNull);
      return http.Response(
        '[{"title":"Magang","description":"Membuat aplikasi",'
        '"category":"internship","started_at":"2025-01-01","ended_at":null}]',
        200,
      );
    });
    await tester.pumpWidget(MyApp(apiClient: ApiClient(client: client)));

    await tester.tap(find.text('Lihat Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.text('Internship\nMembuat aplikasi'), findsOneWidget);
    await tester.tap(find.text('Magang'));
    await tester.pumpAndSettle();
    expect(find.text('Category: Internship'), findsOneWidget);
    expect(find.text('Ongoing'), findsOneWidget);
  });

  testWidgets('login membuka form, POST Experience berhasil, dan logout', (
    WidgetTester tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path == '/api/v1/auth/token/') {
        return http.Response('{"token":"test-token"}', 200);
      }
      if (request.url.path == '/api/v1/experiences/') {
        expect(request.method, 'POST');
        expect(request.headers['authorization'], 'Token test-token');
        final payload = jsonDecode(request.body) as Map<String, dynamic>;
        expect(
          payload.keys,
          unorderedEquals([
            'title',
            'description',
            'category',
            'started_at',
            'ended_at',
            'thumbnail',
          ]),
        );
        expect(payload['title'], 'Pengalaman baru');
        expect(payload['description'], 'Membuat aplikasi');
        expect(payload['category'], 'full-time');
        expect(payload['started_at'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
        expect(payload['ended_at'], isNull);
        expect(payload['thumbnail'], isNull);
        return http.Response(jsonEncode(payload), 201);
      }
      expect(request.url.path, '/api/v1/auth/logout/');
      expect(request.headers['authorization'], 'Token test-token');
      return http.Response('', 204);
    });
    await tester.pumpWidget(MyApp(apiClient: ApiClient(client: client)));

    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'admin',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Pengalaman baru',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Membuat aplikasi',
    );
    final startDate = find.text('Select date').first;
    await tester.ensureVisible(startDate);
    await tester.tap(startDate);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Pengalaman berhasil ditambahkan!'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Logout berhasil.'), findsOneWidget);
    final homeContext = tester.element(find.byType(MyHomePage));
    expect(homeContext.read<AuthState>().isLoggedIn, isFalse);
  });

  testWidgets(
    'kartu Tambah Pendidikan membuka formulir dan tombol kembali pulang',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(apiClient: ApiClient()));

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
      await tester.pumpWidget(MyApp(apiClient: ApiClient()));

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Add Experience'), findsOneWidget);
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
      await tester.pumpWidget(educationForm());

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
    await tester.pumpWidget(educationForm());

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
      await tester.pumpWidget(educationForm());

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
    await tester.pumpWidget(educationForm());

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

    await tester.pumpWidget(educationForm());
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
