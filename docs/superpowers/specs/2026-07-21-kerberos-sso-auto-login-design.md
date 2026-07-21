# Kerberos / Domain SSO Auto-Login — Design

- **Date:** 2026-07-21
- **Status:** Approved (brainstorming) — pending spec review
- **Repos touched:** `klarnet2009/rustdesk` (client), `klarnet2009/rustdesk-server` (server/web-panel)
- **Feature branch:** `feat/kerberos-sso` (both repos)

## Problem

Domain-joined Windows machines should log the RustDesk **desktop client** into its account
automatically, using the current Windows domain user (Kerberos), with a silent fallback to
manual login when SSO is unavailable. The **web management panel** should also accept domain
SSO, but grant access to administrators only.

This is **not greenfield**. A prior automated pass (`.planning/phases/06-*`, 2026-06-16) left a
working skeleton:

- Client Rust SSPI token generator `main_get_sso_token` — works, returns a base64 SPNEGO token.
- Client Dart `tryKerberosSso` — already invoked on startup from `refreshCurrentUser`.
- Server endpoint `/api/login-sso` with a `pyspnego` branch.

The skeleton has one **critical security defect** and several gaps (below). The work here is to
**finish and harden**, not rebuild.

### 🔴 Critical defect (closed by this work, task 1)

`pyspnego` is not in `requirements.txt`, so the real Kerberos branch never runs; the live path is
the `except ImportError` fallback that trusts a `TOCKEN_SIMULATION_<username>` string
(`web_panel/server.py:2273`). Any unauthenticated caller can send
`Authorization: Negotiate <base64("TOCKEN_SIMULATION_admin")>` and receive a valid 30-day admin
JWT. This is a full authentication bypass with privilege escalation and is already deployed. It is
removed entirely in this work, with a regression test asserting such tokens are rejected.

## Goals

- Windows domain client: silent, passwordless account login on startup via Kerberos.
- JIT account creation for **all** domain users (client access is for everyone).
- Attribute/role enrichment (email, display name, admin flag) via the existing LDAP integration.
- Web panel: domain SSO **for administrators only**; local `admin` account remains as bootstrap.
- Silent fallback to the existing manual login (LDAP / local) when SSO is unavailable.
- Remove the authentication bypass.

## Non-goals

- Cross-platform client SSO (Linux/macOS/Android). SSPI is Windows-only; other platforms always
  fall back to manual login (the Rust FFI already returns `""` off-Windows).
- NTLM multi-leg negotiation. Only single-leg Kerberos is supported; NTLM attempts fail cleanly to
  manual login.
- Changing the JWT scheme, session model, or the manual `/api/login` / `/login` flows.

## Access model (decisions)

| Aspect | Decision |
| --- | --- |
| Scope | Desktop client **and** web panel |
| Client access | All domain users (JIT), `is_admin` does not gate client login |
| Panel access | Administrators only — session granted iff `is_admin=1` |
| Provisioning | JIT for every authenticated domain user |
| Attributes / role | Enriched via LDAP (email, display_name, groups → `is_admin` per `ldap_admin_groups`) |
| LDAP unavailable | Graceful degradation: minimal JIT, `is_admin=0` (panel SSO then denies; local admin still works) |
| Fallback UX | Unchanged — silent "Login" button; no forced popup |
| Dev bypass | Removed entirely (no `TOCKEN_SIMULATION_`) |

## Architecture

### Data flow — desktop client (`/api/login-sso`)

1. Windows domain client opens → `refreshCurrentUser()` (`user_model.dart:50`). Access token empty
   **and** Windows **and** api-server URL set → `tryKerberosSso(url)` (`user_model.dart:133`).
2. `spn = "HTTP/<api-host>"`; `mainGetSsoToken(spn)` returns a base64 SPNEGO ticket, guarded by a
   **timeout** so a hung SSPI call cannot stall startup.
3. `POST /api/login-sso`, header `Authorization: Negotiate <token>`.
4. Server validates the ticket against the **keytab** via `pyspnego` (no live KDC contact needed —
   the AP-REQ is decrypted with the keytab key), yielding `client_principal` (`user@REALM`).
5. Server resolves the user (LDAP enrichment + JIT), computes `is_admin`.
6. `create_token(user_id, username, is_admin)` → `{access_token, type, user}` — identical shape to
   `/api/login`.
7. Client stores `access_token`, calls `_parseAndUpdateUser`, shows an **i18n** success toast.
   Any failure/empty token → silent fall-through (Login button remains).

### Data flow — web panel (`/login-sso`, browser)

1. Browser requests `/login-sso` → server replies `401 WWW-Authenticate: Negotiate`.
2. Browser configured for the intranet zone (via GPO / `AuthServerAllowlist`) auto-sends the
   Kerberos ticket.
3. Server validates via the same acceptor and resolves the user.
4. **Panel gate:** only if `is_admin=1` → set the signed session cookie
   (`session['user_id'|'username'|'is_admin']`) and redirect to the dashboard. Non-admin → redirect
   to `/login` with an "administrators only" message.
5. Fallback: the standard `/login` form (LDAP / local) is always available.

## Components (isolated, independently testable)

- **`web_panel/sso_kerberos.py`** (new)
  - `validate_negotiate_token(token_b64: str, spn: str) -> str` — turns a Negotiate token into a
    verified principal or raises. Wraps the `pyspnego` acceptor; reads keytab/SPN from config;
    **ignores the `Host` header** (SPN is pinned by config, not client-controllable).
- **`web_panel/ldap_auth.py`** (extend)
  - `ldap_lookup_user(username: str) -> dict | None` — lookup by `sAMAccountName` using the
    **service bind** (no user password). Returns `{email, display_name, groups}`. Reuses the
    existing config helpers. (Today `ldap_auth` only binds with a user password; SSO needs
    password-less lookup.)
- **`web_panel/server.py`** — `resolve_sso_user(principal: str) -> dict`
  - principal → panel user. Derives `username = sAMAccountName` (lowercased). If LDAP enabled:
    `ldap_lookup_user` → compute `is_admin` from groups vs `ldap_admin_groups` → persist via the
    existing `sync_ldap_user_to_db`. Else: minimal JIT (username, `email` synthesized from realm,
    `is_admin=0`). Returns `{user_id, username, is_admin, email, display_name}`. Shared by both
    endpoints.
- **`/api/login-sso`** (rewrite) — thin route: `validate_negotiate_token` → `resolve_sso_user` →
  `create_token` → JSON. **The `TOCKEN_SIMULATION_` branch is deleted.**
- **`/login-sso`** (new) — same validate + resolve, then the **admin gate**, session cookie,
  redirect.
- **Client `tryKerberosSso`** (`user_model.dart:133`) — add a timeout around `mainGetSsoToken`;
  replace the hard-coded Russian toast with `translate(...)`; keep the fallback behavior.

## Provisioning & LDAP enrichment

- Principal → `sAMAccountName` (strip realm, lowercase). `users.username` is the unique key
  (`server.py:116`).
- LDAP enabled → `ldap_lookup_user` fills `email`, `display_name`, `groups`; `is_admin` computed
  from `ldap_admin_groups`; row upserted via `sync_ldap_user_to_db` (`ldap_auth.py:220`).
- LDAP disabled/lookup fails → minimal JIT: `email = "<user>@<realm-domain>"`, `is_admin=0`,
  `display_name=""`. Client SSO still works; panel SSO denies (no admin) — local `admin` covers it.
- Removes the old hard-coded `@domain.local` email and the always-`is_admin=0` behavior.

## Deployment / infrastructure (prerequisites — AD-admin work)

- **SPN:** `setspn -S HTTP/rustdesk.iterum.lv <service-account>`.
- **Keytab:**
  `ktpass /princ HTTP/rustdesk.iterum.lv@<REALM> /mapuser <svc> /crypto AES256-SHA1 /ptype KRB5_NT_PRINCIPAL /pass <pw> /out rustdesk.keytab`.
- Mount the keytab into the container as a Coolify secret; set `KRB5_KTNAME=/etc/rustdesk.keytab`.
- Provide `/etc/krb5.conf` with `[realms] <REALM> = { kdc = <dc-host> }` and a `domain_realm`
  mapping (baked into the image or mounted).
- **Dockerfile:** `apt-get install -y --no-install-recommends gcc libkrb5-dev krb5-user`.
- **requirements.txt:** add `pyspnego[kerberos]`.
- **Panel browser SSO:** add `rustdesk.iterum.lv` to the intranet zone / `AuthServerAllowlist` via
  GPO so Edge/Chrome/Firefox send the ticket.
- The SPN host must match the client's request (`HTTP/rustdesk.iterum.lv`). Domain clients on the
  LAN reach the KDC to obtain tickets; the server needs only the keytab.

## Security considerations

- Delete the `TOCKEN_SIMULATION_` bypass (task 1) + regression test that such a token is rejected.
- SPN/hostname come from config, never from the `Host` header.
- Confirm `verify_password` never authenticates an empty/absent password (JIT SSO rows have
  `password=''`), so those rows cannot be used via `/api/login`.
- JWT unchanged (HS256, 30-day). Panel SSO honors existing cookie flags (`HttpOnly`, `SameSite`,
  `Secure`).
- Change the default `admin/admin123` (adjacent hardening; tracked, not blocking).

## Testing strategy

- **Server unit:** `validate_negotiate_token` with a mocked `pyspnego` acceptor
  (complete / incomplete / invalid); `resolve_sso_user` with mocked LDAP (found / not-found /
  admin-group / LDAP-down); `/api/login-sso` returns correct JSON, issues the 401 Negotiate
  challenge, and **rejects `TOCKEN_SIMULATION_`**; `/login-sso` admin gate (admin → session,
  non-admin → redirect).
- **Client:** `tryKerberosSso` — empty token → no-op; 200 → user set; error → fall-through;
  timeout honored.
- **Rust:** existing `sspi_tests` still compile (empty off-Windows, no panic on Windows).
- **Manual E2E:** domain machine → client auto-login + admin panel SSO; off-domain → Login button,
  local admin panel login.

## Implementation waves

1. **Server core + hotfix** — remove bypass; `sso_kerberos.py`; `ldap_lookup_user`;
   `resolve_sso_user`; rewrite `/api/login-sso`; unit tests. (Closes the vuln first.)
2. **Deployment/infra** — Dockerfile deps; `requirements.txt`; `krb5.conf`/keytab wiring; Coolify
   env/secrets. (Needs the AD-admin prerequisites.)
3. **Client polish** — timeout guard + i18n in `tryKerberosSso`.
4. **Panel browser SSO** — `/login-sso` route + admin gate; GPO note. (Heaviest; depends on browser
   IWA config.)

## Open prerequisites to confirm

- Is LDAP already configured on the panel (`ldap_*` settings)? Enrichment and SSO-derived admin
  depend on it; local `admin` is the bootstrap otherwise.
- AD realm name, KDC/DC host, and the service account for the SPN/keytab.

## Change map (from reconnaissance)

| Concern | Location |
| --- | --- |
| Rust SSPI token | `rustdesk/src/flutter_ffi.rs:1073,1162` |
| Client SSO caller | `rustdesk/flutter/lib/models/user_model.dart:133` |
| Startup auto-login hook | `rustdesk/flutter/lib/models/user_model.dart:60` |
| Hard-coded toast (→ i18n) | `rustdesk/flutter/lib/models/user_model.dart:173` |
| SSO endpoint (rewrite) | `rustdesk-server/web_panel/server.py:2214` |
| Bypass to remove | `rustdesk-server/web_panel/server.py:2273` |
| JWT create/verify | `rustdesk-server/web_panel/server.py:312,320` |
| Panel login (add gate) | `rustdesk-server/web_panel/server.py:1757` |
| API login (shape parity) | `rustdesk-server/web_panel/server.py:2317` |
| LDAP JIT / enrichment | `rustdesk-server/web_panel/ldap_auth.py:220` |
| requirements / Dockerfile | `rustdesk-server/web_panel/requirements.txt`, `Dockerfile` |
