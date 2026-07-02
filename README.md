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

