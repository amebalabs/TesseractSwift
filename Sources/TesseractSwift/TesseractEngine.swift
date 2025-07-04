import Foundation
import TesseractObjC

/// Errors that can occur during Tesseract OCR operations.
public enum TesseractError: Error {
    /// The Tesseract engine failed to initialize. This typically occurs when the tessdata directory is invalid or missing.
    case initializationFailed
    
    /// The provided image data could not be processed. Check that the image format and dimensions are valid.
    case imageProcessingFailed
    
    /// Text recognition failed. This may occur if the image quality is too poor or the engine is not properly initialized.
    case recognitionFailed
    
    /// The requested language is not available in the tessdata directory.
    case languageNotAvailable
    
    /// The specified data path does not exist or is not accessible.
    case dataPathNotFound
}

/// Page segmentation modes for Tesseract OCR.
///
/// These modes control how Tesseract segments the image before recognition.
/// Choose the appropriate mode based on your document layout.
public enum PageSegmentationMode: Int {
    /// Orientation and script detection only.
    case osdOnly = 0
    
    /// Automatic page segmentation with orientation and script detection.
    case autoOSD = 1
    
    /// Automatic page segmentation, but no OSD or OCR.
    case autoOnly = 2
    
    /// Fully automatic page segmentation, but no OSD. (Default)
    case auto = 3
    
    /// Assume a single column of text of variable sizes.
    case singleColumn = 4
    
    /// Assume a single uniform block of vertically aligned text.
    case singleBlockVerticalText = 5
    
    /// Assume a single uniform block of text.
    case singleBlock = 6
    
    /// Treat the image as a single text line.
    case singleLine = 7
    
    /// Treat the image as a single word.
    case singleWord = 8
    
    /// Treat the image as a single word in a circle.
    case circleWord = 9
    
    /// Treat the image as a single character.
    case singleChar = 10
    
    /// Find as much text as possible in no particular order.
    case sparseText = 11
    
    /// Sparse text with orientation and script detection.
    case sparseTextOSD = 12
    
    /// Treat the image as a single text line, bypassing hacks specific to Tesseract.
    case rawLine = 13
    
    var bridgeValue: TesseractPageSegMode {
        TesseractPageSegMode(rawValue: self.rawValue) ?? .auto
    }
}

/// A Swift wrapper for the Tesseract OCR engine.
///
/// TesseractEngine provides optical character recognition capabilities for images.
/// Before using, you must download the appropriate language data files and initialize
/// the engine with a valid tessdata directory path.
///
/// Example usage:
/// ```swift
/// let engine = TesseractEngine(dataPath: "/path/to/tessdata")
/// try engine.initialize(language: "eng")
/// let text = try engine.recognize(cgImage: myImage)
/// print("Recognized text: \(text)")
/// print("Confidence: \(engine.confidence())%")
/// ```
///
/// - Note: This class is not thread-safe. Use separate instances for concurrent operations.
public class TesseractEngine {
    private let bridge: TesseractBridge
    private let dataPath: String
    private var currentLanguage: String?
    
    /// Indicates whether the engine has been successfully initialized.
    /// You must initialize the engine before performing OCR.
    public var isInitialized: Bool {
        bridge.isInitialized
    }
    
    /// Creates a new Tesseract engine instance.
    /// - Parameter dataPath: Path to the directory containing tessdata files.
    ///   This directory must exist and contain valid .traineddata files.
    /// - Note: Creating an engine does not initialize it. Call `initialize(language:)` before use.
    public init(dataPath: String) {
        self.dataPath = dataPath
        self.bridge = TesseractBridge()
    }
    
    deinit {
        bridge.cleanup()
    }
    
    /// Initializes the Tesseract engine with the specified language.
    /// 
    /// - Parameter language: The language code (e.g., "eng" for English, "fra" for French).
    ///   Multiple languages can be specified with "+" separator (e.g., "eng+fra").
    /// - Throws: `TesseractError.dataPathNotFound` if the tessdata directory doesn't exist.
    ///   `TesseractError.initializationFailed` if initialization fails.
    public func initialize(language: String = "eng") throws {
        guard FileManager.default.fileExists(atPath: dataPath) else {
            throw TesseractError.dataPathNotFound
        }
        
        guard bridge.initialize(withDataPath: dataPath, language: language) else {
            throw TesseractError.initializationFailed
        }
        
        currentLanguage = language
    }
    
    /// Sets the page segmentation mode for recognition.
    /// 
    /// - Parameter mode: The segmentation mode to use. Default is `.auto`.
    public func setPageSegmentationMode(_ mode: PageSegmentationMode) {
        bridge.setPageSegMode(mode.bridgeValue)
    }
    
    /// Performs OCR on image data.
    /// 
    /// - Parameters:
    ///   - imageData: Image data in raw pixel format.
    ///   - width: Width of the image in pixels.
    ///   - height: Height of the image in pixels.
    ///   - bytesPerPixel: Number of bytes per pixel (default is 4 for RGBA).
    ///   - bytesPerRow: Number of bytes per row. If nil, calculated as width * bytesPerPixel.
    /// - Returns: The recognized text from the image.
    /// - Throws: `TesseractError.initializationFailed` if engine not initialized.
    ///   `TesseractError.recognitionFailed` if recognition fails.
    public func recognize(imageData: Data, width: Int, height: Int, bytesPerPixel: Int = 4, bytesPerRow: Int? = nil) throws -> String {
        guard isInitialized else {
            throw TesseractError.initializationFailed
        }
        
        let actualBytesPerRow = bytesPerRow ?? (width * bytesPerPixel)
        bridge.setImageWith(imageData, width: width, height: height, bytesPerPixel: bytesPerPixel, bytesPerLine: actualBytesPerRow)
        
        guard let text = bridge.recognizedText() else {
            throw TesseractError.recognitionFailed
        }
        
        return text
    }
    
    /// Returns the confidence score of the last recognition operation.
    /// 
    /// - Returns: Confidence score as a percentage (0-100).
    public func confidence() -> Int {
        bridge.confidence()
    }
    
    /// Clears the current recognition results and prepares for a new image.
    public func clear() {
        bridge.clear()
    }
    
    /// Returns a list of available languages in the specified tessdata directory.
    /// 
    /// - Parameter dataPath: Path to the directory containing tessdata files.
    /// - Returns: Array of language codes found in the directory.
    /// - Note: Languages are identified by .traineddata files in the directory.
    public static func availableLanguages(at dataPath: String) -> [String] {
        TesseractBridge.availableLanguages(atPath: dataPath)
    }
}

// MARK: - CGImage Extension
#if canImport(CoreGraphics)
import CoreGraphics

extension TesseractEngine {
    /// Performs OCR on a CGImage.
    /// 
    /// - Parameter cgImage: The image to process.
    /// - Returns: The recognized text from the image.
    /// - Throws: `TesseractError.imageProcessingFailed` if image cannot be processed.
    ///   `TesseractError.initializationFailed` if engine not initialized.
    ///   `TesseractError.recognitionFailed` if recognition fails.
    /// 
    /// Example:
    /// ```swift
    /// let image = UIImage(named: "document")!.cgImage!
    /// let text = try engine.recognize(cgImage: image)
    /// ```
    public func recognize(cgImage: CGImage) throws -> String {
        guard let imageData = cgImage.pixelData() else {
            throw TesseractError.imageProcessingFailed
        }
        
        return try recognize(
            imageData: imageData,
            width: cgImage.width,
            height: cgImage.height,
            bytesPerPixel: 4,
            bytesPerRow: cgImage.bytesPerRow
        )
    }
}

extension CGImage {
    func pixelData() -> Data? {
        let width = self.width
        let height = self.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        var pixelData = Data(count: height * bytesPerRow)
        
        pixelData.withUnsafeMutableBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else { return }
            
            guard let context = CGContext(
                data: baseAddress,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return
            }
            
            context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        return pixelData
    }
}
#endif
