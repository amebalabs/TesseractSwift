# Contributing to TesseractSwift

First off, thank you for considering contributing to TesseractSwift! It's people like you that make TesseractSwift such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for TesseractSwift. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title** for the issue to identify the problem
- **Describe the exact steps which reproduce the problem** in as many details as possible
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior
- **Explain which behavior you expected to see instead and why**
- **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the problem
- **Include crash reports or logs** if available
- **Include details about your configuration and environment:**
  - Which version of TesseractSwift are you using?
  - What's the name and version of the OS you're using?
  - Which Xcode version are you using?
  - Which iOS/macOS version are you targeting?

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for TesseractSwift, including completely new features and minor improvements to existing functionality.

Before creating enhancement suggestions, please check the existing issues as you might find out that you don't need to create one. When you are creating an enhancement suggestion, please include as many details as possible:

- **Use a clear and descriptive title** for the issue to identify the suggestion
- **Provide a step-by-step description of the suggested enhancement** in as many details as possible
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior** and **explain which behavior you expected to see instead** and why
- **Include screenshots and animated GIFs** which help you demonstrate the steps or point out the part of TesseractSwift which the suggestion is related to
- **Explain why this enhancement would be useful** to most TesseractSwift users

### Pull Requests

The process described here has several goals:

- Maintain TesseractSwift's quality
- Fix problems that are important to users
- Engage the community in working toward the best possible TesseractSwift
- Enable a sustainable system for TesseractSwift's maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. **Fork the repository** and create your branch from `main`
2. **Add tests** for any new functionality
3. **Ensure the test suite passes** by running `swift test`
4. **Make sure your code follows the existing style** of the project
5. **Write a clear commit message** describing your changes
6. **Create a Pull Request** with a clear title and description

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/amebalabs/TesseractSwift.git
   cd TesseractSwift
   ```

2. Open the package in Xcode:
   ```bash
   open Package.swift
   ```

3. Build the project:
   ```bash
   swift build
   ```

4. Run tests:
   ```bash
   swift test
   ```

## Style Guidelines

### Swift Style Guide

- Use 4 spaces for indentation
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use descriptive variable and function names
- Add documentation comments for all public APIs
- Keep functions focused and small
- Use Swift's type inference where it improves readability
- Prefer `let` over `var` when possible
- Use trailing closure syntax when appropriate
- Handle errors appropriately with `do-catch` or `throw`

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line
- Consider starting the commit message with an applicable emoji:
  - 🎨 `:art:` when improving the format/structure of the code
  - 🐎 `:racehorse:` when improving performance
  - 📝 `:memo:` when writing docs
  - 🐛 `:bug:` when fixing a bug
  - 🔥 `:fire:` when removing code or files
  - ✅ `:white_check_mark:` when adding tests
  - 🔒 `:lock:` when dealing with security
  - ⬆️ `:arrow_up:` when upgrading dependencies
  - ⬇️ `:arrow_down:` when downgrading dependencies

## Testing

- Write unit tests for new functionality
- Ensure all tests pass before submitting a PR
- Aim for high test coverage
- Test edge cases and error conditions
- Use XCTest framework for testing

## Documentation

- Update the README.md if needed
- Add inline documentation for public APIs
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/) format
- Include code examples in documentation where helpful

## Questions?

Feel free to open an issue with your question or contact the maintainers directly.

Thank you for contributing! 🎉