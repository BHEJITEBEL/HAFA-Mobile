#!/usr/bin/env bash
# Jalankan dari folder hafa_mobile:   bash tools/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

command -v flutter >/dev/null || { echo "Flutter tidak dijumpai dalam PATH."; exit 1; }

echo "1/4  Menjana folder android/ ..."
flutter create --org my.hafa --project-name hafa_mobile --platforms android .

echo "2/4  Memasang AndroidManifest (kamera, NFC, internet) ..."
cp -f tools/AndroidManifest.xml android/app/src/main/AndroidManifest.xml

echo "3/4  Memuat turun pakej ..."
flutter pub get

echo "4/4  Menjana ikon aplikasi ..."
dart run flutter_launcher_icons

echo "Siap. Buka folder ini dalam Android Studio, pilih emulator, dan tekan Run."
