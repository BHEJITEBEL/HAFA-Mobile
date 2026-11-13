# HAFA Mobile — Heritage Artisan Fair-Trade Authenticator

Versi **aplikasi mobile (Flutter + Android)** bagi projek HAFA FYP anda, dengan backend **Node/Express + MongoDB dalam Docker**.

```
HAFA-Mobile/
├── docker-compose.yml     ← MongoDB + API (satu arahan)
├── hafa-backend/          ← backend asal + Dockerfile + endpoint baharu
└── hafa_mobile/           ← aplikasi Flutter (39 fail Dart)
    ├── lib/               ← kod aplikasi
    ├── tools/             ← skrip setup + AndroidManifest (kamera, NFC, internet)
    └── test/              ← ujian unit
```

---

## 1. Prasyarat (Windows)

| Perisian | Kegunaan |
|---|---|
| **Docker Desktop** (WSL2 hidup) | Jalankan MongoDB + API |
| **Flutter SDK** (stable) dalam `PATH` | Bina aplikasi |
| **Android Studio** + plugin *Flutter* & *Dart* | IDE + emulator |

Selepas pasang, buka terminal baharu dan jalankan `flutter doctor`. Semua item **Flutter** dan **Android toolchain** mesti ✓.
Jika ada masalah lesen Android: `flutter doctor --android-licenses`.

---

## 2. Langkah 1 — Jalankan backend (Docker)

Dalam folder `HAFA-Mobile`:

```powershell
docker compose up -d --build
```

Kali pertama, 4 produk contoh dimasukkan **secara automatik** ke MongoDB (`AUTO_SEED`). Semak:

```powershell
curl.exe http://localhost:8001/api/health
curl.exe http://localhost:8001/api/products
```

| Arahan | Fungsi |
|---|---|
| `docker compose logs -f api` | Lihat log API |
| `docker compose down` | Henti (data kekal) |
| `docker compose down -v` | Henti + **padam** data & gambar yang dimuat naik |

> MongoDB tempatan dalam Docker menggantikan MongoDB Atlas. Anda **tidak perlu** `.env` untuk Docker.

---

## 3. Langkah 2 — Sediakan projek Flutter

Folder `android/` dijana oleh Flutter (bukan ditulis tangan), jadi jalankan skrip setup **sekali sahaja**:

```powershell
cd hafa_mobile
powershell -ExecutionPolicy Bypass -File tools\setup.ps1
```

Skrip ini: `flutter create` (jana `android/`) → pasang `AndroidManifest.xml` (kebenaran kamera/NFC/internet) → `flutter pub get` → jana ikon aplikasi.

(Linux/macOS: `bash tools/setup.sh`)

---

## 4. Langkah 3 — Jalankan di Android Studio

1. **File ▸ Open** → pilih folder `hafa_mobile`. Tunggu *Gradle sync* & *pub get* siap.
2. **Device Manager** → *Create Device* (cth. Pixel 7, API 34) → mulakan emulator.
3. Pilih peranti di bar atas → tekan ▶ **Run** (`lib/main.dart`).

### Menyambung ke server

| Peranti | Alamat server |
|---|---|
| **Emulator Android** | `http://10.0.2.2:8001` (lalai — tiada tetapan diperlukan) |
| **Telefon fizikal** (WiFi sama dengan PC) | `http://<IP-PC-anda>:8001` |

Untuk telefon fizikal:
1. Dapatkan IP PC: `ipconfig` → *IPv4 Address* (cth. `192.168.1.10`).
2. Benarkan port melalui firewall (PowerShell **Administrator**):
   ```powershell
   New-NetFirewallRule -DisplayName "HAFA API" -Direction Inbound -Protocol TCP -LocalPort 8001 -Action Allow
   ```
3. Dalam aplikasi: **Profile ▸ Server Settings** → masukkan `http://192.168.1.10:8001` → **Test** → **Save**.
   (Atau bina dengan `--dart-define=API_BASE_URL=http://192.168.1.10:8001`.)

---

## 5. Cara menguji ciri utama

- **Tanpa kamera/NFC**: tab **Verify** ▸ *Manual Lookup* — taip `HAFA-2024-TRG-001`, atau tekan chip contoh.
- **Imbas QR (emulator)**: buka **Heritage Passport** produk dalam telefon/PC, atau jana QR dengan teks `hafa://verify/HAFA-2024-TRG-001`, kemudian tunjuk pada kamera. Emulator: *Extended controls ▸ Camera* → pilih *Webcam* atau *Virtual scene*. Telefon sebenar paling mudah.
- **Kod tak berdaftar**: imbas QR rawak yang mengandungi teks lain → skrin merah **NOT VERIFIED** (bukan "palsu" jika rangkaian bermasalah; itu dipaparkan sebagai ralat sambungan).
- **NFC** (telefon sebenar sahaja, emulator tiada NFC): log masuk sebagai **Artisan** → *Heritage Passport* ▸ **Write to NFC Tag** (tag NTAG213/215 kosong) → kemudian **Verify ▸ Tap NFC Tag**.
- **Daftar produk**: peranan Artisan → *Register* → 6 langkah → produk muncul dengan status *Pending Verification*.

---

## 6. Bina APK

**Android Studio**: *Build ▸ Flutter ▸ Build APK*, atau terminal:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10:8001
# hasil: build\app\outputs\flutter-apk\app-release.apk
```

*(Pilihan, tidak diuji)* bina APK tanpa memasang Flutter, melalui Docker:

```powershell
docker run --rm -v "${PWD}:/app" -w /app ghcr.io/cirruslabs/flutter:stable bash -lc "bash tools/setup.sh && flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10:8001"
```

---

## 7. Penyelesaian masalah

| Masalah | Penyelesaian |
|---|---|
| *Cannot reach the HAFA server* | `docker compose ps` — pastikan `hafa-api` *running*. Emulator guna `10.0.2.2`, **bukan** `localhost`. Telefon: semak IP + firewall + WiFi sama. |
| `flutter pub get` gagal / konflik versi | Salin mesej ralat penuh dan hantar kepada saya; versi pakej dalam `pubspec.yaml` ditetapkan secara konservatif. |
| Ralat Gradle berkaitan *namespace* / *Kotlin* pada plugin | Naikkan versi plugin berkenaan dalam `pubspec.yaml` lalu `flutter pub upgrade <nama>`. |
| Kamera hitam | *Settings ▸ Apps ▸ HAFA ▸ Permissions ▸ Camera* → Allow. |
| `Write to NFC Tag` gagal | Tag mesti NDEF & tidak dikunci; dekatkan bahagian belakang atas telefon. |
| Gambar produk tidak keluar | Pastikan *Server URL* betul — gambar dimuat dari server yang sama. |
| `docker compose up` gagal pada `npm ci` | Pastikan Docker boleh akses internet; `docker compose build --no-cache api`. |

---

## 8. Had & perkara yang perlu anda tahu

1. **Log masuk/daftar masih simulasi** (seperti versi web asal) — tiada akaun di server. Endpoint tulis (`POST`) **belum dilindungi** autentikasi. Untuk produksi: tambah JWT + peranan.
2. **Blockchain & IPFS masih data simulasi** (hash/CID dijana secara rawak oleh server), sama seperti data contoh asal.
3. Halaman **Admin Analytics** & **Cybersecurity** menggunakan angka contoh statik (seperti asal; di web asal carta kategori berubah rawak setiap render — kini tetap).
4. Butang **Review** admin hanya memaparkan butiran; kelulusan sebenar memerlukan API admin berautentikasi.
5. Produk tidak dipautkan kepada pengguna — dashboard artisan memaparkan semua produk.
6. `usesCleartextTraffic=true` dalam manifest membolehkan `http://` ke Docker semasa pembangunan. **Gunakan HTTPS & buang tetapan ini** untuk produksi.
7. Kod asal mengandungi folder tersasar bernama `{models,routes,seed}` (kesan `mkdir` di Windows) — tidak disertakan di sini.

### Pepijat dalam kod asal yang dibetulkan
- `HomeDashboard`: `case 'ADMINISTRATOR'` ditulis dua kali (yang kedua tidak pernah dicapai).
- `ProductDetailPage` memaut ke `/verify/:id` yang **tiada route** (jatuh ke redirect) — kini ke `/qr-verify/:id`.
- Keputusan pengesahan kini jujur: produk *Pending* tidak lagi dilabel "Heritage Authentic".
