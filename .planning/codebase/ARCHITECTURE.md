# Architecture

**Analysis Date:** 2026-06-16

## System Overview

RustDesk is built on a split architecture consisting of a Flutter frontend for UI rendering and a Rust backend for high-performance screen capture, encoding, and network transport.

```
┌──────────────────────────────────────────────────┐
│                  Flutter UI                      │
└────────────────────────┬─────────────────────────┘
                         │ (FFI Bridge)
┌────────────────────────▼─────────────────────────┐
│               Rust FFI (flutter.rs)              │
└────────────────────────┬─────────────────────────┘
                         │ (tokio channel)
┌────────────────────────▼─────────────────────────┐
│         Rust Engine (core_main.rs, server.rs)    │
└───────────┬────────────────────────────┬─────────┘
            │                            │
┌───────────▼───────────┐    ┌───────────▼─────────┐
│   libs/scrap (Capture)│    │ libs/enigo (Input)  │
└───────────────────────┘    └─────────────────────┘
```

## Client-Service Split

To support remote desktop capture and input simulation even on login screen/UAC elevation blocks, the application splits duties between two processes (primarily on Windows and Linux):

1. **System Service (`rustdesk.exe --service`):**
   - Runs with elevated privileges (e.g. `NT AUTHORITY\SYSTEM` on Windows, `root` on Linux).
   - Responsible for launching the capture loops, simulating clipboard actions, and executing inputs.
   - Listens on a local IPC port (via `parity-tokio-ipc`) for connections from user sessions.
2. **User Client / UI (`rustdesk.exe`):**
   - Runs in the user's active session.
   - Renders the desktop window, configuration panels, and address book.
   - Communicates with the service process via IPC to send input events and receive status updates.

## Core Layers

- **Flutter UI Layer (`flutter/lib/`):**
  - Cross-platform presentation code. Handles settings screens, navigation using GetX, and window creation on desktop (via `desktop_multi_window`).
- **FFI Bridge (`flutter_rust_bridge`):**
  - Generated FFI layer (`bridge_generated.rs` and `generated_bridge.dart`). Translates asynchronous Dart futures and streams into native C/Rust calls, and routes backend events back to Flutter.
- **Rust Engine Layer (`src/`):**
  - Handles the heavy lifting: video encoding/decoding, connection states, encryption keys validation, and network packet serialization.
  - Asynchronous execution managed by the `tokio` thread pool.
- **Platform Layer (`src/platform/`):**
  - Low-level wrappers for Windows, macOS, Linux, Android, and iOS to access system capture, power management, registry, and OS notifications.

## Primary Data Flows

### Video/Audio Flow
1. **Capture:** The host's screen is continuously captured by `libs/scrap` yielding raw RGB/YUV frames.
2. **Encoding:** Frames are compressed using either hardware acceleration (`hwcodec`) or software codecs (VP8/VP9/AV1/H264/H265).
3. **Transport:** Encoded video packets are fragmented and transmitted to the peer using UDP (via `KCP` protocol) or TCP relay.
4. **Decoding & Render:** The client receives the packets, decodes them, and feeds the raw frame texture to Flutter's custom texture renderer (`flutter_texture_rgba_renderer`).

### Input Event Flow
1. **Capture:** The remote user's mouse/keyboard inputs are captured by Flutter widgets.
2. **FFI Send:** Events are serialized and passed through the FFI bridge to the Rust client thread.
3. **Network Send:** The client wraps the events in custom protobuf packets and sends them to the host server.
4. **Execution:** The host service receives the packets, translates keycodes to platform-specific events, and injects them via `libs/enigo` or `rdev` into the system.

## Key Abstractions

- `ServerConfig` (`libs/hbb_common/src/config.rs`) — Represents all persistent settings (ID, relay, encryption key, etc.).
- `RendezvousMediator` (`src/rendezvous_mediator.rs`) — Manages the lifecycle of connection negotiation, NAT traversal (hole punching), and keep-alive signals to `hbbs`.
- `Connection` (`src/server/connection.rs`) — Represents an active remote session, holding state for screen sharing, file transfer, audio, and clipboard pipes.

---
*Architecture analysis: 2026-06-16*
