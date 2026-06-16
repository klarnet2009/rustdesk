# Phase 6: Global Configurations & SSO Authentication - Validation Guidelines

## 1. Global Settings Verification
- **Form Submission**: Verify that saving the Global Settings form on the server setting panel updates the `settings` table in `rustdesk.db` under key `global_settings`.
- **Public API Check**: Perform an HTTP GET request to `/api/global-settings` and verify it returns correct JSON payload of options.
- **Client Application Check**: Confirm that client on startup fetches the settings and updates its local configuration.

## 2. Kerberos SSO Verification
- **Negotiate Challenge Check**: Make a request to `/api/login-sso` on the Flask server. Verify it returns `HTTP 401 Unauthorized` with `WWW-Authenticate: Negotiate` header when no credential token is supplied.
- **Negotiate Validate Check**: Make a request to `/api/login-sso` with an invalid token and verify it fails, but compiling does not error.
- **Rust Client FFI Check**: Ensure `main_get_sso_token` compiles without syntax errors on Windows and returns an empty string on other OS.
- **Flutter SSO Fallback Check**: Verify that if SSO endpoint is offline or returns an error, the client UI continues to show standard login.
