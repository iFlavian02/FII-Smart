# FII Smart App Build Instructions

This document contains instructions for building the FII Smart app with optimized build settings.

## Using the Build Scripts

The repository includes two build scripts for easy building with pre-configured options:

### For Windows (PowerShell)

```powershell
# Simple build with default options (release APK)
.\build_app.ps1

# Build a debug APK
.\build_app.ps1 -buildType debug

# Build an App Bundle for Google Play Store
.\build_app.ps1 -target appbundle

# See all available options
.\build_app.ps1 -help
```

### For macOS/Linux (Bash)

```bash
# Make sure the script is executable
chmod +x build_app.sh

# Simple build with default options (release APK)
./build_app.sh

# Build a debug APK
./build_app.sh --debug

# Build an App Bundle for Google Play Store
./build_app.sh --appbundle

# See all available options
./build_app.sh --help
```

## Manual Building

If you prefer to build manually without using the scripts:

```bash
# For release APK without tree-shaking icons
flutter build apk --release --no-tree-shake-icons

# For debug APK without tree-shaking icons
flutter build apk --debug --no-tree-shake-icons
```

## Build Outputs

- APK files: `build/app/outputs/flutter-apk/`
- App Bundle: `build/app/outputs/bundle/`
- Web: `build/web/`

## About Tree-Shaking Icons

The `--no-tree-shake-icons` flag prevents Flutter from analyzing and removing unused icons from the font files. This makes the build process slightly faster but may result in a slightly larger app size.

## Troubleshooting

If you encounter build issues:

1. Try cleaning the build with `flutter clean`
2. Make sure all dependencies are up to date with `flutter pub get`
3. Check that you have the correct versions of the Android SDK and build tools
