# Integrasi ke proyek Flutter

### 1. Logo
Salin `02_PNG_Icon/Color/moeslim_pm_icon_512.png` ke `assets/branding/moeslim_pm_logo.png`.

### 2. pubspec.yaml
```yaml
flutter:
  assets:
    - assets/branding/
```

### 3. Widget
```dart
Image.asset('assets/branding/moeslim_pm_logo.png', width: 112, height: 112)
```

### 4. Icon Launcher
Pindahkan file `05_Android/mipmap-*` ke `android/app/src/main/res/` sesuai densitas masing-masing.
Untuk adaptive icon, gunakan foreground 432 dan background warna #065F46. Android konfigurasi `ic_launcher.xml` memerlukan nama drawable yang cocok dengan lokasi file.

### 5. Favicon web Flutter
Salin `04_Favicon_Web/favicon.ico` ke `web/favicon.ico`; ubah manifest web sesuai kebutuhan.
