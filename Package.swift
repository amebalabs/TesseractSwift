// swift-tools-version: 5.9
// Note: This package currently only supports ARM64 (Apple Silicon) architecture.
// The binary XCFrameworks (TesseractCore, Leptonica) need to be rebuilt with
// x86_64 slices to support Intel Macs.

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
