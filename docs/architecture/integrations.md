# Integrations Documentation

## 1. RustDesk Client Application
- **Purpose:** Telemetry reporting and remote connectivity.
- **Protocol:** HTTP REST APIs over TCP.
- **Endpoints Utilized:**
  - `POST /api/heartbeat` (Keepalive pings)
  - `POST /api/sysinfo` (Hardware/OS info reports)
  - `POST /api/audit/<typ>` (Session connectivity audit logging)
- **URI Launchers:** Integrates via OS-registered custom schema launcher `rustdesk://connection/new/<device_id>`.

## 2. LDAP / Active Directory
- **Purpose:** User account synchronization and login delegation.
- **Protocol:** LDAP/LDAPS.
- **APIs Used:**
  - Bind operations using python `ldap3` package.
  - Search queries under directory base DN paths.
- **Authentication Method:** Simple credentials bind.
