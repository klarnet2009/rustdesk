# Coding Conventions

**Analysis Date:** 2026-06-16

## Code Style

### Rust
- **Formatting:** Enforced via `rustfmt`.
- **Imports:** Grouped cleanly, with local crates (`hbb_common`, `scrap`) separated from external crates (`tokio`, `serde`).
- **Idiomatic Patterns:**
  - Leverage pattern matching extensively.
  - Avoid `unwrap()` in production code; prefer explicit `Result` management using `map_err`, `and_then`, or default fallbacks.
  - Extensive conditional compilation (`#[cfg(target_os = "...")]`) to write platform-specific screen and input logic without polluting shared backend code.

### Dart / Flutter
- **Formatting:** Enforced via `flutter format`.
- **State Management:** Reactive programming using GetX. UI widgets should listen to model changes via `Obx` wrappers.
- **Design Tokens:** Styling variables (spacing, fonts, colors) must be referenced from `lib/design_tokens.dart` to maintain UI consistency across platforms.

## Error Handling

### Rust Backend
- Common error types are defined in `libs/hbb_common` and propagated using `Result<T, E>`.
- Log failures using the standard logging facade (`log::info!`, `log::error!`) to print stack/debug trace output in logs rather than crashing the system.
- Use `?` operator to bubble errors up to FFI boundaries.

### Dart Frontend
- Exceptions must be caught and handled with user-friendly alerts or toast notifications (using `bot_toast` or `showToast`).
- Form validations must check requirements inline (e.g. `validator` closures inside `TextFormField` or `serverSettingsTextFormField`).

## FFI Bridge Conventions

Communication between Dart and Rust is strictly structured around the `flutter_rust_bridge` architecture:

1. **Rust FFI Export:** Functions exposed to Dart must be defined inside `src/flutter_ffi.rs`.
2. **Types Mapping:** Complex objects passed through the bridge should be defined in Rust and generated into Dart equivalent models via codegen.
3. **Async Event Streams:** Real-time updates (e.g. active connection list, audio feedback, file transfer progress) should be pushed to Dart using Rust streams/event-sinks rather than Dart polling.
4. **Synchronizing changes:** Whenever signatures in `src/flutter_ffi.rs` are updated, the code generation command must be executed to refresh `src/bridge_generated.rs` and `flutter/lib/generated_bridge.dart`.

---
*Conventions analysis: 2026-06-16*
