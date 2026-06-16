# Technology Stack

**Analysis Date:** 2026-06-16

## Languages

**Primary:**
- Rust 1.75+ — Backend engine, IPC service, rendezvous connection logic, platform-specific APIs.
- Dart 3.1.0+ — Frontend application shell, layout, user interactions, settings UI.

**Secondary:**
- C/C++ — Submodule helpers (e.g. `wf_cliprdr.c`), Sciter UI hooks (legacy).
- Python — Scripting, helper APIs (`api_server.py`), and build orchestration (`build.py`).

## Runtime

**Environment:**
- Compiled Native Binaries — Runs directly on Windows (win32), macOS, Linux (X11/Wayland), Android, and iOS.
- Flutter SDK Runner — Embeds the Dart UI into platform-native windows and interfaces.

**Package Manager:**
- cargo (Rust package manager) — Lockfile: `Cargo.lock` present.
- pub (Dart/Flutter package manager) — Lockfile: `flutter/pubspec.lock` present.

## Frameworks

**Core:**
- Flutter SDK — Cross-platform UI toolkit.
- GetX (Get 4.6.5) — Frontend state management, reactive models, navigation, and dialog routing.
- flutter_rust_bridge (1.80.1) — Bidirectional Dart-Rust FFI generator for high-performance communication.

**Testing:**
- cargo test — Integrated Rust unit and integration tests.
- flutter test — Widget/unit tests in Flutter.

**Build/Dev:**
- `build.py` — Orchestrator for setting up environment variables, compiling Rust libraries, and building Flutter.
- Vcpkg — C/C++ dependency manager (specified in `vcpkg.json`).

## Key Dependencies

**Backend (Rust):**
- `hbb_common` (local crate) — Protocols, protobuf definitions, Sodium encryption (XChaCha20).
- `scrap` (local crate) — Core screen capture and desktop mirroring wrapper.
- `tokio` — Multi-threaded async runtime.
- `parity-tokio-ipc` — Inter-process communication between client and background service.
- `enigo` & `rdev` — Input simulation, event injection, and global listener.
- `reqwest` — HTTP client for API server requests.

**Frontend (Flutter):**
- `desktop_multi_window` — Controls multiple OS windows from a single Flutter process (crucial for multi-session support).
- `flutter_texture_rgba_renderer` / `flutter_gpu_texture_renderer` — Custom video rendering textures for remote screen streams.
- `uni_links` / `uni_links_desktop` — Deep-link registration and URI handling.
- `settings_ui` — Prebuilt layout structures for settings panels.

## Configuration

**Environment:**
- User settings are serialized/deserialized to JSON files (`settings.json` / `state.json`) via `hbb_common` configuration helpers.

**Build:**
- `Cargo.toml` — Rust dependencies and features config.
- `flutter/pubspec.yaml` — Flutter dependencies.
- `vcpkg.json` — C++ native dependencies.
- `build.rs` — Rust pre-build codegen hook.

## Platform Requirements

**Development:**
- Windows/macOS/Linux with Rust (rustup), Flutter SDK, LLVM toolchain, and C++ compiler.

**Production:**
- Distributable installers (MSI/EXE for Windows, DMG for macOS, DEB/AppImage/Flatpak for Linux, APK/IPA for mobile).

---
*Stack analysis: 2026-06-16*
