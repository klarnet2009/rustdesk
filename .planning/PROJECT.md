# RustDesk Web Management Panel

## What This Is

A web-based administration panel for RustDesk server and client networks, designed to help system administrators track online/offline status, view system metrics, and initiate remote control sessions for all registered client devices. The interface is built using Python (Flask) on the backend and Tailwind CSS + DaisyUI on the frontend.

## Core Value

Provide a central, reliable management portal where administrators can view all managed computers and connect to them with a single click, eliminating the need to request IDs manually from remote users.

## Requirements

### Validated

- ✓ **INIT-01** — Basic Flask backend with SQLite storage initialized (`web_panel/server.py`).
- ✓ **INIT-02** — Base HTTP endpoints for heartbeat reception, device registration, and audit logs.
- ✓ **INIT-03** — JWT authentication helper and base HTML template routing.
- ✓ **UI-01** — Redesign and migrate the entire Web UI to Tailwind CSS and DaisyUI (v1.0).
- ✓ **MGMT-01** — Implement robust device tracking and heartbeat audit (v1.0).
- ✓ **CONN-01** — Click-to-connect URI flow integration (v1.0).
- ✓ **ACCT-01** — Same-account passwordless remote connections & auto-association (v2.0).

### Active

- [ ] **LDAP-01** — Implement configurable multi-group mapping to local user roles in LDAP settings.
- [ ] **LDAP-02** — Add on-demand LDAP user synchronization button and background sync scheduler in the admin panel.
- [ ] **LDAP-03** — Implement a robust fallback local authentication path to prevent lockout if the LDAP server is offline.

### Out of Scope

- **CLOUD-01** — Native SaaS multi-tenant cloud hosting (defer to future, local/private network server deployment is sufficient).
- **MOB-01** — Dedicated mobile application for the panel (responsive browser-based web view is sufficient for mobile browsers).

## Context

- The admin panel was initialized in `web_panel/` containing Flask code (`server.py`), package definitions (`package.json`), and SQLite storage (`rustdesk.db`).
- Users report that client devices do not always appear in the search, making it necessary to manually ask for connection IDs. Heartbeat handling and API endpoints must be audited to ensure reliable discovery.

## Constraints

- **Tech stack**: Flask (Python 3), JWT, SQLite, Tailwind CSS, DaisyUI.
- **Protocol**: Needs to stay fully compatible with standard RustDesk client heartbeat/API specifications.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Migrate to DaisyUI | Provides premium, pre-built web dashboard widgets (tables, status indicators, statistics cards) using Tailwind. | ✓ Completed |
| SQLite Storage | Lightweight, file-based database requiring zero installation/maintenance for private self-hosted setups. | ✓ Good |
| Same-Account Passwordless Auth | Automates remote session authorization using client access token verification and client-side passwordless tag check. | ✓ Implemented |
| Unified LDAP Authentication | Intercepts client logins via `/api/login` and `/api/currentUser` to authenticate Active Directory domain users on the client. | ✓ Implemented |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition:**
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone:**
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-16 after initial project definition*
