# Phase 2: Device Discovery & Heartbeat Audit - Pattern Map

**Mapped:** 2026-06-16
**Files analyzed:** 1
**Analogs found:** 1 / 1

## File Classification

| Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---------------|------|-----------|----------------|---------------|
| `web_panel/server.py` | controller / views | database-request-response | `web_panel/server.py` | exact |

## Pattern Assignments

### `web_panel/server.py` (controller / views, database-request-response)
- **Database transaction pattern:** Obtain `get_db()`, execute query, commit, and close connection.
- **Timestamp pattern:** Use `datetime('now')` in SQLite queries to record events in UTC format.
- **Search input pattern:** Read parameter `search` from Flask request (`request.args.get('search')`) and pass it down.
