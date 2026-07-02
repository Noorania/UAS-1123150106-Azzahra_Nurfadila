# Jrb Jewelry × DompetQU (Emoney)

Sistem e-commerce perhiasan (**Jrb Jewelry**) yang terintegrasi dengan dompet digital (**DompeQU / Emoney**) lewat mekanisme **deeplink** untuk alur pembayaran antar-aplikasi. Terdiri dari 2 aplikasi Flutter dan 2 backend Go yang berjalan independen.

## Arsitektur Sistem

| Komponen | Tech Stack | Fungsi |
|---|---|---|
| **jrb_jewelry** | Flutter, Provider | App e-commerce perhiasan (cart, checkout, order) |
| **gin-firebase-backend** | Go, Gin, MySQL, Firebase Admin SDK | API untuk jrb_jewelry (produk, cart, order, auth) |
| **emoney** | Flutter, BLoC, GoRouter, GetIt | App dompet digital (saldo, transfer, topup, 2FA) |
| **be-emoney** | Go, Gin, MySQL, Redis, Firebase Admin SDK | API untuk emoney (akun, transaksi, OTP/TOTP) |

Kedua sistem terhubung lewat **deeplink** — user checkout di Jrb Jewelry, diarahkan ke Emoney untuk membayar, lalu otomatis kembali ke Jrb Jewelry setelah pembayaran selesai.

## Struktur Repository

```
├── jrb_jewelry/            # Flutter app — e-commerce
├── gin-firebase-backend/    # Go backend — jrb_jewelry
├── emoney/                # Flutter app — dompet digital
└── be-emoney/              # Go backend — emoney
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

Sistem ini membutuhkan **2 project Firebase terpisah** — satu untuk Jrb Jewelry, satu untuk Emoney — karena keduanya punya basis pengguna dan autentikasi independen.

### 1. Project Firebase — Jrb Jewelry

1. Buat project baru di [Firebase Console](https://console.firebase.google.com)
2. **Authentication → Sign-in method** → aktifkan **Email/Password** dan **Google**
3. **Project Settings → Add app → Android**
   - `applicationId` harus sama persis dengan yang ada di `jrb_jewelry/android/app/build.gradle.kts`
4. Download `google-services.json`, taruh di `jrb_jewelry/android/app/`
5. Generate SHA-1 fingerprint (wajib untuk Google Sign-In):
   ```powershell
   cd jrb_jewelry/android
   ./gradlew signingReport
   ```
6. Tambahkan SHA-1 tersebut di **Project Settings → Your apps → Add fingerprint**

### 2. Project Firebase — Emoney

Ulangi langkah yang sama dengan project Firebase **baru/terpisah**:

1. Buat project baru, misal `dompet-kampus`
2. Aktifkan provider auth yang dibutuhkan
3. Add Android app dengan `applicationId` sesuai `emoney/android/app/build.gradle.kts`
4. Download `google-services.json`, taruh di `emoney/android/app/`
5. Generate & tambahkan SHA-1 untuk project ini juga

### 3. Service Account (untuk backend)

Kedua backend (`gin-firebase-backend` dan `be-emoney`) memakai Firebase Admin SDK untuk verifikasi token dari client:

1. **Project Settings → Service Accounts → Generate new private key**
2. Simpan file JSON hasil download ke folder `config/` masing-masing backend (jangan commit ke git — tambahkan ke `.gitignore`)
3. Sesuaikan path file tersebut di kode config masing-masing backend

---

## Setup — Redis (Docker)

Redis dipakai oleh **be-emoney** (misalnya untuk penyimpanan OTP/TOTP sementara).

```powershell
docker run --name redis-emoney -p 6379:6379 -d redis
```

Verifikasi container berjalan:
```powershell
docker ps
```

Pastikan konfigurasi koneksi Redis di `be-emoney/config/` mengarah ke `localhost:6379` (atau sesuaikan bila memakai `docker-compose.yml`).

---

## Setup — Redis (Docker)

Redis dipakai oleh **be-emoney** (misalnya untuk penyimpanan OTP/TOTP sementara).

```powershell
docker run --name redis-emoney -p 6379:6379 -d redis
```

Verifikasi container berjalan:
```powershell
docker ps
```

Pastikan konfigurasi koneksi Redis di `be-emoney/config/` mengarah ke `localhost:6379` (atau sesuaikan bila memakai `docker-compose.yml`).

---
```
```
## untuk file JrB jewelry 
https://github.com/Noorania/uts_JrB_Jewelry_1123150106
```
## Menjalankan Backend

### gin-firebase-backend (Jrb Jewelry)

```powershell
cd gin-firebase-backend
go mod tidy
go run main.go
```

Berjalan di **port `8081`**. Pastikan MySQL sudah aktif dan konfigurasi koneksi database di `config/` sudah sesuai.

Struktur folder:
```
gin-firebase-backend/
├── config/         # koneksi database & Firebase Admin SDK
├── handlers/        # HTTP handler (menerima request)
├── middleware/       # auth middleware, dsb
├── models/          # struct data (Order, Product, CartItem, ...)
├── repositories/      # akses database (query murni)
├── routes/          # deklarasi endpoint
├── seed/           # data awal / dummy
└── services/         # business logic
```

### be-emoney (Emoney)

```powershell
cd be-emoney
go mod tidy
go run main.go
```

Pastikan Redis dan MySQL sudah aktif sebelum menjalankan.

Struktur folder:
```
be-emoney/
├── config/     # koneksi database, Redis, Firebase Admin SDK
├── database/    # migration / schema
├── handlers/    # HTTP handler
├── middleware/   # auth middleware, dsb
├── models/     # struct data (Account, Transaction, ...)
├── postman/     # collection Postman untuk testing manual
├── routes/     # deklarasi endpoint
└── services/    # business logic (topup, transfer, OTP, TOTP)
```
---

## Setup — Redis (Docker)

Redis dipakai oleh **be-emoney** (misalnya untuk penyimpanan OTP/TOTP sementara).

```powershell
docker run --name redis-emoney -p 6379:6379 -d redis
```

Verifikasi container berjalan:
```powershell
docker ps
```

Pastikan konfigurasi koneksi Redis di `be-emoney/config/` mengarah ke `localhost:6379` (atau sesuaikan bila memakai `docker-compose.yml`).

---

## Menjalankan Backend

### gin-firebase-backend (Jrb Jewelry)

```powershell
cd gin-firebase-backend
go mod tidy
go run main.go
```

Berjalan di **port `8081`**. Pastikan MySQL sudah aktif dan konfigurasi koneksi database di `config/` sudah sesuai.

Struktur folder:
```
gin-firebase-backend/
├── config/         # koneksi database & Firebase Admin SDK
├── handlers/        # HTTP handler (menerima request)
├── middleware/       # auth middleware, dsb
├── models/          # struct data (Order, Product, CartItem, ...)
├── repositories/      # akses database (query murni)
├── routes/          # deklarasi endpoint
├── seed/           # data awal / dummy
└── services/         # business logic
```

### be-emoney (Emoney)

```powershell
cd be-emoney
go mod tidy
go run main.go
```

Pastikan Redis dan MySQL sudah aktif sebelum menjalankan.

Struktur folder:
```
be-emoney/
├── config/     # koneksi database, Redis, Firebase Admin SDK
├── database/    # migration / schema
├── handlers/    # HTTP handler
├── middleware/   # auth middleware, dsb
├── models/     # struct data (Account, Transaction, ...)
├── postman/     # collection Postman untuk testing manual
├── routes/     # deklarasi endpoint
└── services/    # business logic (topup, transfer, OTP, TOTP)
```

---

## Menjalankan Aplikasi Flutter

### jrb_jewelry

```powershell
cd jrb_jewelry
flutter pub get
flutter run
```

Sebelum run, sesuaikan base URL API di `lib/core/constants/` dengan alamat backend:
- **Emulator Android Studio** → `http://10.0.2.2:8081`
- **Device fisik** → `http://<IP-WiFi-lokal-komputer>:8081` (pastikan device & komputer satu jaringan WiFi)

### emoney

```powershell
cd emoney
flutter pub get
flutter run
```

Sesuaikan base URL API dengan cara yang sama, mengarah ke backend `be-emoney`.

> **Catatan:** Kedua app perlu ter-install di device/emulator **yang sama** agar deeplink antar-app dapat berfungsi saat testing.

---

## Clean Architecture

### jrb_jewelry — Feature-based

```
lib/
├── core/
│   ├── constants/
│   ├── guards/       # route guard
│   ├── providers/     # state management global
│   ├── routes/       # app_router.dart
│   ├── services/      # EmoneyService (deeplink), NotificationService
│   └── theme/
└── features/
    ├── auth/         (data / domain / presentation)
    ├── cart/         (data / domain / presentation)
    ├── dashboard/      (data / domain / presentation)
    └── order/        (data / domain / presentation)
```

Setiap fitur mengelompokkan layer `data`, `domain`, `presentation` di dalam foldernya sendiri — memudahkan navigasi saat bekerja pada satu fitur tertentu.

### emoney — Layer-based

```
lib/
├── core/           # constants, error, network, router, services, theme, utils
├── data/           # datasources, models, repositories (implementasi)
├── domain/          # entities, repositories (interface), usecases
├── injection/        # dependency injection (GetIt)
└── presentation/       # blocs, pages, widgets
```

Mengikuti clean architecture klasik: `domain` sebagai inti bisnis yang tidak bergantung pada detail teknis, `data` sebagai implementasi konkret (API, storage), `presentation` sebagai UI yang mengonsumsi `usecase` melalui BLoC.

### Backend Go — Layered Architecture

Kedua backend Go mengikuti pola serupa:

```
Route → Handler → Service → Repository → Database
```

- **Handler** — menerima HTTP request, memanggil service
- **Service** — business logic (validasi, kalkulasi, orkestrasi)
- **Repository** — akses database murni, tanpa logic bisnis

---

## Flow Deeplink Pembayaran

```
1. User checkout di Jrb Jewelry, pilih metode bayar Emoney
   → EmoneyService.buildDeeplinkUrl() generate:
     emoneydompetku://pay?merchant_id=...&amount=...&reference=...&callback=jrbjewelry://payment-callback

2. url_launcher (LaunchMode.externalApplication) membuka app Emoney
   → Android package visibility (<queries>) & intent-filter (AndroidManifest.xml)
     harus terdaftar di kedua app agar resolusi intent berhasil

3. DeeplinkService (Emoney) menangkap URI via app_links
   → Cold-start: URI disimpan sebagai pending, diproses setelah auth check selesai
   → In-app: langsung router.go('/pay')

4. PaymentDeeplinkPage menampilkan ringkasan pembayaran
   → User masukkan PIN → lanjut verifikasi TOTP
   → Kode TOTP dikirim sebagai otpCode ke endpoint transfer backend

5. Setelah transfer sukses:
   → DeeplinkCallbackService.notifySuccess() generate:
     jrbjewelry://payment-callback?status=success&reference=...&transaction_id=...
   → launchUrl membuka kembali app Jrb Jewelry

6. EmoneyService (Jrb Jewelry) menangkap callback via app_links
   → Broadcast lewat stream ke PaymentPendingPage
   → Navigasi otomatis ke halaman Order Success

```
## SCREENSHOT

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/4c019c04-623c-4f00-b445-b08f5f3f0846" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/b8642f68-852e-4d04-ac16-8cb38f809e1e" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/bc1a116f-ed92-42b6-bbab-ed0456d58dee" width="200" /></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/b2c606c0-e03c-48dd-9eb3-eeafd400d727" width="200" /></td>
    <td><img src="https://github.com/user-attachments/assets/5fc3ac42-62c4-4c5d-86b1-4ae4d54cc167" width="200" /></td>
      <td><img src="https://github.com/user-attachments/assets/0dd4c5a0-676a-425a-9f35-948d43e36c32" width="200" /></td>
  </tr>
</table>
```
## Developer
Az-zahra Nurfadila Puspita Ayu
Link Youtube : 
