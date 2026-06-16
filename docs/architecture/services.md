# Services Documentation

## 1. Web Management Service
- **Purpose:** Serve the administrative control panel to authorized web users.
- **Responsibilities:**
  - Render user, device, logs, and settings templates.
  - Handle admin login, logout, and session lifecycle.
- **Dependencies:**
  - Flask web server.
  - SQLite database connections.

## 2. API Handler Service
- **Purpose:** Process incoming client telemetry and heartbeats.
- **Responsibilities:**
  - Receive post payloads containing hostname, CPU/RAM specs, OS versions, and IP addresses.
  - Update last seen timestamps and status indicators for remote hosts.
- **APIs Exposed:**
  - `/api/heartbeat` (Device heartbeat checks)
  - `/api/sysinfo` (Full hardware metadata synchronization)
  - `/api/sysinfo_ver` (Client query helper)
  - `/api/audit/<typ>` (Audit logs dispatcher)
  - `/api/admin/devices` (Device query helper)

## 3. Directory Authentication Service
- **Purpose:** Authenticate administrative users against local database or LDAP/Active Directory.
- **Responsibilities:**
  - Query LDAP server paths and check credentials against security groups.
  - Test server connections on demand.
