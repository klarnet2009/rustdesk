---
phase: 06-global-configurations-sso-authentication
plan: 02
subsystem: client-server
tags:
  - kerberos
  - sso
  - sspi
  - negotiation
  - active-directory
provides:
  - FFI main_get_sso_token for Windows client SSPI token acquisition
  - Server SSO endpoint /api/login-sso validating Negotiate tokens
  - Client tryKerberosSso login flow with AD automatic entry and local/credentials fallback
affects: []
tech-stack:
  added:
    - pyspnego
  patterns:
    - sspi
    - negotiate
    - fallback-auth
key-files:
  created: []
  modified:
    - rustdesk-server/web_panel/server.py
    - rustdesk/flutter/lib/models/user_model.dart
    - rustdesk/src/flutter_ffi.rs
key-decisions:
  - Expose /api/login-sso endpoint handling WWW-Authenticate Negotiate challenge
  - Support fallback simulation token starting with TOCKEN_SIMULATION_ for developer testing
  - Client automatically calls SSPI via secur32.dll dynamically on Windows and falls back to standard login screen if SSO fails
duration: 15min
completed: 2026-06-16
status: complete
---

# Phase 6: Global Configurations & SSO Authentication - Plan 02 Summary

**Kerberos Single Sign-On (SSO) login flow is successfully implemented for domain-joined Windows desktop clients, supporting full SPNEGO validation and parallel credentials fallback.**

## Performance
- **Duration:** 15 minutes
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- **Server Negotiate Validator**: Created the `/api/login-sso` endpoint in `server.py` that challenges clients with `Negotiate` headers and validates Kerberos/SPNEGO tokens using `pyspnego`. Added a `TOCKEN_SIMULATION_` prefix fallback for local development environments.
- **Client Rust SSPI integration**: Defined self-contained `secur32` Win32 SSPI library bindings in `flutter_ffi.rs` to dynamically call `AcquireCredentialsHandleW` and `InitializeSecurityContextW` on Windows, fetching Kerberos tickets for target server SPNs.
- **Flutter SSO login Flow**: Updated the Dart `UserModel` to invoke `tryKerberosSso` on startup when on Windows. If FFI returns a valid ticket, it logs the user in automatically and displays a Russian-language success toast; otherwise, it falls back to standard credentials form.

## Next Phase Readiness
Milestone v4.0 is fully implemented and tested! Proceeding to milestone completion audit.
