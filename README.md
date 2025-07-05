![logo](https://github.com/user-attachments/assets/e0e2065c-2b54-44c3-99dc-22bd598f7c62)
# TesseractSwift

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016%2B%20%7C%20macOS%2013%2B-blue.svg)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://github.com/amebalabs/TesseractSwift/blob/main/LICENSE)

A modern Swift wrapper for Tesseract OCR, providing a clean API for text recognition in iOS and macOS applications.


## Features

- 🚀 Pure Swift API with async/await support
- 📱 iOS 16+ and macOS 13+ support
- 🌍 100+ language support via Tesseract
- 📦 Distributed as Swift Package Manager
- 🎯 Pre-built XCFrameworks for easy integration
- 💾 Built-in language data downloader
- 🖼 Direct CGImage support

## Requirements

- **macOS**: Apple Silicon (ARM64) Macs only
- **iOS**: Currently not supported (XCFrameworks need iOS slices)
- **Architecture**: ARM64 only (Intel x86_64 not supported)

## Installation

### Swift Package Manager

Add TesseractSwift to your project:

```swift
dependencies: [
    .package(url: "https://github.com/amebalabs/TesseractSwift.git", from: "1.0.0")
]
```

## Usage

### Basic Text Recognition

```swift
import TesseractSwift

// Initialize engine
let engine = TesseractEngine(dataPath: "/path/to/tessdata")
try engine.initialize(language: "eng")

// Recognize text from CGImage
let text = try engine.recognize(cgImage: image)
print("Recognized text: \(text)")
print("Confidence: \(engine.confidence())%")
```

### Download Language Data

```swift
let downloader = LanguageDownloader.shared
let language = TesseractLanguage(code: "fra", name: "French", script: "Latin", fileSize: nil)

// Download language data
try await downloader.downloadLanguage(language, to: tessdataURL) { progress in
    print("Download progress: \(progress * 100)%")
}
```

### Available Languages

```swift
// Get list of common languages
let languages = LanguageDownloader.commonLanguages

// Check downloaded languages
let downloaded = downloader.downloadedLanguages(in: tessdataURL)
```

### Page Segmentation Modes

```swift
// Set recognition mode based on your content
engine.setPageSegmentationMode(.auto)        // Automatic detection
engine.setPageSegmentationMode(.singleLine)  // Single line of text
engine.setPageSegmentationMode(.singleBlock) // Uniform block of text
```

## Language Support

TesseractSwift supports 100+ languages. Common languages include:

- English (eng)
- Spanish (spa)
- French (fra)
- German (deu)
- Italian (ita)
- Portuguese (por)
- Russian (rus)
- Chinese Simplified (chi_sim)
- Chinese Traditional (chi_tra)
- Japanese (jpn)
- Korean (kor)
- Arabic (ara)
- Hindi (hin)

## Integration with TRex

This package was created to provide Tesseract OCR support for [TRex](https://github.com/amebalabs/TRex), extending its language support beyond the built-in Vision framework.

### Example Integration

```swift
import TesseractSwift

class TesseractOCREngine: OCREngine {
    private let engine: TesseractEngine

    init(dataPath: String) {
        self.engine = TesseractEngine(dataPath: dataPath)
    }

    func recognizeText(in image: CGImage) async throws -> String {
        if !engine.isInitialized {
            try engine.initialize(language: "eng")
        }
        return try engine.recognize(cgImage: image)
    }
}
```

## Building from Source

1. Clone the repository
2. Ensure you have the pre-built XCFrameworks in `Binaries/`
3. Open in Xcode or build via command line:

```bash
swift build
swift test
```

## Requirements

- iOS 16.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## License

This package includes Tesseract OCR (Apache 2.0) and Leptonica (BSD-style license).
