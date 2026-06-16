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

### Active

- [ ] **UI-01** — Redesign and migrate the entire Web UI to Tailwind CSS and DaisyUI, replacing custom CSS selectors with modern styling tokens.
- [ ] **MGMT-01** — Implement robust device tracking to ensure all online client devices are reliably registered, active, and listed.
- [ ] **CONN-01** — Verify click-to-connect URI flow (`rustdesk://connection/new/<id>`) works smoothly to launch the client application from the web interface.

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
| Migrate to DaisyUI | Provides premium, pre-built web dashboard widgets (tables, status indicators, statistics cards) using Tailwind. | — Pending |
| SQLite Storage | Lightweight, file-based database requiring zero installation/maintenance for private self-hosted setups. | ✓ Good |

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
