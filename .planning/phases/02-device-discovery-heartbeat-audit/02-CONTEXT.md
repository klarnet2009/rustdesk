# Phase 2: Device Discovery & Heartbeat Audit - Context

**Gathered:** 2026-06-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Audit and fix client device discovery and background heartbeat endpoints. Ensure all online client devices are reliably registered in the `devices` table in `rustdesk.db` and shown with correct online/offline statuses in the UI based on a 30-second window. Implement a client-side or server-side filtering mechanism to search devices by hostname, username, and OS.

</domain>

<decisions>
## Implementation Decisions

### Heartbeat & Status Tracking
- **Online Threshold:** Devices whose `last_seen` timestamp is within the last 30 seconds are considered online.
- **Stale Device Cleanup:** Automatically update `online = 0` for any devices whose `last_seen` timestamp is older than 30 seconds.
- **Registration on Heartbeat:** `/api/heartbeat` should ensure the device exists in the database and updates `last_seen` and `online = 1`.
- **System Information Sync:** `/api/sysinfo` updates full metadata (OS, hostname, username, CPU, memory, version) and sets `online = 1` and `last_seen = datetime('now')`.
- **Consistency:** Ensure online status is evaluated/refreshed during read paths (like dashboard loading, devices listing, and API devices calls) to prevent stale online states.

### Device Search/Filtering
- Use the DataTables search input to filter devices dynamically by Hostname, Username, and OS on the devices list page.
- Ensure the OS column and Hostname columns are fully indexed/searchable in the table.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `get_devices_list()` in `web_panel/server.py` which retrieves all devices from the database.
- `/api/heartbeat` and `/api/sysinfo` endpoints in `web_panel/server.py` which receive pings and metadata from client devices.

### Established Patterns
- SQLite `datetime('now')` is used to record last seen times in UTC.
- HTML views use Jinja2 to render status badges and details.

</code_context>

<specifics>
## Specific Ideas

- Run cleanup check on every devices list/dashboard request to ensure accurate status representation.

</specifics>

<deferred>
## Deferred Ideas

None.

</deferred>
