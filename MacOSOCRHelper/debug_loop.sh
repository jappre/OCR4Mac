#!/bin/bash

# Kill any existing instances
pkill -f OCR4Mac

# Build
echo "Building..."
swift build
if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

# Run in background
echo "Starting App..."
.build/arm64-apple-macosx/debug/OCR4Mac &
APP_PID=$!

# Run test script
echo "Running Test Script..."
swift run_test.swift

# Check if app is still running
if ps -p $APP_PID > /dev/null; then
    echo "SUCCESS: App is still running."
    kill $APP_PID
    exit 0
else
    echo "FAILURE: App crashed or exited unexpectedly."
    exit 1
fi
