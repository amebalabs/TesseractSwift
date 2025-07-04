import Foundation

/// Represents a Tesseract language with metadata.
public struct TesseractLanguage: Codable {
    /// The language code (e.g., "eng" for English, "fra" for French).
    public let code: String
    
    /// The human-readable name of the language.
    public let name: String
    
    /// The script system used by the language (e.g., "Latin", "Cyrillic").
    public let script: String?
    
    /// The approximate file size in bytes of the language data file.
    public let fileSize: Int?
    
    /// The filename for this language's trained data file.
    public var fileName: String {
        "\(code).traineddata"
    }
}

/// Downloads and manages Tesseract language data files.
///
/// LanguageDownloader provides functionality to download language data files
/// from the official Tesseract repository and manage them locally.
///
/// Example usage:
/// ```swift
/// let downloader = LanguageDownloader.shared
/// let language = TesseractLanguage(code: "fra", name: "French", script: "Latin", fileSize: nil)
/// 
/// do {
///     try await downloader.downloadLanguage(language, to: tessdataURL) { progress in
///         print("Download progress: \(progress * 100)%")
///     }
/// } catch {
///     print("Download failed: \(error)")
/// }
/// ```
public class LanguageDownloader {
    /// Shared instance for convenient access.
    public static let shared = LanguageDownloader()
    
    private let baseURL = "https://github.com/tesseract-ocr/tessdata_best/raw/main/"
    private let githubAPIURL = "https://api.github.com/repos/tesseract-ocr/tessdata_best/contents"
    private let session: URLSession
    
    /// Creates a new language downloader instance.
    /// - Parameter session: The URLSession to use for downloads. Defaults to `.shared`.
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Common languages with their display names and metadata.
    /// These represent the most frequently used languages for OCR.
    public static let commonLanguages: [TesseractLanguage] = [
        TesseractLanguage(code: "eng", name: "English", script: "Latin", fileSize: 15_290_718),
        TesseractLanguage(code: "fra", name: "French", script: "Latin", fileSize: 8_884_494),
        TesseractLanguage(code: "deu", name: "German", script: "Latin", fileSize: 8_211_483),
        TesseractLanguage(code: "spa", name: "Spanish", script: "Latin", fileSize: 8_879_210),
        TesseractLanguage(code: "ita", name: "Italian", script: "Latin", fileSize: 8_880_025),
        TesseractLanguage(code: "por", name: "Portuguese", script: "Latin", fileSize: 8_920_834),
        TesseractLanguage(code: "rus", name: "Russian", script: "Cyrillic", fileSize: 10_673_115),
        TesseractLanguage(code: "jpn", name: "Japanese", script: "Japanese", fileSize: 36_605_511),
        TesseractLanguage(code: "chi_sim", name: "Chinese (Simplified)", script: "Chinese", fileSize: 44_366_453),
        TesseractLanguage(code: "chi_tra", name: "Chinese (Traditional)", script: "Chinese", fileSize: 56_012_192),
        TesseractLanguage(code: "kor", name: "Korean", script: "Hangul", fileSize: 12_876_003),
        TesseractLanguage(code: "ara", name: "Arabic", script: "Arabic", fileSize: 36_435_344),
        TesseractLanguage(code: "hin", name: "Hindi", script: "Devanagari", fileSize: 13_780_064),
        TesseractLanguage(code: "tha", name: "Thai", script: "Thai", fileSize: 11_866_002),
        TesseractLanguage(code: "vie", name: "Vietnamese", script: "Latin", fileSize: 9_645_872),
        TesseractLanguage(code: "pol", name: "Polish", script: "Latin", fileSize: 10_009_085),
        TesseractLanguage(code: "nld", name: "Dutch", script: "Latin", fileSize: 10_307_878),
        TesseractLanguage(code: "tur", name: "Turkish", script: "Latin", fileSize: 11_436_347),
        TesseractLanguage(code: "heb", name: "Hebrew", script: "Hebrew", fileSize: 5_454_498),
        TesseractLanguage(code: "swe", name: "Swedish", script: "Latin", fileSize: 9_683_865)
    ]
    
    /// Comprehensive mapping of all Tesseract language codes to display names.
    /// Use this to get human-readable names for language codes.
    public static let languageNames: [String: String] = [
        "afr": "Afrikaans",
        "amh": "Amharic",
        "ara": "Arabic",
        "asm": "Assamese",
        "aze": "Azerbaijani",
        "aze_cyrl": "Azerbaijani (Cyrillic)",
        "bel": "Belarusian",
        "ben": "Bengali",
        "bod": "Tibetan",
        "bos": "Bosnian",
        "bre": "Breton",
        "bul": "Bulgarian",
        "cat": "Catalan",
        "ceb": "Cebuano",
        "ces": "Czech",
        "chi_sim": "Chinese (Simplified)",
        "chi_sim_vert": "Chinese (Simplified Vertical)",
        "chi_tra": "Chinese (Traditional)",
        "chi_tra_vert": "Chinese (Traditional Vertical)",
        "chr": "Cherokee",
        "cos": "Corsican",
        "cym": "Welsh",
        "dan": "Danish",
        "deu": "German",
        "div": "Dhivehi",
        "dzo": "Dzongkha",
        "ell": "Greek",
        "eng": "English",
        "enm": "Middle English",
        "epo": "Esperanto",
        "equ": "Math/Equations",
        "est": "Estonian",
        "eus": "Basque",
        "fao": "Faroese",
        "fas": "Persian",
        "fil": "Filipino",
        "fin": "Finnish",
        "fra": "French",
        "frk": "Frankish",
        "frm": "Middle French",
        "fry": "Frisian",
        "gla": "Scottish Gaelic",
        "gle": "Irish",
        "glg": "Galician",
        "grc": "Ancient Greek",
        "guj": "Gujarati",
        "hat": "Haitian Creole",
        "heb": "Hebrew",
        "hin": "Hindi",
        "hrv": "Croatian",
        "hun": "Hungarian",
        "hye": "Armenian",
        "iku": "Inuktitut",
        "ind": "Indonesian",
        "isl": "Icelandic",
        "ita": "Italian",
        "ita_old": "Italian (Old)",
        "jav": "Javanese",
        "jpn": "Japanese",
        "jpn_vert": "Japanese (Vertical)",
        "kan": "Kannada",
        "kat": "Georgian",
        "kat_old": "Georgian (Old)",
        "kaz": "Kazakh",
        "khm": "Khmer",
        "kir": "Kyrgyz",
        "kmr": "Kurdish (Kurmanji)",
        "kor": "Korean",
        "kor_vert": "Korean (Vertical)",
        "lao": "Lao",
        "lat": "Latin",
        "lav": "Latvian",
        "lit": "Lithuanian",
        "ltz": "Luxembourgish",
        "mal": "Malayalam",
        "mar": "Marathi",
        "mkd": "Macedonian",
        "mlt": "Maltese",
        "mon": "Mongolian",
        "mri": "Maori",
        "msa": "Malay",
        "mya": "Burmese",
        "nep": "Nepali",
        "nld": "Dutch",
        "nor": "Norwegian",
        "oci": "Occitan",
        "ori": "Odia",
        "osd": "Orientation Script Detection",
        "pan": "Punjabi",
        "pol": "Polish",
        "por": "Portuguese",
        "pus": "Pashto",
        "que": "Quechua",
        "ron": "Romanian",
        "rus": "Russian",
        "san": "Sanskrit",
        "sin": "Sinhala",
        "slk": "Slovak",
        "slv": "Slovenian",
        "snd": "Sindhi",
        "spa": "Spanish",
        "spa_old": "Spanish (Old)",
        "sqi": "Albanian",
        "srp": "Serbian",
        "srp_latn": "Serbian (Latin)",
        "sun": "Sundanese",
        "swa": "Swahili",
        "swe": "Swedish",
        "syr": "Syriac",
        "tam": "Tamil",
        "tat": "Tatar",
        "tel": "Telugu",
        "tgk": "Tajik",
        "tha": "Thai",
        "tir": "Tigrinya",
        "ton": "Tongan",
        "tur": "Turkish",
        "uig": "Uyghur",
        "ukr": "Ukrainian",
        "urd": "Urdu",
        "uzb": "Uzbek",
        "uzb_cyrl": "Uzbek (Cyrillic)",
        "vie": "Vietnamese",
        "yid": "Yiddish",
        "yor": "Yoruba"
    ]
    
    /// Downloads a language data file to the specified directory.
    /// 
    /// - Parameters:
    ///   - language: The language to download.
    ///   - directory: The directory to save the file to (typically tessdata).
    ///   - progress: Optional closure called with download progress (0.0 to 1.0).
    /// - Throws: Network errors or file system errors.
    /// - Note: If the language file already exists, this method returns immediately.
    ///         Progress callbacks are called on the main thread.
    public func downloadLanguage(_ language: TesseractLanguage, to directory: URL, progress: ((Double) -> Void)? = nil) async throws {
        let fileURL = directory.appendingPathComponent(language.fileName)
        
        // Check if already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return
        }
        
        guard let downloadURL = URL(string: baseURL + language.fileName) else {
            throw URLError(.badURL)
        }
        
        let (tempURL, response) = try await session.download(from: downloadURL) { bytesWritten, totalBytes in
            if totalBytes > 0 {
                let progressValue = Double(bytesWritten) / Double(totalBytes)
                Task { @MainActor in
                    progress?(progressValue)
                }
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Create directory if needed
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        // Move file to final location
        try FileManager.default.moveItem(at: tempURL, to: fileURL)
    }
    
    /// Deletes a language data file from the specified directory.
    /// 
    /// - Parameters:
    ///   - language: The language to delete.
    ///   - directory: The directory containing the language file.
    /// - Throws: File system errors if deletion fails.
    public func deleteLanguage(_ language: TesseractLanguage, from directory: URL) throws {
        let fileURL = directory.appendingPathComponent(language.fileName)
        try FileManager.default.removeItem(at: fileURL)
    }
    
    /// Checks if a language data file exists in the specified directory.
    /// 
    /// - Parameters:
    ///   - language: The language to check.
    ///   - directory: The directory to check in.
    /// - Returns: `true` if the language file exists, `false` otherwise.
    public func isLanguageDownloaded(_ language: TesseractLanguage, in directory: URL) -> Bool {
        let fileURL = directory.appendingPathComponent(language.fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    /// Returns a list of language codes for downloaded language files.
    /// 
    /// - Parameter directory: The directory to scan for language files.
    /// - Returns: Array of language codes found in the directory.
    public func downloadedLanguages(in directory: URL) -> [String] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return []
        }
        
        return files
            .filter { $0.pathExtension == "traineddata" }
            .map { $0.deletingPathExtension().lastPathComponent }
    }
    
    /// Returns all available Tesseract languages from the language mapping.
    /// 
    /// - Returns: Array of all supported languages, sorted alphabetically by name.
    /// - Note: This excludes special files like "osd" (Orientation Script Detection).
    public static func allAvailableLanguages() -> [TesseractLanguage] {
        languageNames.compactMap { code, name in
            // Skip special files like osd (Orientation Script Detection)
            guard code != "osd" else { return nil }
            
            // Create TesseractLanguage without file size (will be fetched if needed)
            return TesseractLanguage(code: code, name: name, script: nil, fileSize: nil)
        }.sorted { $0.name < $1.name }
    }
    
    /// Fetches available languages from GitHub API with file size information.
    /// 
    /// - Returns: Array of languages with up-to-date file size information.
    /// - Throws: Network errors if the API request fails.
    /// - Note: This method queries the GitHub API and may be rate-limited.
    ///         Use the static `allAvailableLanguages()` for offline access.
    public func fetchAvailableLanguagesFromGitHub() async throws -> [TesseractLanguage] {
        guard let githubURL = URL(string: githubAPIURL) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: githubURL)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        struct GitHubFile: Codable {
            let name: String
            let size: Int
        }
        
        let files = try JSONDecoder().decode([GitHubFile].self, from: data)
        
        return files.compactMap { file in
            guard file.name.hasSuffix(".traineddata") else { return nil }
            
            let code = String(file.name.dropLast(".traineddata".count))
            let name = Self.languageNames[code] ?? code
            
            return TesseractLanguage(code: code, name: name, script: nil, fileSize: file.size)
        }.sorted { $0.name < $1.name }
    }
}

// MARK: - URLSession Extension for Progress
extension URLSession {
    func download(from url: URL, progress: @escaping (Int64, Int64) -> Void) async throws -> (URL, URLResponse) {
        let delegate = ProgressDelegate(progressHandler: progress)
        return try await download(from: url, delegate: delegate)
    }
}

class ProgressDelegate: NSObject, URLSessionTaskDelegate {
    let progressHandler: (Int64, Int64) -> Void
    
    init(progressHandler: @escaping (Int64, Int64) -> Void) {
        self.progressHandler = progressHandler
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progressHandler(totalBytesSent, totalBytesExpectedToSend)
    }
}
