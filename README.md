# MyPortfolio Mobile

Aplikasi portofolio pribadi sederhana untuk Android, iOS, dan platform lain yang didukung Flutter, dibuat sebagai pemenuhan tugas mata kuliah Pemrograman Berbasis Platform.

## Teknologi

- Flutter dengan Dart SDK `^3.13.7`.
- Material Design dan Material 3.
- Tidak memerlukan backend atau konfigurasi API untuk menjalankan aplikasi.

## Fitur Saat Ini
 
- Halaman utama dengan tiga kartu informasi (`InfoCard`): NPM, Name, dan Class.
- Empat kartu aksi (`ItemCard`): **Lihat Proyek**, **Tambah Proyek**, **Tambah Pendidikan**, dan **Logout**.
- SnackBar "Kamu telah menekan tombol [Nama Tombol]!" setiap kartu aksi ditekan.
- Drawer untuk navigasi ke halaman utama, formulir proyek, dan formulir pendidikan.
- Formulir proyek dengan validasi nama dan deskripsi, pilihan kategori, teknologi, serta tautan; isian ditampilkan dalam dialog dan belum disimpan ke database.
- Tombol **Tambah Proyek** membuka formulir, dan tombol Back kembali ke halaman sebelumnya.
- Formulir pendidikan dengan validasi nama institusi dan bidang studi, pilihan jenjang, URL logo opsional, deskripsi, dan tanggal selesai opsional. Ringkasan input ditampilkan dalam dialog; data belum disimpan ke database.
- Pratinjau logo dari URL dengan indikator pemuatan dan pesan jika gambar tidak dapat dimuat.

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
- **Tutorial 09**: Menambahkan drawer, formulir proyek dengan validasi dan dialog ringkasan, navigasi, serta merapikan halaman dan widget ke direktori `screens/` dan `widgets/`.
- **Tugas 8**: Menambahkan formulir Education berdasarkan model portofolio, navigasi dari kartu dan drawer, validasi, dialog ringkasan, pemilih tanggal, serta pratinjau logo.

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

### Tugas 8

1. **Apa perbedaan `Navigator.push()`, `pushReplacement()`, dan `pop()`? Bagaimana navigasi Tugas 8 bekerja?**
   `push()` menambahkan halaman baru di atas halaman aktif, `pushReplacement()` mengganti halaman teratas dengan halaman baru, sedangkan `pop()` menutup halaman teratas dan kembali ke halaman sebelumnya. Kartu **Tambah Pendidikan** memakai `Navigator.push()`, sehingga tombol Back perangkat menutup formulir dan kembali ke beranda. Opsi **Home** pada drawer memakai `pushReplacement()` untuk mengganti formulir dengan halaman utama.

2. **Bagaimana `Scaffold`, `AppBar`, dan `Drawer` menjaga konsistensi halaman?**
   Kedua halaman memakai `Scaffold` sebagai kerangka, `AppBar` untuk judul, dan komponen `LeftDrawer` yang sama untuk navigasi. Warna indigo dipakai pada halaman utama melalui warna primer tema, serta pada AppBar dan tombol Simpan formulir agar identitas visual tetap konsisten.

3. **Mengapa tata letak formulir ini dipilih untuk layar terbatas?**
   Field disusun vertikal dalam `Column`, diberi jarak dengan `Padding`, dan ditempatkan di dalam `SingleChildScrollView`. Karena itu formulir tetap dapat digulir ketika layar sempit atau ruang terlihat berkurang saat keyboard tampil. Tanggal selesai memakai `showDatePicker()` karena field tersebut bertipe tanggal.

4. **Apa peran `GlobalKey<FormState>`, validator, dan `validate()`?**
   `GlobalKey<FormState>` memberi akses ke state formulir. Saat Simpan ditekan, `validate()` menjalankan validator setiap field dan dialog hanya muncul jika semuanya lolos. Nama institusi dan bidang studi yang kosong atau hanya berisi spasi ditolak; URL logo yang bukan URL HTTP(S) juga ditolak. Memilih keyboard yang sesuai hanya membantu mengetik, tetapi tidak memastikan nilai wajib terisi atau URL benar.

## AI Disclosure
### Tugas 7
Saya menggunakan OpenAI Codex untuk membantu pengerjaan Tugas 7 ini.\
Chat link: https://chatgpt.com/s/cx_6afaac25f5c0819197fa2466c6ee6bd1 

**Hal yang dibantu**: OpenAI Codex membantu membaca soal, mengubah `main.dart` dan `menu.dart`, serta extra feature. 

**Strategi prompting**: Saya memberikan soal dan rubrik lengkap, meminta AI bekerja per checkpoint agar saya bisa commit manual di setiap tahap, dan menegaskan agar implementasi tetap mengikuti instruksi. Pada tahap akhir, pengecekan dan revisi dilakukan secara manual dan menyeluruh.

**Keterbatasan**: Ada kalanya model AI menambahkan fitur seperti tata letak responsif dan dialog konfirmasi di luar kebutuhan maupun instruksi yang dilakukan. Sehingga perlu direvert. Ini menunjukan pengecekan dan revisi secara manual dan menyeluruh tetap perlu dilakukan.

### Tugas 8

Saya menggunakan OpenAI Codex untuk membantu pengerjaan Tugas 8 ini.\
Chat link: https://chatgpt.com/s/cx_6b0321740a648191b6b07f4c2038ae53 

**Hal yang dibantu**: Implementasi formulir Education, navigasi, validasi, pratinjau logo, dan widget tests

**Strategi prompting**: Saya memberikan instruksi dan rubrik Tugas 8, meminta implementasi mengikuti Tutorial 09 tanpa improvisasi, serta meminta riwayat commit bertahap. README dan extra feature saya tunda sampai tahap berikutnya. Setelah itu, saya meminta pratinjau logo sebagai extra feature.

**Keterbatasan dan pemeriksaan manual**: Widget tests menemukan overflow setelah kartu pendidikan ditambahkan serta ketidakcocokan simulasi tombol Back; layout dan pengujian kemudian diperbaiki. Pemeriksaan screenshot juga menunjukkan bahwa URL halaman berkas Wikipedia berformat SVG tidak dapat dimuat oleh pratinjau gambar saat ini. Pratinjau menampilkan pesan gagal-muat untuk URL atau format gambar yang tidak dapat dirender. Saya menjalankan `flutter analyze` dan widget tests setelah perbaikan; hasil terakhir tidak menemukan isu dan seluruh 11 test lulus.
