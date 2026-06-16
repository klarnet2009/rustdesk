---
phase: 3
slug: connection-flow-integration-check
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-06-16
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | python |
| **Quick run command** | `python -c "import sys; sys.path.append('web_panel'); from server import DEVICES_HTML, DASHBOARD_HTML; assert 'rustdesk://connection/new/' in DEVICES_HTML and 'rustdesk://connection/new/' in DASHBOARD_HTML; print('OK')"` |
| **Estimated runtime** | ~0.2 seconds |

## Sampling Rate

- **Before `/gsd-verify-work`:** Assertion and existence validation passes.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | CONN-01 | — | N/A | logic | `python -c "import sys; sys.path.append('web_panel'); from server import DEVICES_HTML, DASHBOARD_HTML; assert 'rustdesk://connection/new/' in DEVICES_HTML and 'rustdesk://connection/new/' in DASHBOARD_HTML; print('OK')"` | ✅ server.py | ⬜ pending |
| 03-01-02 | 01 | 1 | CONN-02 | — | N/A | integration | `python -c "import os; assert os.path.exists('docs/architecture/system-overview.md') and os.path.exists('docs/development/deployment.md'); print('OK')"` | ✅ docs/ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*
