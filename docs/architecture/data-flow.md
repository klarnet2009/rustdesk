# Data Flow Documentation

## 1. Heartbeat Telemetry Pipeline
1. **Trigger:** RustDesk client pings the server at configured intervals (default: 30 seconds).
2. **Endpoint:** Client invokes HTTP POST `/api/heartbeat`.
3. **Database Write:** Server performs an UPSERT on the `devices` table:
   ```sql
   INSERT INTO devices (id, uuid, online, last_seen) VALUES (?, ?, 1, datetime('now'))
   ON CONFLICT(id) DO UPDATE SET uuid = excluded.uuid, online = 1, last_seen = datetime('now')
   ```
4. **Housekeeping:** Stale status triggers update devices whose last seen time is > 30 seconds ago to offline status (`online = 0`).

## 2. Admin Request Pipeline
1. **Trigger:** Administrator visits the dashboard `/dashboard` or `/devices`.
2. **Database Read:**
   - Execute the offline devices check.
   - Retrieve all devices sorted by last seen timestamp.
   - Fetch total device counters and active user lists.
3. **Jinja2 Rendering:** Inject rows into HTML layouts and serve compile page to the browser.
4. **DataTables Filtering:** Client-side DataTable parses the DOM table and filters records by search inputs.

## 3. Session Authentication
1. **Login:** Administrator enters username and password.
2. **Verification:** System checks bcrypt/sha256 hash or tests bind on LDAP server.
3. **Token:** On success, a JWT token is created and persisted in browser cookie/session storage.
