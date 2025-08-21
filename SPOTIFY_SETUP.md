# Panduan Konfigurasi Spotify Developer App

## Setting di Spotify Developer Dashboard

Masuk ke [Spotify Developer Dashboard](https://developer.spotify.com/dashboard) dan konfigurasi aplikasi Anda:

### 1. App Settings
- **App name**: MUSCTA
- **App description**: Music Social Media App - Connect your Spotify music taste
- **Website**: (opsional)

### 2. Redirect URIs
Tambahkan redirect URI berikut di bagian "Redirect URIs":
```
muscta://callback
http://localhost:8888/callback
```

### 3. Bundle IDs / Package Names
Di bagian "Bundle IDs" (untuk iOS) atau "Android packages" (untuk Android):
- **Android**: `com.example.muscta_app`
- **iOS**: `com.example.muscta`

### 4. API Scopes yang Diperlukan
Pastikan aplikasi Anda meminta izin untuk scope berikut:
- `user-read-email`
- `user-read-private`
- `user-top-read`
- `user-read-recently-played`
- `playlist-read-private`
- `playlist-read-collaborative`

### 5. App Credentials
- **Client ID**: `b5a13e69c34a4e259f2b89b2b9532` (sudah dikonfigurasi)
- **Client Secret**: `fa522b90ae0a4abb8f4112c132de92d1` (sudah dikonfigurasi)

### 6. Mode Development
- Pastikan aplikasi dalam mode "Development" untuk testing
- Tambahkan email tester di bagian "Users and Access"

## Yang Sudah Dikonfigurasi di App:

✅ SpotifyService dengan OAuth 2.0 flow
✅ SpotifyConnectWidget di CompleteProfileScreen
✅ Deep linking untuk Android (muscta://callback)
✅ Deep linking untuk iOS (muscta://callback)
✅ Internet permissions
✅ Network security config

## Cara Testing:

1. Build dan jalankan aplikasi di device/emulator
2. Buka Complete Profile Screen
3. Tap "Connect to Spotify" 
4. Browser akan terbuka dengan login Spotify
5. Setelah login berhasil, akan redirect ke app
6. Data musik akan ditampilkan di widget

## Troubleshooting:

- Jika redirect tidak bekerja, pastikan Redirect URI tepat sama
- Jika error scope, periksa permission di dashboard
- Jika deep link gagal, periksa bundle ID/package name
- Untuk testing, pastikan akun Spotify dalam daftar tester

## Security Notes:

- Client Secret tidak boleh di-commit ke public repository
- Gunakan environment variables untuk production
- Implement proper token refresh mechanism
- Handle expired tokens gracefully
