# Integrations

**Analysis Date:** 2026-06-16

## Rendezvous & Relay Protocol

**Purpose:** Coordinates peer-to-peer signalling and connection relays when direct paths are blocked.

**Details:**
- **Rendezvous Server (`hbbs`):** Clients connect via custom protobuf packets (TCP/UDP port 21116) to register their unique ID, report online status, and request peer IP addresses.
- **Relay Server (`hbbr`):** When direct P2P connection via UDP hole punching fails, the connection falls back to a relay server on TCP port 21117.
- **P2P Signalling:** Direct UDP punch-through is implemented in `src/rendezvous_mediator.rs`. It negotiates NAT traversal to establish low-latency remote control sessions.

## HTTP REST APIs

**Purpose:** User authentication, device registration, and address book sharing.

**APIs:**
- **Account Service:** Integrates with the RustDesk API server (or custom self-hosted API servers via `api_server.py`). Handles user login, registration, 2FA (`src/auth_2fa.rs`), and address book sync.
- **HTTP client:** Implemented using `reqwest` in Rust and standard `http` package in Flutter (`flutter/lib/common.dart`).

## Operating System APIs

**Purpose:** Desktop capture, audio capture, event injection, clipboard sharing, and service elevation.

**Platform Details:**
- **Windows:**
  - Screen capture using `DXGI Desktop Duplication API` (via `scrap`).
  - Input injection via `SendInput` API (Windows SDK hooks).
  - Registry key reading/writing for settings persistence.
  - Windows service wrapper (`src/service.rs`) running as `NT AUTHORITY\SYSTEM` to bypass User Account Control (UAC) prompts.
  - Clipboard sharing: native Win32 clipboard API (via `libs/clipboard`).
- **macOS:**
  - Screen capture using `ScreenCaptureKit` / `AVFoundation`.
  - Input injection using macOS Accessibility API (`CGEventPost`).
- **Linux:**
  - Desktop capture via X11 API or Wayland portals (using PipeWire via `scrap`).
  - Input injection via `uinput` or XTest extension.
- **Mobile (Android/iOS):**
  - Native Screen MediaProjection API for capture.
  - Custom AccessibilityService on Android for touch event injection.

## Submodules

**Purpose:** Decouples core remote desktop utilities into isolated, reusable libraries.

**Dependencies:**
- `libs/hbb_common` — Shared encryption wrappers (Sodium/XChaCha20), protocol buffer message definitions, configuration models.
- `libs/scrap` — Low-level screen grabber abstraction across Windows, macOS, and Linux.
- `libs/enigo` — Input simulation crate for simulating mouse clicks and key presses.
- `libs/clipboard` — Fork of clipboard handling library customized for remote file copy-paste and text sync.

---
*Integrations analysis: 2026-06-16*
