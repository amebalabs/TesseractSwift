# TesseractSwift build commands

# Default command - show available commands
default:
    @just --list

# Build the Swift package
build:
    swift build

# Build for release
build-release:
    swift build -c release

# Run tests
test:
    swift test

# Run tests with coverage
test-coverage:
    swift test --enable-code-coverage

# Clean build artifacts
clean:
    swift package clean
    rm -rf .build

# Update package dependencies
update:
    swift package update

# Generate Xcode project
xcode:
    swift package generate-xcodeproj
    open *.xcodeproj

# Build documentation
docs:
    swift package generate-documentation

# Lint Swift code
lint:
    if command -v swiftlint >/dev/null 2>&1; then \
        swiftlint; \
    else \
        echo "SwiftLint not installed. Install with: brew install swiftlint"; \
    fi

# Format Swift code
format:
    if command -v swift-format >/dev/null 2>&1; then \
        swift-format -i -r Sources/ Tests/; \
    else \
        echo "swift-format not installed. Install with: brew install swift-format"; \
    fi

# Create XCFrameworks from static libraries
create-xcframeworks:
    ./Scripts/create-xcframeworks.sh

# Patch XCFramework headers
patch-headers:
    ./Scripts/patch-headers.sh

# Build for iOS simulator
build-ios:
    xcodebuild -scheme TesseractSwift -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'

# Build for macOS
build-macos:
    xcodebuild -scheme TesseractSwift -destination 'platform=macOS'

# Run example
run-example:
    swift run TesseractSwiftExample

# Check Swift package manifest
check-manifest:
    swift package dump-package

# Resolve package dependencies
resolve:
    swift package resolve

# Show package dependencies
deps:
    swift package show-dependencies

# Archive for release
archive NAME="TesseractSwift":
    mkdir -p build/{{NAME}}
    cp -r Sources build/{{NAME}}/
    cp -r Tests build/{{NAME}}/
    cp Package.swift build/{{NAME}}/
    cp README.md build/{{NAME}}/
    cp LICENSE build/{{NAME}}/
    cp CHANGELOG.md build/{{NAME}}/
    cd build && zip -r {{NAME}}.zip {{NAME}}
    rm -rf build/{{NAME}}
    echo "Archive created at build/{{NAME}}.zip"

# Validate package for Swift Package Index
validate-spi:
    @echo "Validating package for Swift Package Index..."
    @echo "✓ Checking Package.swift..."
    @test -f Package.swift && echo "  Package.swift exists" || echo "  ❌ Package.swift missing"
    @echo "✓ Checking README.md..."
    @test -f README.md && echo "  README.md exists" || echo "  ❌ README.md missing"
    @echo "✓ Checking LICENSE..."
    @test -f LICENSE && echo "  LICENSE exists" || echo "  ❌ LICENSE missing"
    @echo "✓ Checking version tag..."
    @git describe --tags 2>/dev/null && echo "  Version tags exist" || echo "  ⚠️  No version tags (create with: git tag -a 1.0.0 -m 'Version 1.0.0')"
    @echo "✓ Package validation complete!"

# Tag a new version
tag VERSION:
    git tag -a v{{VERSION}} -m "Version {{VERSION}}"
    @echo "Tagged version {{VERSION}}"
    @echo "Push tags with: git push origin v{{VERSION}}"

# Full CI run
ci: clean lint build test

# Prepare for release
release VERSION: ci
    @echo "Preparing release {{VERSION}}..."
    just tag {{VERSION}}
    just archive TesseractSwift-{{VERSION}}
    @echo "Release {{VERSION}} prepared!"
    @echo "Next steps:"
    @echo "1. git push origin main"
    @echo "2. git push origin v{{VERSION}}"
    @echo "3. Create GitHub release with build/TesseractSwift-{{VERSION}}.zip"