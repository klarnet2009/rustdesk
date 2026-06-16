# Phase 2: Device Discovery & Heartbeat Audit - Research

**Date:** 2026-06-16

## 1. Heartbeat Mechanism Analysis

### API Endpoint: `/api/heartbeat`
- **Request Format:** JSON POST with fields:
  - `id`: Unique RustDesk Device ID (string)
  - `uuid`: Device UUID (string)
- **Database Action:**
  - Performs an `INSERT OR REPLACE` (upsert) on `devices` table to update `last_seen` to `datetime('now')` and set `online = 1`.
  - Cleans up offline devices: `UPDATE devices SET online = 0 WHERE datetime(last_seen) < datetime('now', '-60 seconds')`.

### API Endpoint: `/api/sysinfo`
- **Request Format:** JSON POST containing full hardware/system metadata:
  - `id`: RustDesk Device ID (string)
  - `uuid`: Device UUID (string)
  - `hostname`: Machine hostname (string)
  - `os`: Operating system name and version (string)
  - `username`: Current user (string)
  - `version`: RustDesk client version (string)
  - `cpu`: CPU name/cores (string)
  - `memory`: Total RAM (string)
  - `ip`: Client IP address (string)
- **Database Action:**
  - Performs an upsert on `devices` to save all fields and set `online = 1` and `last_seen = datetime('now')`.

## 2. Issues & Enhancements

1. **Online/Offline Threshold Mismatch:** The current `/api/heartbeat` cleans up offline devices using a `-60 seconds` window. The target requirement is a `-30 seconds` window.
2. **Stale State in Read Paths:** Offline status updates only run when a device actively sends a heartbeat. If no heartbeats are received (e.g., all clients are closed), the UI and API would continue showing devices as "Online" indefinitely since the database is never updated.
3. **Solution:** Create a helper `update_offline_devices(conn)` to mark devices offline if their last heartbeat was > 30 seconds ago, and run it transparently during every read query (listing, dashboard stats, address book API).
