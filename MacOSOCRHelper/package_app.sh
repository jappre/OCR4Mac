#!/bin/bash

APP_NAME="OCR4Mac"
BUILD_DIR=".build/arm64-apple-macosx/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# 1. Build release version
echo "Building release version..."
swift build -c release
if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

# 2. Create App Bundle structure
echo "Creating App Bundle structure..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 3. Copy executable
echo "Copying executable..."
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# 4. Create Info.plist
echo "Creating Info.plist..."
cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${APP_NAME}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/> <!-- This makes it a menu bar app (no dock icon) -->
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSScreenCaptureUsageDescription</key>
    <string>We need access to screen recording to capture the area you select for OCR.</string>
</dict>
</plist>
EOF

# 5. Create PkgInfo
echo "APPL????" > "${CONTENTS_DIR}/PkgInfo"

# 6. Optional: Create a simple icon (if you had an AppIcon.icns)
# cp AppIcon.icns "${RESOURCES_DIR}/"

echo "App Bundle created at: ${APP_BUNDLE}"
echo "You can move this to /Applications to use it."
