# KEBAB DZAQY — POS + Pemesanan Online

Stack: **React (Vite)** di frontend, **FastAPI** di backend, **GitHub API**
sebagai database utama, **MongoDB** hanya untuk cache/sesi/log.

Repo ini punya 2 bagian yang di-deploy **terpisah**:

```
kebab-dzaqy/
├── frontend/     -> deploy ke Netlify (situs statis)
└── backend/      -> deploy ke Render/Railway/Fly (butuh server Python, bukan Netlify)
```

> ⚠️ **Kenapa dipisah?** Netlify hanya bisa menghosting file statis
> (HTML/CSS/JS) dan fungsi serverless pendek. FastAPI adalah server Python
> yang harus terus menyala (menerima webhook Pakasir kapan saja) — ini
> **tidak didukung Netlify**. Solusinya: frontend di Netlify, backend di
> platform yang mendukung Docker (Render, Railway, atau Fly.io — semua
> punya paket gratis).

---

## 0. Ganti kredensial dulu (WAJIB sebelum deploy sungguhan)

Token GitHub dan API key Pakasir yang dipakai selama development di chat ini
**sudah terekspos**. Sebelum deploy produksi:

1. Revoke token GitHub lama, buat token baru (scope `repo`) di
   GitHub → Settings → Developer settings → Personal access tokens.
2. Minta API key Pakasir baru dari dashboard Pakasir Anda.
3. Ganti `DEFAULT_OWNER_PASSWORD` dan `DEFAULT_KASIR_PASSWORD` dengan
   password baru yang kuat (nilai ini hanya dipakai **sekali** untuk
   membuat akun pertama kali — setelah itu tersimpan sebagai hash di
   `data/users.json` di repo GitHub Anda).

Nilai-nilai ini **tidak** ditulis di kode — semuanya diisi lewat
**Environment Variables** di dashboard hosting masing-masing (Netlify /
Render), sesuai permintaan Anda.

---

## 1. Siapkan repo data di GitHub

Backend butuh sebuah repo GitHub (boleh repo baru/kosong) sebagai "database".
Repo yang Anda sebutkan (`heimalingpangsit/GATAU`, branch `main`) bisa
dipakai langsung — backend akan otomatis membuat folder `data/` beserta
`menu.json`, `orders.json`, dst. saat pertama kali dipakai. Tidak perlu
membuat file JSON manual.

---

## 2. Deploy Backend (Render — contoh, Railway/Fly juga bisa)

1. Push seluruh folder ini ke repo GitHub Anda (repo kode, boleh beda dari
   repo data).
2. Buka [render.com](https://render.com) → **New → Blueprint** → pilih repo
   ini. Render otomatis membaca `render.yaml` di root dan mendeteksi
   `backend/Dockerfile`.
3. Di layar **Environment Variables**, isi:

   | Key | Isi |
   |---|---|
   | `GITHUB_TOKEN` | token baru Anda |
   | `GITHUB_OWNER` | `heimalingpangsit` |
   | `GITHUB_REPO` | `GATAU` |
   | `GITHUB_BRANCH` | `main` |
   | `PAKASIR_API_KEY` | API key baru Anda |
   | `PAKASIR_SLUG` | `pokaycore` |
   | `MONGO_URI` | connection string MongoDB Atlas (lihat langkah 2b) |
   | `JWT_SECRET_KEY` | boleh biarkan Render generate otomatis |
   | `DEFAULT_OWNER_USERNAME` / `DEFAULT_OWNER_PASSWORD` | akun owner pertama |
   | `DEFAULT_KASIR_USERNAME` / `DEFAULT_KASIR_PASSWORD` / `DEFAULT_KASIR_WHATSAPP` | akun kasir pertama |
   | `FRONTEND_ORIGIN` | URL Netlify Anda, isi setelah langkah 3 (mis. `https://kebabdzaqy.netlify.app`) |

4. Klik **Apply** / **Deploy**. Render akan build Docker image dan
   menjalankan server otomatis — **tidak ada perintah terminal yang perlu
   Anda jalankan**. Catat URL backend yang diberikan Render, contoh:
   `https://kebab-dzaqy-backend.onrender.com`.

### 2b. MongoDB (cache/session/log)
Buat cluster gratis di [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register),
buat database user, lalu salin **connection string** (`mongodb+srv://...`)
ke `MONGO_URI` pada langkah di atas. Ini bukan tempat data utama — kalau
kosong/expired pun aplikasi tetap jalan (cache dan cart otomatis fallback
ke GitHub / kosong), hanya sedikit lebih lambat dan cart tamu tidak
tersimpan.

*(Alternatif ke Render: Railway.app atau Fly.io — sama-sama bisa membaca
`backend/Dockerfile` langsung tanpa perlu `render.yaml`.)*

---

## 3. Deploy Frontend (Netlify)

1. Di Netlify: **Add new site → Import an existing project** → pilih repo
   ini. Netlify otomatis membaca `netlify.toml` di root (base dir
   `frontend`, build `npm run build`, publish `frontend/dist`).
2. Di **Site settings → Environment variables**, tambahkan:

   | Key | Isi |
   |---|---|
   | `VITE_API_URL` | URL backend dari langkah 2, mis. `https://kebab-dzaqy-backend.onrender.com` |

3. Deploy. Netlify build otomatis setiap kali Anda push ke repo — tidak
   ada perintah terminal yang perlu dijalankan dari HP Anda.
4. Setelah dapat URL Netlify (mis. `https://kebabdzaqy.netlify.app`),
   kembali ke Render → update `FRONTEND_ORIGIN` dengan URL ini persis
   (termasuk `https://`, tanpa trailing slash), lalu redeploy backend agar
   CORS mengizinkan frontend Anda.

---

## 4. Setel webhook Pakasir

Di dashboard project Pakasir Anda, set URL webhook pembayaran ke:
```
https://<url-backend-anda>/api/webhook/pakasir
```
Ini membuat status pesanan otomatis berubah jadi "Sudah Dibayar" saat
pembeli selesai scan QRIS, tanpa perlu refresh manual.

---

## 5. Login pertama kali

Buka `https://<url-frontend-anda>/login`, pakai username/password yang
Anda isi di `DEFAULT_OWNER_USERNAME` / `DEFAULT_OWNER_PASSWORD` (owner) atau
`DEFAULT_KASIR_USERNAME` / `DEFAULT_KASIR_PASSWORD` (kasir). Akun ini dibuat
otomatis di `data/users.json` pada repo GitHub Anda saat backend pertama
kali menerima request login.

---

## Struktur fitur

- **Buyer** (tanpa login): lihat menu & banner, keranjang, checkout QRIS,
  cek status pesanan pakai nomor order.
- **Owner** (`/owner`): ringkasan omzet & menu terlaris, kelola pesanan,
  CRUD menu, CRUD voucher, CRUD banner, export CSV/Excel/PDF.
- **Kasir** (`/kasir`): kelola status pesanan (bayar → proses → siap →
  selesai).

## Catatan arsitektur

- GitHub API dipakai sebagai "database" sesuai permintaan awal proyek —
  setiap CRUD = 1 commit ke repo data. Cocok untuk skala 1 toko, **bukan**
  untuk trafik tinggi (rate limit GitHub ~5000 request/jam per token).
- MongoDB hanya cache (TTL 30 detik), sesi keranjang tamu, dan log — kalau
  Mongo down, aplikasi tetap bisa jalan lebih lambat.
- Tidak ada data aplikasi yang disimpan di localStorage. Yang tersimpan di
  localStorage browser hanyalah token JWT (kredensial sesi) dan ID sesi
  keranjang tamu — bukan data menu/order itu sendiri.
