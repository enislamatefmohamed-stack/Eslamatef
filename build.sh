#!/bin/bash
set -e

echo "=== Vercel Build Script for Flutter Web ==="

# Check if flutter is already in PATH
if command -v flutter &> /dev/null; then
  echo "Flutter is already installed on the system."
else
  echo "Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable _flutter
  export PATH="$PATH:$(pwd)/_flutter/bin"
fi

echo "Configuring Flutter..."
flutter config --no-analytics

echo "Building Flutter Web release..."
flutter build web --release

echo "Copying presentation files into web output..."
cp -r presentation build/web/presentation || true

echo "=== Flutter Web Build Completed Successfully! ==="
