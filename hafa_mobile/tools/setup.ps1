# Jalankan dari folder hafa_mobile:   powershell -ExecutionPolicy Bypass -File tools\setup.ps1
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter tidak dijumpai dalam PATH. Pasang Flutter SDK dan buka semula terminal." -ForegroundColor Red
  exit 1
}

Write-Host "1/4  Menjana folder android/ ..." -ForegroundColor Cyan
flutter create --org my.hafa --project-name hafa_mobile --platforms android .

Write-Host "2/4  Memasang AndroidManifest (kamera, NFC, internet) ..." -ForegroundColor Cyan
Copy-Item -Force "tools\AndroidManifest.xml" "android\app\src\main\AndroidManifest.xml"

Write-Host "3/4  Memuat turun pakej ..." -ForegroundColor Cyan
flutter pub get

Write-Host "4/4  Menjana ikon aplikasi ..." -ForegroundColor Cyan
dart run flutter_launcher_icons

Write-Host "`nSiap. Buka folder ini dalam Android Studio, pilih emulator, dan tekan Run." -ForegroundColor Green
