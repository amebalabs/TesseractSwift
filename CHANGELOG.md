# Changelog

All notable changes to TesseractSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-04

### Added
- Initial release of TesseractSwift
- Pure Swift API with async/await support
- iOS 16+ and macOS 13+ support
- Pre-built XCFrameworks for Tesseract 5.5.0 and Leptonica
- Support for 100+ languages via Tesseract
- Built-in language data downloader with progress tracking
- Direct CGImage support for OCR
- Comprehensive test suite
- Example integration code for TRex app
- MIT License with proper attribution

### Features
- `TesseractEngine` - Main OCR engine class
- `LanguageDownloader` - Async language data downloader
- `TesseractLanguage` - Language model with metadata
- Thread-safe operations
- Confidence score reporting
- Multiple language support in single recognition

[1.0.0]: https://github.com/amebalabs/TesseractSwift/releases/tag/v1.0.0