# Contributing to NavigationKit

Thanks for taking the time to contribute! This document covers how to set up the project,
the conventions the codebase follows, and how to submit a change.

## Getting set up

- Xcode 27 or newer (Swift 6.4, iOS 27 SDK).
- Open `Navigator.xcworkspace` — this includes the `NavigationKit` package itself, the
  `NavigationKitDebug` package, and the multi-module `ShowCaseApp` example, which is the
  fastest way to see a change running end to end.

## Running tests

```bash
xcodebuild test \
  -scheme NavigationKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

`Package.swift` lives at the repository root, next to `Navigator.xcworkspace`. If you run
`xcodebuild` from the repo root, it picks up the workspace rather than treating the directory
as a standalone package — copy `Package.swift`, `Sources/`, and `Tests/` elsewhere first if you
need to invoke the `NavigationKit-Package` scheme directly (this is what CI does; see
`.github/workflows/ci.yml`). Running tests through Xcode itself (⌘U on the `NavigationKit`
scheme) works without any of that, since Xcode resolves the package scheme correctly inside the
IDE.

## Building the example app

Select the `ShowCaseApp` scheme in `Navigator.xcworkspace` and run it on an iOS Simulator. The
example exercises every part of the framework — tabs, nested stacks, sheets, deep links — across
several feature packages under `Examples/ShowCaseApp/Packages/Features`.

## Code style

- Favor the existing structure: one type per file, grouped into `Core/`, `Routing/`, `State/`,
  `Modals/`, and `Views/` under `Sources/NavigationKit`.
- Public API should carry doc comments (`///`) explaining what it does and, for non-trivial
  APIs, an example usage block — match the style already used throughout the package.
- Keep `NavigationKit` free of UIKit/AppKit dependencies; platform-specific debugging tooling
  belongs in `NavigationKitDebug`.
- New behavior should come with `Tests/NavigationKitTests` coverage using `swift-testing`
  (`@Test`, `#expect`), matching the existing test files.

## Documentation

User-facing guides live in `Documentation/`, and the DocC catalog lives at
`Sources/NavigationKit/Documentation.docc`. If you add or change public API, update both the
inline doc comments and, where relevant, the matching guide.

## Submitting a change

1. Fork the repository and create a branch from `main`.
2. Make your change, including tests and documentation updates.
3. Make sure `xcodebuild test` passes and the `ShowCaseApp` example still builds.
4. Open a pull request describing the change and the motivation behind it. Link any related
   issue.

## Reporting issues

Please include:

- NavigationKit version (or commit SHA) and Xcode/Swift version.
- A minimal reproduction — a small `StackNavigator`/`RouteBuilder` setup that demonstrates the
  issue is far easier to debug than a description alone.
- What you expected to happen vs. what actually happened.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you're
expected to uphold it.
