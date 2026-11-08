# Panduan Build Aplikasi

Halo! Halaman ini adalah panduan lengkap untuk melakukan _build_ aplikasi di lingkungan lokal. Fokus utama kita adalah target **Android**, namun kita juga akan membahas target sekunder seperti **Linux desktop** dan pembuatan _installer_ untuk **Windows**.

_(Catatan: Konfigurasi build untuk iOS sebenarnya ada, namun tidak dicakup dalam dokumen ini karena bukan workflow utama pengembangan lokal)._

## Persiapan Awal (Prerequisites)

Sebelum mulai menjalankan perintah di terminal, pastikan beberapa hal berikut sudah siap di komputer kamu:

- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** sudah terinstal dengan versi Dart SDK yang memenuhi batasan di file `pubspec.yaml`.
- **Android Studio** atau **Android SDK** sudah terpasang dan terkonfigurasi.
- **Perangkat fisik (HP)** atau **Emulator** siap digunakan untuk menjalankan aplikasi.

Buka terminal di _repository root_ (folder utama proyek), lalu verifikasi kesiapan sistem kamu dengan menjalankan:

```bash
flutter doctor
```

## Android: Build & Run

Ini adalah alur kerja harian yang paling sering kamu gunakan untuk pengembangan lokal:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Hal Penting yang Perlu Kamu Perhatikan:

- Perintah `flutter run` akan otomatis mendeteksi perangkat fisik yang terhubung atau emulator yang aktif. Jika ada lebih dari satu perangkat, Flutter akan meminta kamu memilih salah satu.
- `build_runner` berfungsi untuk mendistribusikan _code generation_, termasuk database Drift.
- Pastikan untuk **menjalankan ulang `build_runner**` setiap kali kamu mengubah skema database (_schema changes_) atau pembaruan kode yang membutuhkan _code generation_.

## Linux Desktop

Target Linux desktop sifatnya sekunder. Saat ini fitur sistem seperti OS _notifications_, _keep-screen-on_, dan _Focus monitoring_ belum didukung. Notifikasi dalam aplikasi baru mengandalkan _Alert tone_.

### 1. Instalasi Dependensi Audio

Untuk pengguna Debian/Ubuntu, instal dependensi audio berikut agar _alert tone_ dapat berjalan:

```bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

### 2. Build dan Jalankan

Gunakan perintah berikut untuk melakukan _build_ dan menjalankan aplikasi:

```bash
flutter build linux --debug
flutter run -d linux
```

File database akan tersimpan di direktori: `~/.local/share/com.dpzstudio.pomodoro_app/pomodoro.sqlite`

## Windows Installer

Untuk membuat _installer_ di platform Windows, ada dua cara yang bisa kamu pilih:

1. **GitHub Actions (Otomatis)**: Menggunakan workflow [Build Windows Release](https://www.google.com/search?q=../.github/workflows/windows-release.yml).
2. **Build Lokal**: Menjalankan proses _packaging_ sendiri di komputer lokal untuk pengujian.

### Cara 1: Rilis Otomatis via GitHub Actions

Workflow ini akan menghasilkan file _installer_ (_unsigned_) khusus untuk _current-user_ yang kompatibel dengan Windows 10 atau versi yang lebih baru.

Kamu **tidak perlu menginstal Visual C++ runtime** terlebih dahulu di komputer target, karena DLL MSVC runtime versi rilis sudah dibundel langsung bersama file eksekusi (_app-local_).

#### Langkah-langkah mengambil paket rilis:

1. Jalankan workflow dari tab **GitHub Actions**.
2. Unduh artefak bernama `windows-release`.
3. Ekstrak file ZIP yang berhasil diunduh.
4. Jalankan file `pomodoro_<version>_setup.exe`.

> **Catatan:** File ZIP berisi file _installer_ (bukan folder _portable app_). Masa berlaku artefak di GitHub Actions adalah **7 hari**.

### Cara 2: Build Windows secara Lokal

Pastikan kamu sudah menginstal [Prasyarat Flutter Windows](https://docs.flutter.dev/platform-integration/windows/setup) dan [Inno Setup versi 6.3 atau yang lebih baru (seri 6.x)](https://jrsoftware.org/isdl.php).

Jalankan skrip berikut melalui **PowerShell** dari _repository root_:

```powershell
flutter pub get
dart run build_runner build
flutter analyze --fatal-infos --fatal-warnings
flutter build windows --release
# Proses bundling MSVC CRT app-local: mengambil versi Redist\MSVC\v*\x64\Microsoft.VC*.CRT terbaru
# (melewati folder v145 kosong pada runner VS 2026), atau VC\Tools\MSVC\*\bin\Hostx64\x64.
./windows/ci/bundle_msvc_runtime.ps1
& "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" windows/installer/release.iss
if ($LASTEXITCODE -ne 0) { throw "Installer compilation failed" }
```

Hasil akhir _installer_ berada di direktori: `build/windows/installer/pomodoro_<version>_setup.exe`

#### Penentuan Versi (Version Format):

Nomor versi diambil dari _four-part Windows file version_. Sebagai contoh, versi `1.2.0+3` di file `pubspec.yaml` akan dikonversi menjadi `1.2.0.3`, sehingga menghasilkan installer bernama `pomodoro_1.2.0.3_setup.exe`.

Skrip installer ([release.iss](https://www.google.com/search?q=../windows/installer/release.iss)) akan membungkus seluruh _bundle_ Release x64, termasuk aset Flutter, _plugin libraries_, dan MSVC runtime _app-local_.

### Perilaku Installer & Hal-hal Khusus

- **Lokasi Instalasi**: Secara _default_ terinstal ke `%LOCALAPPDATA%\Programs\Pomodoro` tanpa memerlukan hak akses administrator (_admin access_).
- **Shortcut & Registrasi**: Otomatis menambahkan _shortcut_ di Start Menu, opsi _shortcut_ di Desktop, serta mendaftarkan nama **Pomodoro** di daftar _Installed Apps_ Windows.
- **Pembaruan Aplikasi**: Menjalankan _installer_ baru akan memperbarui instalasi yang sudah ada.
- **Tips Upgrade**: Tutup aplikasi terlebih dahulu sebelum _upgrade_. Folder _portable_ lama tidak akan terhapus secara otomatis.
- **Identitas & Data**: Aplikasi hasil instalasi berbagi identitas dan data tersimpan (_saved data_) yang sama dengan versi _portable_ jika dijalankan oleh pengguna Windows yang sama.
- **Proses Uninstall**: Menghapus file aplikasi dan _shortcut_, namun **tetap mempertahankan data pengguna** yang tersimpan.
- **Pengujian**: Hindari menjalankan versi terinstal dan versi _portable_ secara bersamaan.
- **Build Debug**: Versi _debug_ tidak dibundel ke dalam _installer_. Perintah `flutter build windows --debug` tetap bisa digunakan untuk pengembangan lokal, tetapi butuh Visual C++ debug runtime dari Visual Studio. Versi ini tidak disediakan oleh Visual C++ Redistributable biasa dan tidak dilesensikan oleh Microsoft untuk didistribusikan ulang.

### Pengujian Installer (Smoke Check)

Kamu bisa melakukan uji coba pada komputer Windows bersih (tanpa komponen Visual C++):

1. **Uji Instalasi**: Jalankan _installer_ sebagai pengguna standar (_standard user_). Pastikan tidak muncul prompt _administrator_ dan lokasi instalasi sesuai _default_.
2. **Uji Jalankan**: Biarkan opsi _shortcut_ desktop tidak dicentang. Buka **Pomodoro** via Start Menu, lalu pastikan _timer_ dan data tersimpan dapat dimuat dengan baik.
3. **Uji Re-install**: Tutup aplikasi, jalankan kembali _installer_ dengan mencentang _shortcut_ desktop. Pastikan aplikasi tetap terdaftar tunggal di Windows dan data lama tidak hilang.
4. **Uji Uninstall**: Hapus aplikasi melalui _Windows Settings_. Pastikan seluruh file instalasi beserta kedua _shortcut_ terhapus.
5. **Uji Verifikasi Data**: Instal kembali aplikasi dan pastikan data tersimpan sebelumnya masih ada dan utuh.

## Verifikasi Akhir (Sanity Check)

Setelah berhasil melakukan _build_ atau menjalankan aplikasi, sangat disarankan untuk melakukan pengujian kualitas kode berikut sebelum membuat _pull request_ / _commit_:

```bash
flutter analyze
flutter test
```

## Opsional: Tag Debug Berdurasi Pendek

Untuk keperluan _manual QA_, kamu bisa mengaktifkan _Debug Tag_ khusus dengan durasi 5 detik. Perlu diingat, fitur ini hanya untuk keperluan pengujian dan bukan untuk penggunaan harian normal.

```bash
flutter run --dart-define=DEBUG_SHORT_TAG=true
```
