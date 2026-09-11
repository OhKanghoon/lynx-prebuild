# Lynx XCFramework Builder

Minimal CI/CD wrapper that turns the Lynx CocoaPods stack into distributable XCFramework zips. Everything is generated on demand so the repo only stores build logic.

The release set is derived from the build, not hand-maintained: every framework the `Pods-LynxPrebuild` scheme produces becomes an XCFramework and ships in the release, minus the CocoaPods umbrella target (`Pods_LynxPrebuild`, a static aggregate). Adding or removing a pod in the `Podfile` is therefore the only change needed to change what a release contains.

To keep that from silently under-delivering, `build_xcframeworks.sh` diffs what it built against `Pods/Target Support Files/Pods-LynxPrebuild/Pods-LynxPrebuild-frameworks.sh` — the manifest Xcode itself uses to embed frameworks — and fails the build on any mismatch. A framework that stops being produced breaks CI instead of quietly vanishing from a release.

## Subspec Selection

The manifest cross-check above guards the set of frameworks, not what is inside each one. A pod that gains a subspec between releases changes a framework's contents while the framework count stays identical, so nothing fails — that is how the `4.0.1` release shipped `XElement` with four of its ten subspecs. When bumping versions, diff each pod's subspec list, not just its version.

Two pods need their subspecs named explicitly in the `Podfile`:

- **`XElement`** defaults to eleven subspecs. `Markdown`, `Behavior` and `AnimaX` cannot be built here at all: `Markdown` depends on `ServalMarkdown`, which pulls `LynxTextra`, a statically linked binary that CocoaPods will not embed under `use_frameworks!`; `AnimaX` (outside the default set) is itself a `static_framework` pod that also depends on `LynxTextra`. Since `Behavior` — the `LynxUI*AutoRegistry` glue — depends on `Markdown`, it is out too, which is why the host app has to register components itself. `SVG` and `Refresh` build fine but each adds a third-party framework (`ServalSVG`, `MJRefresh`) to the release. Everything else, `Video` included, is in.
- **`LynxService`** declares no `default_subspecs`, which in CocoaPods means *all* of them. Naming `Devtool` is what keeps `Http`, `Image` and `Log` out; `Image` alone would add `SDWebImage`, `SDWebImageWebPCoder` and `libwebp`.

Everything else is either at its own default (`Lynx`, `PrimJS`, `DebugRouter`) or has no default and is deliberately taken whole (`LynxDevtool`). Subspecs a pod adds for its own use — `Lynx/Gfx` and `LynxServiceAPI/Native` in 4.1.0 — arrive through `Lynx/Framework`'s own dependencies and need no `Podfile` entry.

## Spec Sources

lynx-family stopped publishing to CocoaPods trunk after 4.0.2 — their [Specs repo](https://github.com/lynx-family/Specs) states that "cocoapods trunk is no longer maintained". From 4.1.0 the `Lynx`, `LynxBase`, `LynxServiceAPI`, `LynxService`, `LynxDevtool`, `BaseDevtool` and `XElement` podspecs exist only in that self-hosted repo, which the `Podfile` lists as a `source` alongside the CDN. `PrimJS`, `DebugRouter` and `SocketRocket` still resolve from trunk; `Podfile.lock`'s `SPEC REPOS` section records which repo each pod came from.

## Upstream Workarounds

The `Podfile`'s `post_install` hook drops `rts_inspector_manager_factory_stub_ios.cc` from the `LynxDevtool` target. LynxDevtool 4.1.0's GN target compiles that file *in addition to* the generic `rts_inspector_manager_factory_stub.cc` on iOS, and both define `LynxRegisterRTSInspectorManagerFactory`. Upstream consumes LynxDevtool as a static framework, where the linker takes the first matching object out of the archive and never sees the second; a dynamic framework links every object and the archive fails with `ld: 1 duplicate symbols`. The generic stub is the one that must survive — it alone defines `LynxRegisterRTSInspectorManagerFactoryImpl`, which `LynxDevToolNGDarwinDelegate.mm` anchors — so the object set after the hook is exactly what 4.0.1 built. The hook is guarded on both files being present and becomes a no-op once upstream fixes the GN target; as of `4.3.0-nightly.202609090610` it has not.

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
- Steps: set up Ruby → run `bundle exec rake release:prepare` → compute SHA-256 checksums → publish a GitHub Release with every `.xcframework.zip` under `output/release/artifacts/`, tabulated with its checksum in the release body.

If you prefer manual releases, run the workflow via `workflow_dispatch`, download the artifacts, and create the release yourself.

The job runs on the `macos-26` image with whatever Xcode that image ships as its default, deliberately unpinned. The SDK the frameworks are compiled against matters: code gated on the build SDK — such as `XElement`'s glass effects, which are compiled only when `__IPHONE_26_0` is available — is silently absent from a binary built with an older Xcode, with no build failure to point at it. Tracking the image default keeps the SDK current without a version bump on every Xcode release.

## Using the binaries

Each release contains one zip per framework CocoaPods would embed. The release notes are authoritative for a given tag — they list exactly what shipped, with each zip's SHA-256 checksum.

These are dynamic frameworks, so you need every framework in the transitive closure of what you link. As of Lynx 4.1.0 the graph is:

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
