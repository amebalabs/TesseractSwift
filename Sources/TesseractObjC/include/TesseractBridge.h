#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TesseractPageSegMode) {
    TesseractPageSegModeOSDOnly = 0,
    TesseractPageSegModeAutoOSD = 1,
    TesseractPageSegModeAutoOnly = 2,
    TesseractPageSegModeAuto = 3,
    TesseractPageSegModeSingleColumn = 4,
    TesseractPageSegModeSingleBlockVertText = 5,
    TesseractPageSegModeSingleBlock = 6,
    TesseractPageSegModeSingleLine = 7,
    TesseractPageSegModeSingleWord = 8,
    TesseractPageSegModeCircleWord = 9,
    TesseractPageSegModeSingleChar = 10,
    TesseractPageSegModeSparseText = 11,
    TesseractPageSegModeSparseTextOSD = 12,
    TesseractPageSegModeRawLine = 13
};

@interface TesseractBridge : NSObject

@property (nonatomic, readonly) BOOL isInitialized;

- (BOOL)initializeWithDataPath:(NSString *)dataPath language:(NSString *)language;
- (void)setPageSegMode:(TesseractPageSegMode)mode;
- (void)setImageWithData:(NSData *)imageData width:(NSInteger)width height:(NSInteger)height bytesPerPixel:(NSInteger)bytesPerPixel bytesPerLine:(NSInteger)bytesPerLine;
- (nullable NSString *)recognizedText;
- (NSInteger)confidence;
- (void)clear;
- (void)cleanup;

+ (NSArray<NSString *> *)availableLanguagesAtPath:(NSString *)dataPath;

@end

NS_ASSUME_NONNULL_END