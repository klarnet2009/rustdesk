# Roadmap: RustDesk Web Management Panel

## Overview

This roadmap defines the path to overhaul the RustDesk Web Management Panel UI using Tailwind CSS and DaisyUI, resolve device discovery/heartbeat issues, and verify remote connection launcher flows.

## Phases

- [x] **Phase 1: Tailwind & DaisyUI UI Migration** - Redesign dashboard and all administration views using DaisyUI.
- [x] **Phase 2: Device Discovery & Heartbeat Audit** - Audit and fix device list/heartbeat APIs to ensure all online client devices are reliably registered.
- [x] **Phase 3: Connection flow & Integration check** - Integrate client-side launcher scheme and document configuration.
- [x] **Phase 4: Passwordless Connection & Same-Account Login** - Implement auto-association, address book tagging, same-account host authorization, and client password prompt bypass.

## Phase Details

### Phase 1: Tailwind & DaisyUI UI Migration
**Goal**: Overhaul the visual interface of the Web Management Panel to use DaisyUI component themes, widgets, and modern styling.
**Depends on**: Nothing (first phase)
**Requirements**: UI-01, UI-02, UI-03, UI-04, UI-05, UI-06
**Success Criteria**:
  1. Tailwind compiler compiles input styles into `static/output.css` without errors.
  2. The Login, Dashboard, Devices, Users, and Logs pages render using DaisyUI components (alert cards, tables, progress indicators, themes).
  3. No custom style overlaps remain.
**Plans**: 3 plans

Plans:
- [x] 01-01: Setup Tailwind compile scripts and integrate DaisyUI with `BASE_HTML`.
- [x] 01-02: Migrate Dashboard and Devices pages to DaisyUI.
- [x] 01-03: Migrate Users, Logs, and Settings pages to DaisyUI.

### Phase 2: Device Discovery & Heartbeat Audit
**Goal**: Ensure all remote client devices reliably report their heartbeat and appear in the admin panel listing.
**Depends on**: Phase 1
**Requirements**: MGMT-01, MGMT-02, MGMT-03
**Success Criteria**:
  1. Devices sending `/api/heartbeat` are registered in `rustdesk.db` SQLite database.
  2. Devices whose last heartbeat was within the last 30 seconds show as "Online" (green badge) in the UI.
  3. Devices can be filtered by hostname, username, and OS via search input.
**Plans**: 2 plans

Plans:
- [x] 02-01: Audit `/api/heartbeat` logic and SQLite schema triggers.
- [x] 02-02: Implement device list search filter in UI and backend.

### Phase 3: Connection flow & Integration check
**Goal**: Verify the admin's click-to-connect actions seamlessly trigger the local RustDesk client application using the custom URI scheme.
**Depends on**: Phase 2
**Requirements**: CONN-01, CONN-02
**Success Criteria**:
  1. Clicking the connection button on the web panel correctly resolves the URI schema `rustdesk://connection/new/<device_id>`.
  2. Document the RustDesk client config setting instructions for users.
**Plans**: 1 plan

Plans:
- [x] 03-01: Connect button integration and user documentation.

### Phase 4: Passwordless Connection & Same-Account Login
**Goal**: Implement passwordless connection for client devices logged into the same account, with automatic device association and client-side password prompt bypass.
**Depends on**: Phase 3
**Requirements**: ACCT-01, ACCT-02
**Success Criteria**:
  1. Login and currentUser API calls automatically link client device IDs to the user account in the SQLite database.
  2. The server's currentUser endpoint returns the required verifier field to enable client login.
  3. The server's address book endpoint merges owned devices and tags them with the 'same-account' tag.
  4. The client's connection manager detects the 'same-account' tag and bypasses the password entry dialog, successfully connecting passwordlessly via same-account token verification.
**Plans**: 1 plan

Plans:
- [x] 04-01: Implement auto-association, address book tagging, same-account host authorization, and client password prompt bypass.

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Tailwind & DaisyUI UI Migration | 3/3 | Completed | 2026-06-16 |
| 2. Device Discovery & Heartbeat Audit | 2/2 | Completed | 2026-06-16 |
| 3. Connection flow & Integration check | 1/1 | Completed | 2026-06-16 |
| 4. Passwordless Connection & Same-Account Login | 1/1 | Completed | 2026-06-16 |

---
*Roadmap defined: 2026-06-16*
*Last updated: 2026-06-16 after initial definition*
