# Windows PowerShell. Run once from the project folder:  .\setup.ps1
$ErrorActionPreference = "Stop"
flutter pub get
flutter test
Write-Host "`nDone. Plug in your phone and run:  flutter devices  then  flutter run"
