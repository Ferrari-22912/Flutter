#!/usr/bin/env bash
# macOS / Linux. Run once from the project folder:  bash setup.sh
set -e
flutter pub get
flutter test
echo
echo "Done. Plug in your phone and run:  flutter devices  then  flutter run"
