// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TesseractSwift",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TesseractSwift",
            targets: ["TesseractSwift"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TesseractObjC",
            dependencies: ["TesseractCore", "Leptonica"],
            path: "Sources/TesseractObjC",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("include"),
                .define("TESS_EXPORTS")
            ],
            linkerSettings: [
                .linkedLibrary("curl"),
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "TesseractSwift",
            dependencies: ["TesseractObjC"],
            path: "Sources/TesseractSwift"
        ),
        .binaryTarget(
            name: "TesseractCore",
            path: "Binaries/TesseractCore.xcframework"
        ),
        .binaryTarget(
            name: "Leptonica",
            path: "Binaries/Leptonica.xcframework"
        ),
        .testTarget(
            name: "TesseractSwiftTests",
            dependencies: ["TesseractSwift"],
            resources: [
                .process("Resources")
            ]
        )
    ],
    cxxLanguageStandard: .cxx17
)
