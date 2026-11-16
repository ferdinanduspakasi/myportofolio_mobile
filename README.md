# MyPortfolio Mobile

Aplikasi portofolio pribadi sederhana untuk Android, iOS, dan platform lain yang didukung Flutter, dibuat sebagai pemenuhan tugas mata kuliah Pemrograman Berbasis Platform.

## Teknologi

- Flutter dengan Dart SDK `^3.13.7`.
- Material Design dan Material 3.
- Tidak memerlukan backend atau konfigurasi API untuk menjalankan aplikasi.

## Fitur Saat Ini
 
- Halaman utama dengan tiga kartu informasi (`InfoCard`): NPM, Name, dan Class.
- Tiga kartu aksi (`ItemCard`) dengan ikon dan warna berbeda: **Lihat Proyek** (biru), **Tambah Proyek** (hijau), dan **Logout** (oranye tua).
- SnackBar "Kamu telah menekan tombol [Nama Tombol]!" setiap kartu aksi ditekan.
- Fitur ekstra: dialog konfirmasi pada **Tambah Proyek**. Pilihan "Batal" dan "Lanjutkan" menghasilkan SnackBar yang berbeda.
- Tata letak tahan layar sempit: `InfoCard` memakai `Expanded` dan halaman dibungkus `SingleChildScrollView`.

## Menjalankan Proyek

Pastikan Flutter SDK sudah terpasang dan perangkat atau emulator tersedia. Dari terminal:

```sh
git clone https://github.com/ferdinanduspakasi/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
flutter run
```
Verifikasi kualitas kode:
 
```sh
flutter analyze   # target: No issues found!
flutter test      # seluruh widget test lulus
```

## Log Progres Mingguan

- **Tutorial 08**: Menyiapkan dasar aplikasi Flutter dan memisahkan bootstrap `main.dart` dari halaman `menu.dart`.
- **Tugas 7**: Menambahkan informasi profil, tiga kartu aksi dengan warna berbeda, dan SnackBar sesuai aksi.

## Refleksi
### Tugas 7

1. **Apa yang dimaksud dengan widget tree dan bagaimana hubungan induk-anak bekerja?**
   Widget tree adalah hierarki widget yang menyusun antarmuka, dari root sampai daun. Induk memegang anak lewat home, body, child, atau children: induk memberi batasan ukuran, anak menentukan ukurannya sendiri, dan induk menentukan posisinya. Anak juga dapat mengambil data leluhurnya (misalnya tema) lewat BuildContext, dan ikut dibangun ulang saat induknya dibangun ulang. Di proyek ini: MyApp → MaterialApp → MyHomePage → Scaffold → AppBar + SingleChildScrollView → Column → Row (3 InfoCard) dan GridView (3 ItemCard).

2. **Widget apa saja yang digunakan dan apa fungsinya?**
   - Kerangka: MaterialApp (tema, navigasi, halaman awal), Scaffold (struktur halaman), AppBar (judul).
   - Tata letak: SingleChildScrollView (halaman dapat digulir), Column/Row (susunan vertikal/horizontal), Expanded (membagi lebar sama), IntrinsicHeight (menyamakan tinggi kartu), GridView.count (kisi 3 kolom), Padding, Center, SizedBox, Container (jarak, posisi, dan ruang isi).
   - Tampilan dan interaksi: Card (kartu profil), Material + InkWell (permukaan berwarna dan respons sentuh kartu aksi), Icon, Text, SnackBar (umpan balik singkat), AlertDialog + TextButton (konfirmasi Tambah Proyek).
   - Buatan sendiri: MyApp, MyHomePage, InfoCard, ItemCard. ItemHomepage adalah kelas model, bukan widget.

3. **Apa fungsi MaterialApp dan mengapa biasa menjadi root widget?**
   MaterialApp menyediakan fitur tingkat aplikasi Material: tema, halaman awal, Navigator/rute, ScaffoldMessenger, dan lokalisasi. Karena dibutuhkan semua halaman, ia diletakkan di akar tree agar Scaffold, AppBar, dialog, dan Theme.of(context) di bawahnya otomatis konsisten dan berfungsi.

4. **Apa perbedaan StatelessWidget dan StatefulWidget? Kapan memilihnya?**
   StatelessWidget immutable: datanya hanya properti final dari konstruktor dan tidak punya objek State. StatefulWidget punya State yang bertahan selama widget ada di tree; data diubah lewat setState yang memicu build ulang, dan siklus hidupnya mencakup initState dan dispose. Pilih StatelessWidget untuk tampilan yang hanya mencerminkan data masukan (MyHomePage, InfoCard, ItemCard), dan StatefulWidget bila widget perlu mengubah data lokal, seperti isian formulir, penghitung, atau 
   daftar proyek.

5. **Apa itu BuildContext dan mengapa penting di metode build?**
   BuildContext adalah penanda posisi widget di dalam widget tree. Lewat context, widget mencari ke atas untuk mengambil layanan dari leluhurnya: Theme.of(context), MediaQuery.of(context), ScaffoldMessenger.of(context), dan Navigator.of(context). Context di build mewakili posisi widget itu, sehingga hasilnya sesuai cabang tree-nya (misalnya ItemCard menemukan Scaffold induknya untuk SnackBar). Setelah await, context harus dicek dengan context.mounted, seperti pada _onTap.

6. **Apa itu hot reload dan apa bedanya dengan hot restart? Kapan perlu restart penuh?**
   Hot reload menyuntikkan kode Dart baru ke aplikasi yang berjalan dan membangun ulang widget tree dengan state tetap terjaga. Hot restart memuat ulang seluruh kode dan menjalankan main() dari awal, sehingga state direset. Hot restart diperlukan saat perubahan menyentuh hal yang hanya berjalan sekali: isi main(), nilai awal variabel global/static, initState, atau perubahan tipe (enum menjadi kelas, tipe generik, StatelessWidget ↔ StatefulWidget). Restart penuh (hentikan lalu flutter run) diperlukan untuk perubahan sisi native: AndroidManifest.xml, Gradle, konfigurasi iOS, ikon aplikasi, atau penambahan plugin.

## AI Disclosure
### Tugas 7
Saya menggunakan OpenAI Codex untuk membantu pengerjaan Tugas 7 ini.\
Chat link: https://chatgpt.com/s/cx_6afaac25f5c0819197fa2466c6ee6bd1 

**Hal yang dibantu**: OpenAI Codex membantu membaca soal, mengubah `main.dart` dan `menu.dart`, serta extra feature. 

**Strategi prompting**: Saya memberikan soal dan rubrik lengkap, meminta AI bekerja per checkpoint agar saya bisa commit manual di setiap tahap, dan menegaskan agar implementasi tetap mengikuti instruksi. Pada tahap akhir, pengecekan dan revisi dilakukan secara manual dan menyeluruh.

**Keterbatasan**: Ada kalanya model AI menambahkan fitur seperti tata letak responsif dan dialog konfirmasi di luar kebutuhan maupun instruksi yang dilakukan. Sehingga perlu direvert. Ini menunjukan pengecekan dan revisi secara manual dan menyeluruh tetap perlu dilakukan.
