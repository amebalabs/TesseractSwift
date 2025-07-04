import Foundation
import CoreGraphics
import CoreText

/// Example usage demonstrating TesseractSwift integration.
public class TesseractExample {
    
    /// Demonstrates basic usage of TesseractSwift with language download and OCR.
    public static func basicUsage() async throws {
        // 1. Set up tessdata directory
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw TesseractError.dataPathNotFound
        }
        let tessdataPath = documentsPath.appendingPathComponent("tessdata")
        
        // 2. Create engine
        let engine = TesseractEngine(dataPath: tessdataPath.path)
        
        // 3. Download language if needed
        let downloader = LanguageDownloader.shared
        guard let englishLang = LanguageDownloader.commonLanguages.first(where: { $0.code == "eng" }) else {
            throw TesseractError.languageNotAvailable
        }
        
        if !downloader.isLanguageDownloaded(englishLang, in: tessdataPath) {
            print("Downloading English language data...")
            try await downloader.downloadLanguage(englishLang, to: tessdataPath) { progress in
                print("Progress: \(Int(progress * 100))%")
            }
        }
        
        // 4. Initialize engine
        try engine.initialize(language: "eng")
        
        // 5. Create sample image (in real app, this would be from camera/screen)
        let sampleImage = createSampleImage()
        
        // 6. Perform OCR
        let recognizedText = try engine.recognize(cgImage: sampleImage)
        print("Recognized text: \(recognizedText)")
        print("Confidence: \(engine.confidence())%")
    }
    
    /// Demonstrates multi-language support with multiple language downloads.
    public static func multiLanguageExample() async throws {
        let tessdataPath = FileManager.default.temporaryDirectory.appendingPathComponent("tessdata")
        let downloader = LanguageDownloader.shared
        
        // Download multiple languages
        let languages = [
            ("eng", "Hello World"),
            ("fra", "Bonjour le monde"),
            ("deu", "Hallo Welt"),
            ("spa", "Hola mundo")
        ]
        
        for (code, _) in languages {
            if let lang = LanguageDownloader.commonLanguages.first(where: { $0.code == code }) {
                if !downloader.isLanguageDownloaded(lang, in: tessdataPath) {
                    print("Downloading \(lang.name)...")
                    try await downloader.downloadLanguage(lang, to: tessdataPath)
                }
            }
        }
        
        // Create engine for each language
        for (code, text) in languages {
            let engine = TesseractEngine(dataPath: tessdataPath.path)
            try engine.initialize(language: code)
            
            // Create image with text in that language
            let image = createTextImage(text: text)
            let recognized = try engine.recognize(cgImage: image)
            
            print("\(code): \(recognized.trimmingCharacters(in: .whitespacesAndNewlines))")
        }
    }
    
    /// Demonstrates different page segmentation modes for various document types.
    public static func segmentationModesExample() throws {
        let engine = TesseractEngine(dataPath: "/path/to/tessdata")
        try engine.initialize()
        
        // Single line of text (e.g., from a document header)
        engine.setPageSegmentationMode(.singleLine)
        
        // Uniform block of text (e.g., from a paragraph)
        engine.setPageSegmentationMode(.singleBlock)
        
        // Sparse text (e.g., from a form or scattered text)
        engine.setPageSegmentationMode(.sparseText)
        
        // Automatic detection (default, works for most cases)
        engine.setPageSegmentationMode(.auto)
    }
    
    // Helper functions
    private static func createSampleImage() -> CGImage {
        createTextImage(text: "Hello TesseractSwift!")
    }
    
    private static func createTextImage(text: String) -> CGImage {
        let size = CGSize(width: 400, height: 100)
        let renderer = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        guard let context = renderer else {
            fatalError("Failed to create CGContext")
        }
        
        // White background
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(origin: .zero, size: size))
        
        // Create text using Core Text (platform-agnostic)
        let fontSize: CGFloat = 36
        let font = CTFontCreateWithName("Helvetica" as CFString, fontSize, nil)
        
        let attributes = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        ] as CFDictionary
        
        guard let attributedString = CFAttributedStringCreate(nil, text as CFString, attributes) else {
            fatalError("Failed to create attributed string")
        }
        let line = CTLineCreateWithAttributedString(attributedString)
        
        context.textPosition = CGPoint(x: 20, y: 30)
        CTLineDraw(line, context)
        
        guard let image = context.makeImage() else {
            fatalError("Failed to create image from context")
        }
        return image
    }
}
