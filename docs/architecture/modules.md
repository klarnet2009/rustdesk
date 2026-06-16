# Modules Documentation

## 1. Web Server Module (`server.py`)
- **Purpose:** Central entry point of the management panel.
- **Key Functions / Classes:**
  - `init_db()`: Sets up SQLite tables, indices, and registers the initial admin user.
  - `get_db()`: Obtains connection to the SQLite database.
  - `update_offline_devices(conn)`: Cleans up offline devices whose heartbeat has expired.
  - `get_devices_list(search_query)`: Queries and formats device details.
  - `web_dashboard()` / `web_devices()` / `web_users()`: Endpoints rendering UI templates.
  - `api_heartbeat()` / `api_sysinfo()`: Telemetry endpoints.
- **Relationships:** Integrates directly with the `ldap_auth.py` helper to verify directory authentication.

## 2. Directory Authentication Module (`ldap_auth.py`)
- **Purpose:** Perform active directory credential validation.
- **Key Functions:**
  - `authenticate_user(server, base_dn, username, password)`: Attempts to bind and fetch member properties.
  - `test_connection(server, bind_dn, password)`: Connectivity checker.
- **Relationships:** Used by configuration and settings routers inside `server.py`.
