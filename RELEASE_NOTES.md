# Release Notes

## v1.0.0 - Initial Release

### 🎉 Overview

TesseractSwift is a modern Swift wrapper for Tesseract OCR, providing a clean and intuitive API for text recognition in macOS applications. This initial release brings powerful OCR capabilities to Swift developers with a focus on ease of use and performance.

### ✨ Features

- **Pure Swift API** - Modern Swift interface with full type safety
- **Async/Await Support** - First-class support for Swift concurrency
- **macOS 13+ Support** - Optimized for modern macOS versions
- **100+ Languages** - Support for over 100 languages via Tesseract
- **Swift Package Manager** - Easy integration via SPM
- **Pre-built XCFrameworks** - No need to compile Tesseract from source
- **Built-in Language Downloader** - Automatic downloading of language data files
- **Direct CGImage Support** - Process images directly without conversion

### 📦 What's Included

- `TesseractSwift` - Main Swift library
- `TesseractObjC` - Objective-C++ bridge layer
- `TesseractCore.xcframework` - Pre-compiled Tesseract 5.x
- `Leptonica.xcframework` - Pre-compiled Leptonica image processing library
- Complete API documentation
- Example usage code

### 🚀 Getting Started

```swift
import TesseractSwift

// Initialize engine
let engine = TesseractEngine()
try await engine.initialize(language: .english)

// Recognize text
let text = try engine.recognize(cgImage: image)
print("Recognized: \(text)")
```

### 📋 Requirements

- **Platform**: macOS 13.0+
- **Architecture**: Apple Silicon (ARM64) only
- **Xcode**: 15.0+
- **Swift**: 5.9+

### ⚠️ Known Limitations

- **ARM64 Only** - Currently supports only Apple Silicon Macs (M1/M2/M3)
- **No iOS Support** - iOS support coming in future release
- **No Intel Support** - x86_64 architecture not supported in this release

### 🔧 Technical Details

- Built with Tesseract 5.x
- Includes Leptonica for image processing
- Thread-safe implementation
- Memory-efficient design
- Supports multiple OCR engine modes

### 📝 API Highlights

#### TesseractEngine
- `initialize(language:)` - Initialize with language
- `recognize(cgImage:)` - Recognize text from CGImage
- `confidence()` - Get recognition confidence
- `setPageSegmentationMode(_:)` - Configure recognition mode
- `availableLanguages()` - List installed languages

#### LanguageDownloader
- `downloadLanguage(_:)` - Download language data
- `deleteLanguage(_:)` - Remove language data
- `isLanguageDownloaded(_:)` - Check if language is available
- `downloadedLanguages()` - List all downloaded languages
- `availableLanguages()` - List all available languages

### 🐛 Bug Fixes

This is the initial release.

### 🙏 Acknowledgments

- Tesseract OCR team for the amazing OCR engine
- Leptonica team for the image processing library
- Swift community for feedback and support

### 📄 License

MIT License - See LICENSE file for details

### 🔗 Links

- [Documentation](https://github.com/amebalabs/TesseractSwift#readme)
- [Example Code](https://github.com/amebalabs/TesseractSwift/blob/main/Sources/TesseractSwift/Example.swift)
- [Issue Tracker](https://github.com/amebalabs/TesseractSwift/issues)

---

**Note**: This is a pre-release version. Please report any issues or feedback via GitHub Issues.