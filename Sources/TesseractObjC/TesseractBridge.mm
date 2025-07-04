#import "TesseractBridge.h"

// Avoid conflicts with macOS system headers
#ifdef fract1
#undef fract1
#endif
#ifdef fract2
#undef fract2
#endif

#import <TesseractCore/baseapi.h>
#import <Leptonica/allheaders.h>
#include <memory>
#include <string>
#include <vector>

@interface TesseractBridge () {
    std::unique_ptr<tesseract::TessBaseAPI> _tesseract;
}
@end

@implementation TesseractBridge

- (instancetype)init {
    self = [super init];
    if (self) {
        _tesseract = std::make_unique<tesseract::TessBaseAPI>();
        _isInitialized = NO;
    }
    return self;
}

- (void)dealloc {
    [self cleanup];
}

- (BOOL)initializeWithDataPath:(NSString *)dataPath language:(NSString *)language {
    if (!_tesseract) {
        return NO;
    }
    
    const char *dataPathCStr = [dataPath UTF8String];
    const char *languageCStr = [language UTF8String];
    
    int result = _tesseract->Init(dataPathCStr, languageCStr);
    _isInitialized = (result == 0);
    
    return _isInitialized;
}

- (void)setPageSegMode:(TesseractPageSegMode)mode {
    if (_tesseract && _isInitialized) {
        _tesseract->SetPageSegMode(static_cast<tesseract::PageSegMode>(mode));
    }
}

- (void)setImageWithData:(NSData *)imageData width:(NSInteger)width height:(NSInteger)height bytesPerPixel:(NSInteger)bytesPerPixel bytesPerLine:(NSInteger)bytesPerLine {
    if (!_tesseract || !_isInitialized) {
        return;
    }
    
    const unsigned char *bytes = static_cast<const unsigned char *>([imageData bytes]);
    _tesseract->SetImage(bytes, (int)width, (int)height, (int)bytesPerPixel, (int)bytesPerLine);
}

- (nullable NSString *)recognizedText {
    if (!_tesseract || !_isInitialized) {
        return nil;
    }
    
    char *text = _tesseract->GetUTF8Text();
    if (!text) {
        return nil;
    }
    
    NSString *result = [NSString stringWithUTF8String:text];
    delete[] text;
    
    return result;
}

- (NSInteger)confidence {
    if (!_tesseract || !_isInitialized) {
        return 0;
    }
    
    return _tesseract->MeanTextConf();
}

- (void)clear {
    if (_tesseract) {
        _tesseract->Clear();
    }
}

- (void)cleanup {
    if (_tesseract) {
        _tesseract->End();
        _tesseract.reset();
        _isInitialized = NO;
    }
}

+ (NSArray<NSString *> *)availableLanguagesAtPath:(NSString *)dataPath {
    NSMutableArray<NSString *> *languages = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:dataPath error:&error];
    
    if (error) {
        return languages;
    }
    
    for (NSString *file in files) {
        if ([file hasSuffix:@".traineddata"]) {
            NSString *language = [file stringByDeletingPathExtension];
            [languages addObject:language];
        }
    }
    
    return [languages copy];
}

@end