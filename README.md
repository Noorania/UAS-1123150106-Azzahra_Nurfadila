# Jrb Jewelry × Dompetku

Sistem e-commerce perhiasan (**Jrb Jewelry**) yang terintegrasi dengan dompet digital (**Dompetku**) lewat mekanisme **deeplink** untuk alur pembayaran antar-aplikasi. Terdiri dari 2 aplikasi Flutter dan 2 backend Go yang berjalan independen.

## Tentang Project

E-commerce yang mendelegasikan proses pembayaran ke aplikasi dompet digital terpisah — mirip pola integrasi Gopay/OVO/Dana ke merchant app di dunia nyata. Kedua sistem dibangun sebagai dua aplikasi dan dua backend yang sepenuhnya terpisah, dihubungkan lewat deeplink dan callback URL.

## Tujuan Project

- Implementasi clean architecture pada Flutter (feature-based di Jrb Jewelry, layer-based di Dompetku)
- Integrasi antar-aplikasi via deeplink di Android (intent-filter, package visibility, callback URL)
- Backend REST API terpisah menggunakan Go/Gin dengan autentikasi Firebase
- Keamanan berlapis pada transaksi: PIN + verifikasi TOTP (2FA)

## Fitur

**Jrb Jewelry**
- Autentikasi (Email/Password & Google Sign-In)
- Katalog produk, keranjang belanja, checkout
- Pembayaran: Virtual Account, Gopay, Dompetku
- Tracking & riwayat pesanan
- Redirect otomatis ke halaman sukses setelah pembayaran

**Dompetku**
- Cek saldo, riwayat transaksi, top up, transfer
- Terima & proses pembayaran merchant via deeplink
- Keamanan transaksi: PIN + verifikasi TOTP (2FA)

## Screenshot

<table>
  <tr>
     <td><img src="https://github.com/user-attachments/assets/5da68b95-863a-40ce-a092-31d8869fb21f" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/4c019c04-623c-4f00-b445-b08f5f3f0846" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/b8642f68-852e-4d04-ac16-8cb38f809e1e" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/bc1a116f-ed92-42b6-bbab-ed0456d58dee" width="200" /></td>
  </tr>
  <tr>
      <td><img src="https://github.com/user-attachments/assets/1d442da0-b2b7-4b43-92b8-a5ce5b5c2c5b" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/0dd4c5a0-676a-425a-9f35-948d43e36c32" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/b2c606c0-e03c-48dd-9eb3-eeafd400d727" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/5fc3ac42-62c4-4c5d-86b1-4ae4d54cc167" width="200" /></td>
  </tr>
</table>

---

## Arsitektur Sistem

```
┌─────────────────────┐        deeplink         ┌──────────────────────┐
│    Jrb Jewelry       │ ───────────────────────▶ │      Dompetku          │
│   (Flutter + Go)      │  emoneydompetku://pay    │    (Flutter + Go)      │
│                     │ ◀─────────────────────── │                      │
└──────────┬───────────┘   jrbjewelry://callback   └───────────┬────────────┘
       │                              │
       ▼                              ▼
┌─────────────────────┐        ┌──────────────────────┐
│ gin-firebase-backend  │        │    be-emoney          │
│    (Go + MySQL)       │        │  (Go + MySQL + Redis)   │
└─────────────────────┘        └──────────────────────┘
```

| Komponen | Tech Stack | Fungsi |
|---|---|---|
| **jrb_jewelry** | Flutter, Provider | App e-commerce perhiasan (cart, checkout, order) |
| **gin-firebase-backend** | Go, Gin, MySQL, Firebase Admin SDK | API untuk jrb_jewelry |
| **emoney (Dompetku)** | Flutter, BLoC, GoRouter, GetIt | App dompet digital |
| **be-emoney** | Go, Gin, MySQL, Redis, Firebase Admin SDK | API untuk Dompetku |

---

## Struktur Repository

```
├── jrb_jewelry/            # Flutter app — e-commerce
├── gin-firebase-backend/    # Go backend — jrb_jewelry
├── emoney/                # Flutter app — Dompetku
└── be-emoney/              # Go backend — Dompetku
```

---

## Prasyarat

- [Flutter SDK](https://flutter.dev) (channel stable)
- [Go](https://go.dev) 1.21+
- [MySQL](https://www.mysql.com) 8.0+
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (untuk Redis)
- Android SDK / emulator, atau device fisik dengan USB debugging aktif
- Akun [Firebase](https://console.firebase.google.com) (2 project terpisah)

---

## Setup — Firebase

Dibutuhkan **2 project Firebase terpisah** — satu untuk Jrb Jewelry, satu untuk Dompetku.

### 1. Project Firebase — Jrb Jewelry

1. Buat project baru di [Firebase Console](https://console.firebase.google.com)
2. **Authentication → Sign-in method** → aktifkan **Email/Password** dan **Google**
3. **Project Settings → Add app → Android** — `applicationId` sesuai `jrb_jewelry/android/app/build.gradle.kts`
4. Download `google-services.json`, taruh di `jrb_jewelry/android/app/`
5. Generate SHA-1 fingerprint (wajib untuk Google Sign-In):
   ```powershell
   cd jrb_jewelry/android
   ./gradlew signingReport
   ```
6. Tambahkan SHA-1 di **Project Settings → Your apps → Add fingerprint**

### 2. Project Firebase — Dompetku

Ulangi langkah yang sama dengan project Firebase **baru/terpisah**, `applicationId` sesuai `emoney/android/app/build.gradle.kts`.

### 3. Service Account (untuk backend)

Kedua backend memakai Firebase Admin SDK untuk verifikasi token dari client:
1. **Project Settings → Service Accounts → Generate new private key**
2. Simpan file JSON ke folder `config/` masing-masing backend (tambahkan ke `.gitignore`)

---

## Setup — Redis (Docker)

Redis dipakai oleh **be-emoney** (Dompetku).

```powershell
docker run --name redis-emoney -p 6379:6379 -d redis
```

Verifikasi container berjalan:
```powershell
docker ps
```

---

## Menjalankan Backend

### gin-firebase-backend (Jrb Jewelry)

```powershell
cd gin-firebase-backend
go mod tidy
go run main.go
```

Berjalan di **port `8081`**.

```
gin-firebase-backend/
├── config/     # koneksi database & Firebase Admin SDK
├── handlers/    # HTTP handler
├── middleware/   # auth middleware
├── models/     # struct data
├── repositories/  # akses database
├── routes/     # deklarasi endpoint
├── seed/      # data awal
└── services/    # business logic
```

### be-emoney (Dompetku)

```powershell
cd be-emoney
go mod tidy
go run main.go
```

Pastikan Redis dan MySQL sudah aktif sebelum menjalankan.

```
be-emoney/
├── config/     # koneksi database, Redis, Firebase Admin SDK
├── database/    # migration / schema
├── handlers/    # HTTP handler
├── middleware/   # auth middleware
├── models/     # struct data
├── postman/     # collection Postman
├── routes/     # deklarasi endpoint
└── services/    # business logic
```

---

## Menjalankan Aplikasi Flutter

### jrb_jewelry

```powershell
cd jrb_jewelry
flutter pub get
flutter run
```

Sesuaikan base URL API di `lib/core/constants/`:
- **Emulator** → `http://10.0.2.2:8081`
- **Device fisik** → `http://<IP-WiFi-lokal-komputer>:8081`

### emoney (Dompetku)

```powershell
cd emoney
flutter pub get
flutter run
```

> **Catatan:** Kedua app perlu ter-install di device/emulator **yang sama** agar deeplink antar-app berfungsi.

---

## Clean Architecture

### jrb_jewelry — Feature-based

```
lib/
├── core/       (constants, guards, providers, routes, services, theme)
└── features/
    ├── auth/     (data / domain / presentation)
    ├── cart/     (data / domain / presentation)
    ├── dashboard/  (data / domain / presentation)
    └── order/    (data / domain / presentation)
```

### emoney (Dompetku) — Layer-based

```
lib/
├── core/       (constants, error, network, router, services, theme, utils)
├── data/       (datasources, models, repositories)
├── domain/      (entities, repositories, usecases)
├── injection/    (dependency injection — GetIt)
└── presentation/  (blocs, pages, widgets)
```

### Backend Go — Layered Architecture

```
Route → Handler → Service → Repository → Database
```

---

## Flow Deeplink Pembayaran

```
1. User checkout di Jrb Jewelry, pilih bayar via Dompetku
   → generate: emoneydompetku://pay?merchant_id=...&reference=...&callback=jrbjewelry://payment-callback

2. url_launcher membuka app Dompetku
   → butuh <queries> & intent-filter terdaftar di kedua app

3. DeeplinkService (Dompetku) menangkap URI via app_links
   → cold-start: disimpan pending, diproses setelah auth check
   → in-app: langsung navigasi ke halaman pembayaran

4. User konfirmasi → masukkan PIN → verifikasi TOTP
   → kode TOTP dikirim sebagai otpCode ke endpoint transfer

5. Setelah sukses: kirim callback jrbjewelry://payment-callback?status=success&...
   → membuka kembali app Jrb Jewelry

6. Jrb Jewelry menangkap callback → navigasi otomatis ke halaman Order Success
```

| Tahap | File |
|---|---|
| Generate URL | `jrb_jewelry/lib/core/services/emoney_service.dart` |
| Intent-filter | `*/android/app/src/main/AndroidManifest.xml` |
| Launch deeplink | `jrb_jewelry/lib/.../payment_pending_page.dart` |
| Tangkap deeplink masuk | `emoney/lib/core/services/deeplink_service.dart` |
| Halaman konfirmasi | `emoney/lib/.../payment_deeplink_page.dart` |
| PIN & TOTP | `emoney/lib/.../pin_page.dart`, `twofa_totp_page.dart` |
| Kirim callback sukses | `emoney/lib/core/services/deeplink_callback_service.dart` |
| Tangkap callback balik | `jrb_jewelry/lib/core/services/emoney_service.dart` |

---
