# How to run 3Bhai and build the APK (VS Code + USB debugging)

## A. One-time setup on your computer
1. Install the Flutter SDK (flutter.dev > Install) and add `flutter\bin` to PATH.
2. Install Android Studio once (it provides the Android SDK), then run:
   `flutter doctor --android-licenses`  (press `y` to accept all)
3. In VS Code install the extensions **Flutter** and **Dart**.
4. Run `flutter doctor`. Fix anything marked with a red cross for Android.

## B. One-time setup on your phone (Android)
1. Settings > About phone > tap **Build number** 7 times.
2. Settings > Developer options > turn on **USB debugging**.
3. Plug the phone in with a data cable, choose **File transfer** mode, and tap
   **Allow** on the "Allow USB debugging?" popup.
4. Check it is seen: `flutter devices` (or `adb devices`).

## C. Prepare the project (once)
Both `android/` and `ios/` folders are already in the project. Open it in VS Code,
open the terminal (Ctrl+`) and run:

    flutter pub get
    flutter test

(or `.\setup.ps1` on Windows / `bash setup.sh` on Mac or Linux).
If a native folder ever looks broken, run
`flutter create --org com.threebhai --project-name three_bhai --platforms=android,ios .`
which only adds missing files and never overwrites `lib/`.

For real accounts, recipes and chat, follow **SETUP_SUPABASE_GEMINI.md** first.

## D. Run on your phone with USB debugging
    flutter devices
    flutter run -d <your-device-id>

Or in VS Code: pick your phone in the bottom-right device selector, open
**Run and Debug** (Ctrl+Shift+D), choose a configuration, press **F5**:
- `3Bhai - demo mode (no Supabase)`: works immediately.
- `3Bhai - with Supabase (env/dev.json)`: real accounts and private history.

While running: `r` = hot reload, `R` = hot restart, `q` = quit.

## E. Build the APK file
Demo mode:

    flutter build apk --release

With Supabase (you MUST pass the keys again when building):

    flutter build apk --release --dart-define-from-file=env/dev.json

The file appears at:

    build/app/outputs/flutter-apk/app-release.apk

Smaller files, one per phone type (use `app-arm64-v8a-release.apk` on most phones):

    flutter build apk --release --split-per-abi

In VS Code you can also press Ctrl+Shift+P > **Tasks: Run Task** >
`Build APK (release, with Supabase)`.

### Install the APK over USB
    adb install -r build/app/outputs/flutter-apk/app-release.apk
or `flutter install -d <your-device-id>`, or copy the file to the phone and tap it.

This APK is signed with the debug key, which is fine for your own phone and
for sharing with friends. For Google Play you need your own signing key.

## F. iOS (iPhone)
iOS apps can only be built on a **Mac with Xcode** (Apple rule). On a Mac:

    flutter pub get
    open -a Simulator
    flutter run -d <iphone-or-simulator-id> --dart-define-from-file=env/dev.json
    flutter build ios --release --dart-define-from-file=env/dev.json

The first run needs Xcode > Runner > Signing & Capabilities > pick your Apple
ID team. The iPhone app icon and bundle id (`com.threebhai.app`) are already set. On Windows you cannot build
iOS locally; use a Mac or a cloud build service such as Codemagic.

## G. Common problems
| Problem | Fix |
|---|---|
| `flutter devices` shows no phone | Different cable (must carry data), re-accept the USB popup, set File transfer mode |
| "unauthorized" in `adb devices` | Unplug, revoke USB debugging authorizations in Developer options, replug |
| Gradle/SDK licence error | `flutter doctor --android-licenses` |
| App opens in "Demo mode" banner | You ran without `--dart-define-from-file=env/dev.json` |
| "Confirm your email" message | Supabase > Authentication > Providers > Email > turn off Confirm email |
| Fonts look plain on first launch | The app downloads its fonts once; needs internet |
