# Requirements: RustDesk Web Management Panel

**Defined:** 2026-06-16
**Core Value:** Provide a central, reliable management portal where administrators can view all managed computers and connect to them with a single click.

## v1 Requirements

Requirements for initial release of the panel improvements.

### User Interface (Tailwind & DaisyUI)

- [ ] **UI-01**: Integrate DaisyUI component library (themes, cards, tables, badges) into `BASE_HTML`.
- [ ] **UI-02**: Redesign Dashboard (`DASHBOARD_HTML`) using DaisyUI stats components (total devices, online devices, active connections).
- [ ] **UI-03**: Redesign Devices Page (`DEVICES_HTML`) using DaisyUI table and status badge components.
- [ ] **UI-04**: Redesign Users Page (`USERS_HTML`) and Logs Page (`LOGS_HTML`) using DaisyUI structures.
- [ ] **UI-05**: Redesign Settings Page (`SETTINGS_HTML`) to support config forms cleanly.
- [ ] **UI-06**: Verify Tailwind CSS build pipeline compiles inputs (`src/input.css`) to optimized static outputs (`static/output.css`).

### Device Management & Discovery

- [ ] **MGMT-01**: Audit client heartbeat endpoint (`/api/heartbeat`) to guarantee reliable background registration of all clients.
- [ ] **MGMT-02**: Ensure device list query calculates online status dynamically based on last seen timestamp (e.g. online = 1 if last_seen within 30s).
- [ ] **MGMT-03**: Add text-based filter/search for devices by ID, Hostname, Username, and Operating System.

### Connection Routing

- [ ] **CONN-01**: Admin can trigger click-to-connect button which opens the `rustdesk://connection/new/<device_id>` URI.
- [ ] **CONN-02**: Verify URI scheme successfully triggers host operating system to launch RustDesk client and establish session.

## v2 Requirements (Deferred)

- **WEB-01**: WebSockets integration for real-time device status and log streaming without polling.
- **GRP-01**: Device grouping and tags for bulk command orchestration or filtering.
- **AUTH-05**: Full Active Directory / LDAP user credential sync.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Multi-tenant Cloud SaaS | Private server hosting is the primary design target. |
| In-browser Screen Viewing | Too complex for v1; native client launcher is sufficient and has native speed. |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| UI-01 | Phase 1 | Pending |
| UI-02 | Phase 1 | Pending |
| UI-03 | Phase 1 | Pending |
| UI-04 | Phase 1 | Pending |
| UI-05 | Phase 1 | Pending |
| UI-06 | Phase 1 | Pending |
| MGMT-01 | Phase 2 | Pending |
| MGMT-02 | Phase 2 | Pending |
| MGMT-03 | Phase 2 | Pending |
| CONN-01 | Phase 2 | Pending |
| CONN-02 | Phase 2 | Pending |

**Coverage:**
- v1 requirements: 11 total
- Mapped to phases: 11
- Unmapped: 0 ✓

---
*Requirements defined: 2026-06-16*
*Last updated: 2026-06-16 after initial definition*
