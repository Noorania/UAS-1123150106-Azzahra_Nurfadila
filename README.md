# Jrb Jewelry × Dompet Kampus (Emoney)

Sistem e-commerce perhiasan (**Jrb Jewelry**) yang terintegrasi dengan dompet digital (**Dompet Kampus / Emoney**) lewat mekanisme **deeplink** untuk alur pembayaran antar-aplikasi. Terdiri dari 2 aplikasi Flutter dan 2 backend Go yang berjalan independen.

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

