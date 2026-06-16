# Roadmap: RustDesk Web Management Panel

## Overview

This roadmap defines the path to overhaul the RustDesk Web Management Panel UI using Tailwind CSS and DaisyUI, resolve device discovery/heartbeat issues, and verify remote connection launcher flows.

## Phases

- [ ] **Phase 1: Tailwind & DaisyUI UI Migration** - Redesign dashboard and all administration views using DaisyUI.
- [ ] **Phase 2: Device Discovery & Heartbeat Audit** - Audit and fix device list/heartbeat APIs to ensure all online client devices are reliably registered.
- [ ] **Phase 3: Connection flow & Integration check** - Integrate client-side launcher scheme and document configuration.

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
- [ ] 01-01: Setup Tailwind compile scripts and integrate DaisyUI with `BASE_HTML`.
- [ ] 01-02: Migrate Dashboard and Devices pages to DaisyUI.
- [ ] 01-03: Migrate Users, Logs, and Settings pages to DaisyUI.

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
- [ ] 02-01: Audit `/api/heartbeat` logic and SQLite schema triggers.
- [ ] 02-02: Implement device list search filter in UI and backend.

### Phase 3: Connection flow & Integration check
**Goal**: Verify the admin's click-to-connect actions seamlessly trigger the local RustDesk client application using the custom URI scheme.
**Depends on**: Phase 2
**Requirements**: CONN-01, CONN-02
**Success Criteria**:
  1. Clicking the connection button on the web panel correctly resolves the URI schema `rustdesk://connection/new/<device_id>`.
  2. Document the RustDesk client config setting instructions for users.
**Plans**: 1 plan

Plans:
- [ ] 03-01: Connect button integration and user documentation.

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Tailwind & DaisyUI UI Migration | 0/3 | Not started | - |
| 2. Device Discovery & Heartbeat Audit | 0/2 | Not started | - |
| 3. Connection flow & Integration check | 0/1 | Not started | - |

---
*Roadmap defined: 2026-06-16*
*Last updated: 2026-06-16 after initial definition*
