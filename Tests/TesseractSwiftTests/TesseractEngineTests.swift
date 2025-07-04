import XCTest
@testable import TesseractSwift
import CoreGraphics
import CoreText

final class TesseractEngineTests: XCTestCase {
    var engine: TesseractEngine!
    var testDataPath: URL!
    
    override func setUpWithError() throws {
        // Create temporary test data directory
        let tempDir = FileManager.default.temporaryDirectory
        testDataPath = tempDir.appendingPathComponent("tessdata")
        try FileManager.default.createDirectory(at: testDataPath, withIntermediateDirectories: true)
        
        // Initialize engine
        engine = TesseractEngine(dataPath: testDataPath.path)
    }
    
    override func tearDownWithError() throws {
        // Clean up
        try? FileManager.default.removeItem(at: testDataPath)
    }
    
    func testInitialization() async throws {
        // Download English language data for testing
        let downloader = LanguageDownloader.shared
        let englishLang = TesseractLanguage(code: "eng", name: "English", script: "Latin", fileSize: nil)
        
        do {
            try await downloader.downloadLanguage(englishLang, to: testDataPath)
            try engine.initialize(language: "eng")
            XCTAssertTrue(engine.isInitialized)
        } catch {
            throw XCTSkip("Could not download language data: \(error)")
        }
    }
    
    func testAvailableLanguages() async throws {
        // Download a language first
        let downloader = LanguageDownloader.shared
        let englishLang = TesseractLanguage(code: "eng", name: "English", script: "Latin", fileSize: nil)
        
        do {
            try await downloader.downloadLanguage(englishLang, to: testDataPath)
            let languages = TesseractEngine.availableLanguages(at: testDataPath.path)
            XCTAssertTrue(languages.contains("eng"))
        } catch {
            throw XCTSkip("Could not download language data: \(error)")
        }
    }
    
    func testTextRecognition() async throws {
        // Skip if we can't download language data
        let downloader = LanguageDownloader.shared
        let englishLang = TesseractLanguage(code: "eng", name: "English", script: "Latin", fileSize: nil)
        
        do {
            try await downloader.downloadLanguage(englishLang, to: testDataPath)
            try engine.initialize(language: "eng")
        } catch {
            throw XCTSkip("Could not download language data: \(error)")
        }
        
        // Create a simple test image with text
        let testImage = createTestImage(text: "Hello World")
        
        do {
            let recognizedText = try engine.recognize(cgImage: testImage)
            XCTAssertTrue(recognizedText.lowercased().contains("hello"))
            
            let confidence = engine.confidence()
            XCTAssertGreaterThan(confidence, 0)
        } catch {
            XCTFail("Recognition failed: \(error)")
        }
    }
    
    func testPageSegmentationModes() throws {
        // Test setting different page segmentation modes
        engine.setPageSegmentationMode(.auto)
        engine.setPageSegmentationMode(.singleLine)
        engine.setPageSegmentationMode(.singleBlock)
        // No assertion needed - just verify no crash
    }
    
    // Helper function to create a test image
    private func createTestImage(text: String) -> CGImage {
        let size = CGSize(width: 200, height: 50)
        let renderer = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        
        // White background
        renderer.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        renderer.fill(CGRect(origin: .zero, size: size))
        
        // Black text using Core Text
        let font = CTFontCreateWithName("Helvetica" as CFString, 24, nil)
        let attributes = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        ] as CFDictionary
        
        let attributedString = CFAttributedStringCreate(nil, text as CFString, attributes)!
        let line = CTLineCreateWithAttributedString(attributedString)
        
        renderer.textPosition = CGPoint(x: 10, y: 15)
        CTLineDraw(line, renderer)
        
        return renderer.makeImage()!
    }
}

final class LanguageDownloaderTests: XCTestCase {
    var downloader: LanguageDownloader!
    var testDirectory: URL!
    
    override func setUpWithError() throws {
        downloader = LanguageDownloader.shared
        testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("test_tessdata")
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: testDirectory)
    }
    
    func testCommonLanguagesAvailable() {
        XCTAssertFalse(LanguageDownloader.commonLanguages.isEmpty)
        XCTAssertTrue(LanguageDownloader.commonLanguages.contains { $0.code == "eng" })
    }
    
    func testLanguageDownloadAndDelete() async throws {
        let language = TesseractLanguage(code: "eng", name: "English", script: "Latin", fileSize: nil)
        
        // Download
        do {
            try await downloader.downloadLanguage(language, to: testDirectory)
            XCTAssertTrue(downloader.isLanguageDownloaded(language, in: testDirectory))
        } catch {
            throw XCTSkip("Could not download language data: \(error)")
        }
        
        // Delete
        try downloader.deleteLanguage(language, from: testDirectory)
        XCTAssertFalse(downloader.isLanguageDownloaded(language, in: testDirectory))
    }
    
    func testDownloadedLanguagesList() async throws {
        let language = TesseractLanguage(code: "eng", name: "English", script: "Latin", fileSize: nil)
        
        do {
            try await downloader.downloadLanguage(language, to: testDirectory)
            let downloaded = downloader.downloadedLanguages(in: testDirectory)
            XCTAssertTrue(downloaded.contains("eng"))
        } catch {
            throw XCTSkip("Could not download language data: \(error)")
        }
    }
}