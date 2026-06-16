# Directory Structure

**Analysis Date:** 2026-06-16

## Repository Layout

The codebase is split into Rust backend modules in the root `src/` directory, submodules in `libs/`, and a Flutter UI frontend inside the `flutter/` directory.

```
D:\rustdesk_src\rustdesk\
├── .cargo/               # Cargo config
├── .github/              # Github CI/CD workflows
├── appimage/             # AppImage build configurations
├── docs/                 # Documentation (README files, guides)
├── flutter/              # Flutter UI frontend
│   ├── lib/              # Dart source code
│   │   ├── common/       # Reusable components and settings
│   │   ├── desktop/      # Desktop-specific pages and layouts
│   │   ├── mobile/       # Mobile-specific pages and layouts
│   │   ├── models/       # State models and observables (GetX)
│   │   ├── native/       # Native platform integrations (Swift, Java)
│   │   ├── services/     # Background services
│   │   ├── widgets/      # Reusable widgets
│   │   └── main.dart     # Flutter application entry point
│   └── test/             # Flutter unit/widget tests
├── libs/                 # Local git submodules & crates
│   ├── clipboard/        # clipboard sharing library fork
│   ├── enigo/            # Input simulation library fork
│   ├── hbb_common/       # Common protobufs, crypto, configurations
│   └── scrap/            # Screen capture wrapper library
├── res/                  # Desktop icons, MSI installer scripts
├── src/                  # Rust backend engine
│   ├── client/           # Client remote session logic
│   ├── ipc/              # Inter-process communication
│   ├── lang/             # Rust-side translation assets
│   ├── platform/         # OS-specific system APIs
│   ├── privacy_mode/     # Security privacy screen drivers
│   ├── server/           # Connection server, input and clipboard service
│   ├── ui/               # Sciter UI / legacy UI wrappers
│   ├── main.rs           # Rust entry point (routes command line flags)
│   └── lib.rs            # Rust library wrapper
└── Cargo.toml            # Rust workspace dependencies
```

## Key File Locations

- **Main Entry Points:**
  - Rust Entry: `src/main.rs` & `src/core_main.rs`
  - Flutter Entry: `flutter/lib/main.dart`
- **FFI Bindings:**
  - Rust-side bindings: `src/flutter_ffi.rs` & `src/bridge_generated.rs`
  - Dart-side bindings: `flutter/lib/generated_bridge.dart`
- **Settings & Config:**
  - Cargo Dependencies: `Cargo.toml`
  - Pub Dependencies: `flutter/pubspec.yaml`
  - C++ Dependencies: `vcpkg.json`
- **Signalling and Relaying:**
  - Hole punching: `src/rendezvous_mediator.rs`
- **Local IPC Server:**
  - IPC Server listener: `src/ipc.rs`

## Naming Conventions

- **Rust:**
  - File Names: standard Snake Case (e.g., `core_main.rs`, `flutter_ffi.rs`).
  - Types/Structs: standard PascalCase (e.g., `ServerConfig`, `RendezvousMediator`).
  - Variables/Functions: standard snake_case (e.g., `show_server_settings`, `set_server_config`).
- **Dart/Flutter:**
  - File Names: lowercase with underscores (e.g., `dialog.dart`, `desktop_setting_page.dart`).
  - Classes: standard PascalCase (e.g., `CustomAlertDialog`, `ServerConfig`).
  - Variables/Functions: standard camelCase (e.g., `isIdServerFixed`, `serverSettingsTextFormField`).

---
*Structure analysis: 2026-06-16*
