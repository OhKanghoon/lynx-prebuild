# Lynx XCFramework Builder

Minimal CI/CD wrapper that turns the Lynx CocoaPods stack into distributable XCFramework zips (`Lynx`, `PrimJS`). Everything is generated on demand so the repo only stores build logic.

## Local workflow

```bash
bundle install
bundle exec rake setup:all    # first run only (creates Xcode project + installs pods)
bundle exec rake release:prepare
```

Results are placed under `output/release/artifacts/`.

## GitHub Actions workflow

- Triggers on **any tag push** or manual `workflow_dispatch`.
- Steps: set up Xcode + Ruby → run `bundle exec rake release:prepare` → compute checksums → publish a GitHub Release with the three `.xcframework.zip` files and their checksums in the body.

If you prefer manual releases, run the workflow via `workflow_dispatch`, download the artifacts, and create the release yourself.

## Using the binaries

Each release contains:

- `Lynx.xcframework.zip`
- `PrimJS.xcframework.zip`

Checksums are printed in the release notes. Reference them from your `Package.swift`:

```swift
.binaryTarget(
    name: "Lynx",
    url: "https://github.com/<owner>/<repo>/releases/download/<tag>/Lynx.xcframework.zip",
    checksum: "<checksum from release notes>"
)
```

Need to verify locally? Run `swift package compute-checksum output/release/artifacts/Lynx.xcframework.zip`.
