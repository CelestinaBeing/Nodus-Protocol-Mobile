#!/bin/bash
set -e

echo "Starting automated Flutter build pipeline..."

echo "1/5: Cleaning workspace..."
flutter clean

echo "2/5: Fetching dependencies..."
flutter pub get

echo "3/5: Running code generation..."
dart run build_runner build --delete-conflicting-outputs

echo "4/5: Running tests..."
flutter test --exclude-tags golden

echo "5/5: Building app..."
if [ "$1" == "apk" ]; then
    flutter build apk --release
elif [ "$1" == "bundle" ]; then
    flutter build appbundle --release
elif [ "$1" == "ios" ]; then
    flutter build ios --release
else
    echo "No valid build target specified. Use 'apk', 'bundle', or 'ios'."
fi

echo "Build pipeline completed successfully."
