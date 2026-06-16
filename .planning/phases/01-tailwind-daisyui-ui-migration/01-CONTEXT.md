# Phase 1: Tailwind & DaisyUI UI Migration - Context

**Gathered:** 2026-06-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Overhaul the visual interface of the Web Management Panel to use DaisyUI component themes, widgets, and modern styling. This includes rewriting the inline HTML templates (`BASE_HTML`, `LOGIN_HTML`, `DASHBOARD_HTML`, `DEVICES_HTML`, `USERS_HTML`, `LOGS_HTML`, `SETTINGS_HTML`) in `web_panel/server.py` to use DaisyUI structures, updating `input.css`, and verifying that the Tailwind compile workflow generates a working `static/output.css`.

</domain>

<decisions>
## Implementation Decisions

### Theme & Visual Styling
- Default theme: `corporate` (light) / `business` (dark) themes for a clean, professional admin console look.
- Theme switching: Dynamic theme switching supported via a header button.
- Accent colors: Custom RustDesk brand colors (orange/blue) mapped to primary/accent Tailwind theme configurations.
- Persistence: Persist theme preferences in client-side `localStorage`.

### Dashboard Layout & Widgets
- Sidebar: Fixed left sidebar using a drawer layout, collapsible on mobile screens.
- Stats display: DaisyUI `stats` component with colored icons, large text values, and clear labels.
- Charts: Interactive Chart.js graphs for connection history (7 days) and OS distribution.
- Automatic refresh: AJAX polling every 30 seconds for live data updates.

### Device Listing & Connection Actions
- List layout: DaisyUI table with DataTables integration for sorting, search, and pagination.
- Status badges: Dynamic DaisyUI badges (`badge-success` / `badge-ghost`) with a pulsing green dot for online status.
- Connect placement: One-click "Connect" button directly inside the "Actions" column in the table.
- Available actions: "Connect" (launches `rustdesk://connection/new/<id>`) and "Details" (opens metadata modal showing CPU, Memory, version details).

### the agent's Discretion
None - all decisions have been explicitly accepted.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Existing scripts and packages defined in `web_panel/package.json` (Tailwind CSS, DaisyUI, PostCSS, Autoprefixer).
- Existing layout styling classes inside `web_panel/src/input.css` using `@apply`.

### Established Patterns
- Inline Flask HTML templates (`BASE_HTML` etc.) with Jinja2 rendering.
- Client-side script handling theme toggling and chart rendering with JQuery, DataTables, and Chart.js.

### Integration Points
- `web_panel/server.py` where HTML strings are served and routes are defined.
- `web_panel/tailwind.config.js` for styling custom theme settings and classes.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>
