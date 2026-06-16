# Architecture Diagram

The diagram below outlines the communication flows between the RustDesk client devices, the Web Panel server, and the administrator browser.

```mermaid
graph TD
    subgraph Client ["Remote Client Devices"]
        RC1[RustDesk Client]
        RC2[RustDesk Client]
    end

    subgraph Server ["Web Panel Server"]
        FP[Flask API Handler]
        DB[(SQLite DB: rustdesk.db)]
        LDAP[LDAP/AD Server]
    end

    subgraph Admin ["Administrator Browser"]
        WP[Admin Web Panel]
    end

    RC1 -- "/api/heartbeat (POST)" --> FP
    RC2 -- "/api/sysinfo (POST)" --> FP
    FP -- "Updates Status & System Info" --> DB
    
    WP -- "Fetches Pages & Devices List" --> FP
    FP -- "Query Devices & Logs" --> DB
    FP -- "Authenticate Admin" --> LDAP
    
    WP -- "Click Connect (rustdesk://)" --> RC1
```

## Communication Patterns
1. **Device Heartbeats:** Background pings occur asynchronously from clients directly to the server's HTTP endpoints.
2. **Web Operations:** Synchronous requests from the administrator browser to retrieve HTML templates populated with SQLite data.
3. **Connection launcher:** Browser triggers URI scheme `rustdesk://connection/new/<device_id>`, invoking the local RustDesk desktop application directly.
