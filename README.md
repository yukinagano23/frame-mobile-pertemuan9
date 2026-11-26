# StokKu - Aplikasi Manajemen Inventaris / Stok Barang Sederhana

**StokKu** adalah aplikasi Android sederhana untuk membantu pemilik usaha kecil (warung, toko, UMKM) mencatat dan memantau stok barang. Pengguna dapat mendaftarkan barang, mencatat barang masuk dan keluar, serta mendapat peringatan visual otomatis ketika stok sebuah barang menipis.

Aplikasi dibangun dengan **Flutter** dan **Material Design 3**. Rancangan antarmukanya dibuat dengan Google Stitch, lalu diterjemahkan ke kode Flutter. State aplikasi dikelola dengan **Provider**.

---

## Daftar Isi

1. [Fitur Utama](#fitur-utama)
2. [Halaman Aplikasi](#halaman-aplikasi)
3. [Cara Menggunakan Aplikasi](#cara-menggunakan-aplikasi)
4. [Teknologi yang Digunakan](#teknologi-yang-digunakan)
5. [State Management](#state-management)
6. [Struktur Proyek](#struktur-proyek)
7. [Model Data](#model-data)
8. [Alur Data](#alur-data)
9. [Cara Menjalankan](#cara-menjalankan)
10. [Keterbatasan dan Pengembangan Lanjutan](#keterbatasan-dan-pengembangan-lanjutan)

---

## Fitur Utama

| Fitur | Keterangan |
|---|---|
| Tambah barang baru | Mendaftarkan barang dengan nama, satuan, stok awal, batas minimum stok, dan foto (opsional). |
| Catat mutasi stok | Tombol cepat **Barang Masuk** dan **Barang Keluar** yang langsung memperbarui jumlah stok. |
| Riwayat mutasi | Setiap perubahan stok tercatat lengkap dengan jumlah, catatan, tanggal, dan jam. |
| Peringatan stok menipis | Badge merah **"Stok Menipis"**, angka stok merah, dan garis aksen merah muncul otomatis jika stok di bawah batas minimum. |
| Filter stok menipis | Chip filter untuk menampilkan hanya barang yang stoknya di bawah batas minimum. |
| Pencarian | Mencari barang berdasarkan nama. |
| Ringkasan | Kartu ringkasan jumlah total barang dan jumlah barang yang stoknya menipis. |
| Ubah batas minimum | Ikon edit di halaman detail untuk mengubah batas minimum stok. |
| Hapus barang | Ikon hapus di halaman detail, dengan dialog konfirmasi. |
| Validasi | Barang keluar tidak boleh melebihi stok tersedia, dan nama barang wajib diisi saat menambah barang. |

---

## Halaman Aplikasi

### 1. Daftar Stok (halaman utama)
- Kolom pencarian, dua kartu ringkasan (**Total Barang** dan **Stok Menipis**), serta chip filter **Semua** dan **Stok Menipis (n)**.
- Setiap barang tampil sebagai kartu berisi ikon, nama, satuan, batas minimum, dan jumlah stok.
- Barang dengan stok di bawah batas minimum diberi badge merah dan garis merah di tepi kiri kartu. Barang yang stoknya aman memakai angka hijau.
- Tombol **+ Tambah Barang** (Floating Action Button) di kanan bawah.
- Tiga kondisi tampilan yang muncul otomatis sesuai data:

| Kondisi | Syarat | Tampilan |
|---|---|---|
| Daftar normal | Ada barang | Daftar kartu barang |
| Daftar kosong | Belum ada barang, atau semua barang sudah dihapus | "Belum ada barang" |
| Stok aman | Filter "Stok Menipis" aktif dan tidak ada barang di bawah batas minimum | "Semua stok aman 🎉" |

Jika pencarian tidak menemukan hasil, tampil pesan "Barang tidak ditemukan".

### 2. Detail & Mutasi Stok
- Kartu detail berisi nama, satuan, kategori, stok saat ini dalam angka besar, batas minimum, dan indikator progres stok.
- Tombol **Barang Masuk** (hijau) dan **Barang Keluar** (cokelat).
- Menekan tombol tersebut membuka *bottom sheet* berisi pilihan jenis mutasi, input jumlah dengan stepper (+/-), catatan opsional, dan tombol **Simpan**.
- Bagian **Riwayat Mutasi** menampilkan daftar kronologis (maksimal 10 catatan terakhir).
- Ikon edit untuk mengubah batas minimum dan ikon hapus untuk menghapus barang.

### 3. Tambah Barang Baru
- Form dengan kolom **Nama Barang** (wajib), **Satuan** (pcs, kg, liter, dus, pak), **Stok Awal**, **Batas Minimum Stok**, dan area **Foto Barang** (opsional).
- Tombol **Simpan** dan **Batal**.
- Jika nama kosong, kolom berubah merah dan menampilkan pesan "Nama barang wajib diisi".

---

## Cara Menggunakan Aplikasi
 
### 1. Melihat daftar stok
1. Buka aplikasi. Halaman **Daftar Stok** langsung tampil.
2. Lihat dua kartu di bagian atas: **Total Barang** menunjukkan jumlah seluruh barang, dan **Stok Menipis** menunjukkan jumlah barang yang stoknya di bawah batas minimum.
3. Baca daftar barang di bawahnya. Setiap kartu memuat nama, satuan, batas minimum, dan jumlah stok di sisi kanan.
**Cara membaca indikator warna:**
 
| Tampilan | Arti |
|---|---|
| Badge merah **"Stok Menipis"**, angka stok merah, garis merah di kiri kartu | Stok berada di bawah batas minimum. Segera restok. |
| Angka stok hijau, tanpa badge | Stok masih aman. |
 
### 2. Mencari barang
Ketik nama barang di kolom **"Cari barang"** di bagian atas. Daftar akan menyaring otomatis. Jika tidak ada yang cocok, muncul pesan "Barang tidak ditemukan".
 
### 3. Menampilkan hanya barang yang stoknya menipis
1. Ketuk chip **Stok Menipis (n)** di bawah kartu ringkasan.
2. Daftar hanya menampilkan barang yang stoknya di bawah batas minimum.
3. Ketuk chip **Semua** untuk kembali melihat seluruh barang.
Jika tidak ada barang yang menipis, akan muncul pesan **"Semua stok aman 🎉"**.
 
### 4. Menambah barang baru
1. Di halaman Daftar Stok, ketuk tombol **+ Tambah Barang** di kanan bawah.
2. Isi form:
   - **Nama Barang** (wajib). Contoh: `Minyak Goreng Bimoli 1L`.
   - **Satuan**. Pilih dari pcs, kg, liter, dus, atau pak.
   - **Stok Awal**. Gunakan tombol **+** dan **-**, atau ketik angkanya langsung.
   - **Batas Minimum Stok**. Aplikasi akan memberi peringatan jika stok turun di bawah angka ini.
   - **Foto Barang** (opsional, belum berfungsi pada versi ini).
3. Ketuk **Simpan**. Barang baru langsung muncul di daftar dan muncul pesan "Barang berhasil ditambahkan".
4. Ketuk **Batal** atau tombol kembali jika ingin membatalkan.
> Jika **Nama Barang** dikosongkan, kolom berubah merah dan muncul pesan "Nama barang wajib diisi".
 
### 5. Mencatat barang masuk (restok)
1. Ketuk kartu barang di halaman Daftar Stok untuk membuka halaman **Detail & Mutasi Stok**.
2. Ketuk tombol hijau **+ Barang Masuk**.
3. Pada panel yang muncul, atur **Jumlah** dengan tombol **+** dan **-**, atau ketik angkanya.
4. (Opsional) Isi **Catatan**, misalnya `Dari supplier A`.
5. Ketuk **Simpan**. Muncul pesan "Stok berhasil diperbarui".
6. Angka stok bertambah, dan catatan baru muncul di **Riwayat Mutasi** dengan tanda hijau (misalnya `+10 kg`).
7. Jika stok kini sudah mencapai atau melewati batas minimum, badge **"Stok Menipis"** hilang otomatis.
### 6. Mencatat barang keluar (penjualan atau pemakaian)
1. Buka halaman detail barang, lalu ketuk tombol cokelat **- Barang Keluar**.
2. Atur **Jumlah** dan isi **Catatan** bila perlu, misalnya `Penjualan harian`.
3. Ketuk **Simpan**.
4. Angka stok berkurang, dan catatan muncul di Riwayat Mutasi dengan tanda cokelat (misalnya `-4 kg`).
5. Jika stok turun di bawah batas minimum, badge **"Stok Menipis"** muncul otomatis. Perubahan ini juga terlihat di Daftar Stok.
> Jumlah barang keluar tidak boleh melebihi stok yang tersedia. Jika berlebih, muncul pesan "Jumlah melebihi stok tersedia" dan tombol **Simpan** dinonaktifkan sampai jumlahnya diperbaiki.
 
Di panel yang sama, kamu bisa berpindah antara **Barang Masuk** dan **Barang Keluar** lewat tombol pilihan di bagian atas panel, tanpa menutupnya.
 
### 7. Melihat riwayat mutasi
Di halaman detail, gulir ke bagian **Riwayat Mutasi**. Setiap catatan menampilkan:
- ikon panah (hijau untuk masuk, cokelat untuk keluar),
- catatan yang kamu isi,
- tanggal dan jam pencatatan,
- jumlah perubahan stok.
Aplikasi menampilkan maksimal 10 catatan terbaru.
 
### 8. Mengubah batas minimum stok
1. Di halaman detail barang, ketuk ikon **pensil** pada kartu barang.
2. Ubah angka batas minimum dengan tombol **+** dan **-** atau ketik langsung.
3. Ketuk **Simpan**. Status stok menipis langsung dihitung ulang berdasarkan batas yang baru.
### 9. Menghapus barang
1. Di halaman detail barang, ketuk ikon **tempat sampah** di pojok kanan atas.
2. Pada dialog konfirmasi, ketuk **Hapus**. Barang beserta riwayat mutasinya akan dihapus, dan aplikasi kembali ke Daftar Stok.
3. Jika semua barang sudah dihapus, Daftar Stok menampilkan "Belum ada barang".
> **Perhatian:** data hanya disimpan di memori. Saat aplikasi ditutup sepenuhnya, data kembali ke data contoh awal.
 
### Contoh alur penggunaan sehari-hari
 
| Situasi | Langkah |
|---|---|
| Ada barang baru dari supplier | **+ Tambah Barang**, isi form, lalu **Simpan** |
| Barang terjual | Buka barang, ketuk **- Barang Keluar**, isi jumlah, lalu **Simpan** |
| Barang baru datang | Buka barang, ketuk **+ Barang Masuk**, isi jumlah, lalu **Simpan** |
| Ingin tahu apa yang harus dibeli | Ketuk chip **Stok Menipis**, lalu lihat daftar barang yang perlu di-restok |
| Ingin memeriksa pergerakan stok sebuah barang | Buka barang, lalu lihat **Riwayat Mutasi** |
 
---


## Teknologi yang Digunakan

| Teknologi | Fungsi |
|---|---|
| **Flutter** (SDK 3.33 ke atas) | Framework UI lintas platform. Target utama aplikasi ini adalah Android. |
| **Dart** | Bahasa pemrograman. |
| **Material Design 3** | Sistem desain dan komponen UI (`useMaterial3: true`, `ColorScheme.fromSeed`). |
| **Provider** (`^6.1.2`) | Pustaka state management berbasis `ChangeNotifier`. |
| **Google Stitch** | Alat desain UI berbasis AI yang dipakai untuk membuat rancangan awal. |
| **Visual Studio Code** | Lingkungan pengembangan. |

Detail teknis yang dipakai:
- Widget bawaan Flutter seperti `ListView`, `Scaffold`, `FloatingActionButton.extended`, `showModalBottomSheet`, `AlertDialog`, `SnackBar`, `LinearProgressIndicator`, dan `DropdownButtonFormField`.
- `CustomPainter` untuk membuat garis putus-putus pada area unggah foto.
- Tidak ada paket tambahan selain `provider`. Format tanggal dibuat manual, tanpa `intl`.

---

## State Management

### Pendekatan
Aplikasi memakai **Provider** dengan pola **`ChangeNotifier`**. Seluruh data inventaris yang dipakai bersama oleh banyak halaman disimpan di satu tempat, yaitu kelas `InventoryProvider`. Dengan begitu, setiap perubahan data otomatis tercermin di semua halaman tanpa perlu menyegarkan layar secara manual.

### Komponen

| Komponen | Peran | Lokasi |
|---|---|---|
| `InventoryProvider extends ChangeNotifier` | Menyimpan state dan logika bisnis | `main.dart` |
| `ChangeNotifierProvider` | Menyediakan satu instance `InventoryProvider` ke seluruh pohon widget | `main()` di `main.dart` |
| `context.watch<InventoryProvider>()` | Membaca state di dalam `build` dan memicu *rebuild* saat data berubah | Halaman Daftar Stok dan Halaman Detail |
| `context.read<InventoryProvider>()` | Memanggil aksi (tanpa *rebuild*) dari tombol atau fungsi | Semua halaman |
| `notifyListeners()` | Memberi tahu semua pendengar bahwa data berubah | Dipanggil di setiap method yang mengubah data |

Penyediaan state dilakukan di titik tertinggi aplikasi:

```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => InventoryProvider(),
      child: const StokKuApp(),
    ),
  );
}
```

### State yang disimpan di `InventoryProvider`

| State | Tipe | Keterangan |
|---|---|---|
| `_items` | `List<StockItem>` | Seluruh daftar barang beserta riwayat mutasinya |
| `_filter` | `StockFilter` | Filter aktif: `semua` atau `menipis` |
| `_query` | `String` | Kata kunci pencarian |

### Getter (state turunan)

| Getter | Keterangan |
|---|---|
| `totalCount` | Jumlah seluruh barang |
| `lowCount` | Jumlah barang yang stoknya di bawah batas minimum |
| `visibleItems` | Daftar barang setelah filter dan pencarian diterapkan |
| `isLow(item)` | `true` jika `item.stock < item.minStock` |
| `byId(id)` | Mengambil satu barang berdasarkan id |

### Aksi (method yang mengubah state)

| Method | Fungsi |
|---|---|
| `addItem(...)` | Menambah barang baru. Jika stok awal lebih dari 0, otomatis dicatat sebagai mutasi masuk "Stok awal". |
| `addMutation(id, type, qty, note)` | Mencatat barang masuk atau keluar. Mengembalikan pesan error (`String`) bila gagal, atau `null` bila berhasil. |
| `updateMinStock(id, value)` | Mengubah batas minimum stok. |
| `removeItem(id)` | Menghapus barang. |
| `setFilter(filter)` | Mengganti filter Semua atau Stok Menipis. |
| `setQuery(query)` | Mengubah kata kunci pencarian. |

### Pembagian state global dan state lokal
- **State global (Provider):** data inventaris, filter, dan pencarian. Data ini dipakai lintas halaman.
- **State lokal (`setState`):** isi form, pesan error validasi, dan pilihan jenis mutasi di bottom sheet. Data ini hanya relevan bagi satu widget dan tidak perlu dibagikan.

### Contoh efek state management di aplikasi
1. Pengguna mencatat **Barang Keluar** di halaman Detail, lalu `addMutation()` memanggil `notifyListeners()`.
2. Halaman Detail memperbarui angka stok dan riwayat mutasi.
3. Halaman Daftar Stok di belakangnya ikut diperbarui: angka stok berubah, ringkasan "Stok Menipis" ikut bertambah atau berkurang, dan badge merah muncul atau hilang sesuai batas minimum.

---

## Struktur Proyek

Proyek terdiri dari 3 file kode di dalam folder `lib/`:

```
lib/
├── main.dart                  # Entry point, tema, model, state (Provider),
│                              # widget bersama, dan Halaman Daftar Stok
├── detail_mutasi_page.dart    # Halaman Detail & Mutasi Stok + bottom sheet mutasi
└── tambah_barang_page.dart    # Halaman Tambah Barang Baru
```

Widget yang dipakai bersama oleh beberapa halaman (`AppColors`, `LowStockBadge`, `QtyStepper`, `formatMutationDate`) diletakkan di `main.dart`. Ketiga file saling mengimpor (*circular import*). Hal ini diperbolehkan di Dart, tetapi pada proyek yang lebih besar, file bersama sebaiknya dipisah ke folder tersendiri (misalnya `models/`, `providers/`, dan `widgets/`).

---

## Model Data

```dart
enum MutationType { masuk, keluar }

class Mutation {
  final MutationType type;  // masuk / keluar
  final int qty;            // jumlah
  final String note;        // catatan
  final DateTime date;      // waktu pencatatan
}

class StockItem {
  final String id;
  String name;
  String unit;              // pcs, kg, liter, dus, pak
  String category;
  int stock;                // stok saat ini
  int minStock;             // batas minimum stok
  IconData icon;
  final List<Mutation> history;  // riwayat, terbaru di indeks 0
}
```

**Aturan stok menipis:** sebuah barang dianggap menipis jika `stock < minStock`.

---

## Alur Data

```
   Aksi pengguna (tombol, form)
              │
              ▼
   context.read<InventoryProvider>().aksi()
              │
              ▼
   InventoryProvider mengubah data  ──►  notifyListeners()
              │
              ▼
   Widget yang memakai context.watch<...>() otomatis di-build ulang
              │
              ▼
   UI terbarui (angka stok, badge, filter, ringkasan, riwayat)
```

---

## Cara Menjalankan

### Prasyarat
- Flutter SDK terpasang (disarankan versi **3.33 atau lebih baru**, karena kode memakai `initialValue` pada `DropdownButtonFormField`).
- Android Studio (untuk emulator Android) atau perangkat Android fisik, serta VS Code atau Android Studio sebagai editor.
- Jalankan `flutter doctor` untuk memastikan lingkungan siap.

### Langkah-langkah
1. Buat proyek Flutter baru:
   ```bash
   flutter create stokku
   cd stokku
   ```
2. Tambahkan paket Provider:
   ```bash
   flutter pub add provider
   ```
   Hasilnya di `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     provider: ^6.1.2
   ```
3. Salin ketiga file (`main.dart`, `detail_mutasi_page.dart`, `tambah_barang_page.dart`) ke folder `lib/`, lalu timpa `main.dart` bawaan.
4. Hapus file `test/widget_test.dart` bawaan (file ini masih merujuk ke `MyApp`), atau sesuaikan isinya dengan `StokKuApp`.
5. Ambil dependensi dan jalankan aplikasi:
   ```bash
   flutter pub get
   flutter run
   ```

### Data contoh
Saat pertama dijalankan, aplikasi memuat 5 barang contoh:

| Barang | Satuan | Stok | Minimum | Status |
|---|---|---|---|---|
| Beras 5 kg | kg | 3 | 10 | Menipis |
| Minyak Goreng 1 L | liter | 25 | 10 | Aman |
| Gula Pasir | kg | 4 | 8 | Menipis |
| Telur | kg | 40 | 15 | Aman |
| Kopi Sachet | pcs | 6 | 20 | Menipis |

Untuk memulai dengan daftar kosong, ubah isi fungsi `_seed()` di `main.dart` menjadi `return [];`.

---

## Keterbatasan dan Pengembangan Lanjutan

**Keterbatasan saat ini**
- **Data belum permanen.** Seluruh data disimpan di memori, sehingga hilang ketika aplikasi ditutup.
- **Unggah foto belum berfungsi.** Area foto baru berupa tampilan.
- **Hanya satu pengguna,** tanpa login dan tanpa sinkronisasi antarperangkat.

**Ide pengembangan**
- Penyimpanan lokal permanen dengan `sqflite`, `drift`, `hive`, atau `shared_preferences`.
- Unggah dan tampil foto barang dengan `image_picker`.
- Notifikasi pengingat ketika ada stok yang menipis.
- Ekspor laporan stok dan riwayat mutasi ke PDF atau Excel.
- Kategori barang yang bisa diatur, serta pemindaian barcode.
- Pemisahan kode ke arsitektur berlapis (`models/`, `providers/`, `screens/`, `widgets/`) dan penambahan unit test untuk `InventoryProvider`.
