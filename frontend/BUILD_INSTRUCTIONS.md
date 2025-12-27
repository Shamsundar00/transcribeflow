# Build Instructions

Run the following commands in your terminal from the `frontend` directory.

## Prerequisite
Ensure you are in the `frontend` directory:
```bash
cd c:\FlutterProjects\Insta_transcription\frontend
```

## 1. Android App
To build a release APK (for creating a `.apk` file to install on phones):
```bash
flutter build apk --release
```
**Output Location:** `build/app/outputs/flutter-apk/app-release.apk`

To build an App Bundle (for Play Store upload):
```bash
flutter build appbundle --release
```
**Output Location:** `build/app/outputs/bundle/release/app-release.aab`

## 2. Windows Desktop App
**Prerequisite:** You must have Visual Studio 2022 installed with the "Desktop development with C++" workload.

To build the executable:
```bash
flutter build windows --release
```
**Output Location:** `build/windows/x64/runner/Release/`
(The executable will be named `frontend.exe` or `transcribeflow.exe` inside this folder).

## 3. Web Application
To build for the web:
```bash
flutter build web --release --wasm
```
*Note: If `--wasm` fails, you can use `flutter build web --release --no-tree-shake-icons`.*

**Output Location:** `build/web/`
(This folder contains the `index.html` and assets ready to be deployed to Firebase Hosting, Vercel, or Netlify).
