# Lynx XCFramework Builder

Minimal CI/CD wrapper that turns the Lynx CocoaPods stack into distributable XCFramework zips. Everything is generated on demand so the repo only stores build logic.

The release set is derived from the build, not hand-maintained: every framework the `Pods-LynxPrebuild` scheme produces becomes an XCFramework and ships in the release, minus the CocoaPods umbrella target (`Pods_LynxPrebuild`, a static aggregate). Adding or removing a pod in the `Podfile` is therefore the only change needed to change what a release contains.

To keep that from silently under-delivering, `build_xcframeworks.sh` diffs what it built against `Pods/Target Support Files/Pods-LynxPrebuild/Pods-LynxPrebuild-frameworks.sh` — the manifest Xcode itself uses to embed frameworks — and fails the build on any mismatch. A framework that stops being produced breaks CI instead of quietly vanishing from a release.

## Resource Bundle Handling

Resource bundles (like `LynxResources.bundle` containing `lynx_core.js`) end up inside their owning framework automatically, because the `Podfile` uses `use_frameworks!` and dynamic frameworks carry their own resources. Nothing in the build script copies them; the XCFrameworks are self-contained as a consequence of the linkage choice.

## Local workflow

```bash
bundle install
bundle exec rake setup:all    # first run only (creates Xcode project + installs pods)
bundle exec rake release:prepare
```

Results are placed under `output/release/artifacts/`.

## GitHub Actions workflow

- Triggers on **any tag push** or manual `workflow_dispatch`.
- Steps: set up Xcode + Ruby → run `bundle exec rake release:prepare` → compute SHA-256 checksums → publish a GitHub Release with every `.xcframework.zip` under `output/release/artifacts/`, tabulated with its checksum in the release body.

If you prefer manual releases, run the workflow via `workflow_dispatch`, download the artifacts, and create the release yourself.

## Using the binaries

Each release contains one zip per framework CocoaPods would embed. The release notes are authoritative for a given tag — they list exactly what shipped, with each zip's SHA-256 checksum.

These are dynamic frameworks, so you need every framework in the transitive closure of what you link. As of Lynx 3.9.0 the graph is:

| Group | Frameworks | Needed when |
| --- | --- | --- |
| Core | `Lynx`, `LynxBase`, `LynxServiceAPI`, `PrimJS` | Always |
| Devtool | `LynxService`, `LynxDevtool`, `BaseDevtool`, `DebugRouter`, `SocketRocket` | Only for debug builds — all-or-nothing, `LynxDevtool` links `SocketRocket` |
| Extensions | `XElement` | Using the `XElement` UI components |

`Lynx` does not link any devtool framework, so a production app that skips the Devtool group needs just the four Core frameworks. `SocketRocket` is reachable only through `LynxDevtool`.

Reference them from your `Package.swift`, copying the checksum out of the release notes table:

```swift
.binaryTarget(
    name: "Lynx",
    url: "https://github.com/<owner>/<repo>/releases/download/<tag>/Lynx.xcframework.zip",
    checksum: "<checksum from release notes>"
)
```

Need to verify locally? `swift package compute-checksum output/release/artifacts/Lynx.xcframework.zip` and `shasum -a 256 output/release/artifacts/Lynx.xcframework.zip` both produce the value the release notes publish.
