# Technical Concerns

**Analysis Date:** 2026-06-16

## Technical Debt & Fragilities

- **FFI Synchronization Overhead:**
  - The FFI bridge (`flutter_rust_bridge`) is a critical point of fragility. Any signature changes in `src/flutter_ffi.rs` must be followed by running the code generator. Failing to run codegen or running mismatched versions results in compiling errors or runtime memory crashes.
- **Git Submodule Drift:**
  - RustDesk relies on local submodules/forks (`hbb_common`, `scrap`, `enigo`, `clipboard`). When fetching or pulling from upstream, commits inside submodules frequently drift, causing merge conflicts or build failures (due to mismatched function signatures in `hbb_common`).
- **Legacy Sciter UI:**
  - The codebase still references `sciter-rs` / `ui.rs` in multiple files, which is a legacy HTML/CSS UI library. This adds complexity to the build environment (requires Sciter SDK libraries) even though the primary UI has migrated to Flutter.

## Security Boundaries

- **Privilege Escalation Risks:**
  - Since the background service (`--service`) runs as `SYSTEM`/`root`, it possesses full control over the OS. Communication between the user UI process and the system service via local IPC (`parity-tokio-ipc`) must be extremely secure. Any parsing vulnerabilities or unauthorized access to the IPC channel could result in local privilege escalation.
- **Encryption Key Validation:**
  - Session security relies on the peer's verification key. Private/public keys must be securely stored, and any bypasses of the key verification dialog (as we saw in `dialog.dart`) must be protected against malicious modification.

## Performance Concerns

- **Stream Rendering Overhead:**
  - Extracting raw video frames, passing them through FFI, and converting them to textures in Flutter (`flutter_texture_rgba_renderer`) creates memory pressure and CPU/GPU overhead. Poor render performance on older clients can lead to frame drops and lag.
- **Real-Time Network Latency:**
  - KCP protocol tuning over UDP is crucial. Network congestion, packet drops, or slow relay fallbacks directly affect the remote control experience.

---
*Concerns analysis: 2026-06-16*
