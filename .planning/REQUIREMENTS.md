# Requirements: RustDesk Web Management Panel

**Defined:** 2026-06-16
**Last Updated:** 2026-06-16 (Milestone v3.0)
**Core Value:** Provide a central, reliable management portal where administrators can view all managed computers and connect to them with a single click.

## Validated Requirements (Completed)

### User Interface (Tailwind & DaisyUI) - v1.0
- ✓ **UI-01**: Integrate DaisyUI component library (themes, cards, tables, badges) into `BASE_HTML`.
- ✓ **UI-02**: Redesign Dashboard using DaisyUI stats components.
- ✓ **UI-03**: Redesign Devices Page using DaisyUI table and status badge components.
- ✓ **UI-04**: Redesign Users Page and Logs Page using DaisyUI structures.
- ✓ **UI-05**: Redesign Settings Page to support config forms cleanly.
- ✓ **UI-06**: Verify Tailwind CSS build pipeline compiles inputs (`src/input.css`) to optimized static outputs (`static/output.css`).

### Device Management & Discovery - v1.0
- ✓ **MGMT-01**: Audit client heartbeat endpoint (`/api/heartbeat`) to guarantee reliable background registration.
- ✓ **MGMT-02**: Ensure device list query calculates online status dynamically based on last seen timestamp.
- ✓ **MGMT-03**: Add text-based filter/search for devices by ID, Hostname, Username, and Operating System.

### Connection Routing - v1.0
- ✓ **CONN-01**: Admin can trigger click-to-connect button which opens the `rustdesk://connection/new/<device_id>` URI.
- ✓ **CONN-02**: Verify URI scheme successfully triggers host operating system to launch RustDesk client.

### Passwordless Connection - v2.0
- ✓ **ACCT-01**: Same-account remote connection passwordless handshake authentication on Windows and Android.
- ✓ **ACCT-02**: Automatic mapping of device ID and UUID to the logged-in user on login/currentUser API calls.

## Active Requirements (v3.0 - LDAP Enhancements)

- [ ] **LDAP-01**: Implement configurable group-to-role mappings in Settings (e.g. AD group `Domain Admins` maps to Admin role, others map to User role).
- [ ] **LDAP-02**: Implement manual "Sync Users" action button in the Web Panel interface.
- [ ] **LDAP-03**: Implement automated background LDAP user sync scheduler (cron/interval task).
- [ ] **LDAP-04**: Implement fallback local administrator credentials validation pathway to prevent lockout.

## Deferred/Out of Scope Requirements

- **WEB-01**: WebSockets integration for real-time device status and log streaming without polling.
- **GRP-01**: Device grouping and tags for bulk command orchestration or filtering.
- **CLOUD-01**: Multi-tenant Cloud SaaS (Private server hosting is the primary design target).
- **MOB-01**: Dedicated mobile application for the panel (responsive browser-based web view is sufficient).

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| UI-01 to 06 | Phase 1 | Validated |
| MGMT-01 to 03 | Phase 2 | Validated |
| CONN-01 to 02 | Phase 3 | Validated |
| ACCT-01 to 02 | Phase 4 | Validated |
| LDAP-01 | Phase 5 | Pending |
| LDAP-02 | Phase 5 | Pending |
| LDAP-03 | Phase 5 | Pending |
| LDAP-04 | Phase 5 | Pending |

---
*Requirements updated: 2026-06-16 for Milestone v3.0*
