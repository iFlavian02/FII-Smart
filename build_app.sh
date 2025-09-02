#!/bin/bash
# Bash build script for Flutter app with pre-configured options

# Default values
BUILD_TYPE="release"
TARGET="apk"

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --debug|--profile|--release) BUILD_TYPE="${1#--}"; shift ;;
        --apk|--appbundle|--ios|--web) TARGET="${1#--}"; shift ;;
        -h|--help) 
            echo "FII Smart App Build Script"
            echo "Usage: ./build_app.sh [--debug|--profile|--release] [--apk|--appbundle|--ios|--web] [--help]"
            echo ""
            echo "Options:"
            echo "  --debug, --profile, --release    Build type (default: release)"
            echo "  --apk, --appbundle, --ios, --web Build target (default: apk)"
            echo "  -h, --help                      Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
done

# Clear terminal
clear

# Show build configuration
echo "Building FII Smart App..."
echo "Build Type: $BUILD_TYPE"
echo "Target: $TARGET"
echo ""

# Run flutter clean first to ensure a fresh build
echo "Cleaning previous builds..."
flutter clean

# Run flutter build with the specified options
echo "Building the app..."
flutter build $TARGET --$BUILD_TYPE --no-tree-shake-icons

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "\033[0;32mBuild successful!\033[0m"
    
    # Show the build output path based on target
    if [ "$TARGET" = "apk" ]; then
        echo "APK file location: $(pwd)/build/app/outputs/flutter-apk/app-$BUILD_TYPE.apk"
    elif [ "$TARGET" = "appbundle" ]; then
        echo "App Bundle location: $(pwd)/build/app/outputs/bundle/${BUILD_TYPE}Bundle/app-$BUILD_TYPE.aab"
    elif [ "$TARGET" = "ios" ]; then
        echo "iOS build completed"
    elif [ "$TARGET" = "web" ]; then
        echo "Web build location: $(pwd)/build/web"
    fi
else
    echo ""
    echo -e "\033[0;31mBuild failed!\033[0m"
fi
