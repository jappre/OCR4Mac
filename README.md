# OCR4Mac

A lightweight, privacy-focused macOS menu bar app for instant OCR (Optical Character Recognition). Capture any part of your screen and extract text immediately.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Swift](https://img.shields.io/badge/language-Swift-orange.svg)

## ✨ Features

- **⚡️ Instant Capture**: Global hotkey (`Cmd + Option + A`) to start capturing immediately.
- **🔒 Privacy First**: Uses Apple's on-device Vision Framework. No data is ever uploaded to the cloud.
- **📋 Auto-Copy**: Recognized text is automatically copied to your clipboard.
- **🌍 Multi-Language**: Optimized for English, Chinese (Simplified & Traditional), Japanese, and Korean.
- **🎨 Native Experience**: Built with SwiftUI and AppKit, designed to feel right at home on macOS.
- **🪶 Lightweight**: Minimal resource usage, runs quietly in your menu bar.

## 🚀 Installation

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/OCR4Mac.git
   cd OCR4Mac
   ```

2. Run directly via CLI (for testing):
   ```bash
   swift run
   ```

3. Or package as an App Bundle:
   ```bash
   chmod +x package_app.sh
   ./package_app.sh
   ```
   Then drag `OCR4Mac.app` to your `/Applications` folder.

## 📖 Usage

1. **Launch the App**: The app runs in the background with a menu bar icon.
2. **Capture**: Press **`Cmd + Option + A`**.
3. **Select**: Drag to select the area containing text.
4. **Done**: The text is extracted, copied to your clipboard, and displayed in a floating result window.

## 🛠 Tech Stack

- **Language**: Swift 5
- **UI**: SwiftUI & AppKit
- **OCR Engine**: Apple Vision Framework (`VNRecognizeTextRequest`)
- **Architecture**: Lightweight, executable Swift package structure

## ⚠️ Permissions

On the first launch, macOS will ask for **Screen Recording** permission. This is required to capture the screen pixels for OCR processing.

- Go to **System Settings** > **Privacy & Security** > **Screen Recording** and enable OCR4Mac.

## 🗺 Roadmap

- [x] Basic OCR & Clipboard Copy
- [x] Global Hotkey (`Cmd + Option + A`)
- [x] Multi-language Support (Chinese/English/Japanese/Korean)
- [ ] Customizable Hotkeys
- [ ] History Management
- [ ] Text Translation Integration (LLM)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
