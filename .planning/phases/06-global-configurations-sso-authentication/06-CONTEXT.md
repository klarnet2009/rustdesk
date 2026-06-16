# Phase 6: Global Configurations & SSO Authentication - Context

**Gathered:** 2026-06-16
**Status:** In Progress (Plan 06-01 completed, Plan 06-02 active)

<domain>
## Phase Boundary

This phase addresses:
1. Centralized global client configuration management: Storing General/Security client options on the Flask server and dynamically propagating them to Windows and Android clients.
2. Active Directory Kerberos Single Sign-On (SSO): Seamless, passwordless desktop login for domain-joined Windows clients using SPNEGO/Negotiate protocol, with co-existence and fallback support for non-domain/local users.

</domain>

<decisions>
## Implementation Decisions

### Centralized Global Settings
- **Three-State Options**: Implemented selects supporting `Not Enforced` (empty value), `Force Enabled` (Y), and `Force Disabled` (N).
- **REST API**: Public `/api/global-settings` endpoint filters out unconfigured options and returns the rest.
- **Client Synchronization**: Client fetches this payload on startup and applies it locally using FFI `bind.mainSetOptions`.

### Kerberos Single Sign-On (SSO)
- **Negotiate Handshake**: Server handles `/api/login-sso` by responding with `401 Unauthorized` and `WWW-Authenticate: Negotiate` header when unauthorized, and validates the returned base64 SPNEGO token.
- **Server Verification**: Uses Python `pyspnego` to authenticate domain credentials against the AD Domain Controller.
- **Client SSPI Integration**: Windows client utilizes Win32 SSPI via Rust FFI (linking to `secur32.dll` and calling `AcquireCredentialsHandle` + `InitializeSecurityContext`) to retrieve the Kerberos service ticket for the server SPN.
- **Fallback Hierarchy**: If SSO fails/is unsupported, the UI falls back to the standard login screen, supporting LDAP bind (credentials-based AD login) and local SQLite credentials.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- FFI wrapper `main_set_options` in `rustdesk/src/flutter_ffi.rs`.
- HTTP client routines in `rustdesk/flutter/lib/models/user_model.dart` and `rustdesk/src/common.rs`.
- Settings SQLite table `settings` in `rustdesk-server/web_panel/server.py`.

### Established Patterns
- `/api/login` and `/api/currentUser` user authentication.
- Access token session management using Bearer JWT.

</code_context>

<specifics>
## Specific Ideas
- Windows client automatically triggers SSO challenge on startup if the API server URL is set.
- SSO can be disabled by policy or configured with a fallback timeout to prevent infinite loops.

</specifics>

<deferred>
## Deferred Ideas
- Cross-platform Kerberos SSO for Linux/macOS clients (out of scope, Windows desktop target is sufficient).

</deferred>
