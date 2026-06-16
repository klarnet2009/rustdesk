# Phase 1: Tailwind & DaisyUI UI Migration - Pattern Map

**Mapped:** 2026-06-16
**Files analyzed:** 4
**Analogs found:** 4 / 4

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `web_panel/server.py` | controller / views | request-response | `web_panel/server.py` | exact (in-place refactor) |
| `web_panel/package.json` | config | config | `web_panel/package.json` | exact |
| `web_panel/tailwind.config.js` | config | config | `web_panel/tailwind.config.js` | exact |
| `web_panel/src/input.css` | styles | transform | `web_panel/src/input.css` | exact |

## Pattern Assignments

### `web_panel/server.py` (controller / views, request-response)

**Analog:** `web_panel/server.py` (in-place)
- **Imports pattern:** standard Python Flask and SQLite libraries.
- **Auth pattern:** JWT helper check (`login_required` decorator).
- **Core view pattern:** Return HTML templates defined as Python string variables.

### `web_panel/src/input.css` (styles, transform)

**Analog:** `web_panel/src/input.css`
- **Tailwind base directives:** `@tailwind base; @tailwind components; @tailwind utilities;`
- **Custom utility overrides:** `@apply` classes inside `@layer components` for styling specific widgets.

## Shared Patterns

### Jinja2 Templating
All frontend HTML pages are defined as Python strings (e.g., `BASE_HTML`, `DASHBOARD_HTML`, `DEVICES_HTML`) inside `web_panel/server.py`. They share the common base template inheritance (`{% extends "base" %}`).

### DaisyUI Component Classes
We will use cohesive DaisyUI components (`stats` for stats grids, `table` for tabular data, `badge` for online status, and `drawer` for sidebar layouts) across all pages to achieve visual consistency.
