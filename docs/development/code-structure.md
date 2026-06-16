# Code Structure Guide

This guide maps where the key components of the RustDesk Web Management Panel live.

> [!NOTE]
> The `/web_panel` directory exists in both client (`rustdesk`) and server (`rustdesk-server`) repositories. The active server panel is managed and executed from the `rustdesk-server/web_panel` directory.

```
/web_panel
│   Dockerfile              # Docker packaging configuration
│   ldap_auth.py            # LDAP Active Directory bind helper logic
│   package.json            # Node dev dependencies and Tailwind compile commands
│   requirements.txt        # Python pip library dependencies
│   server.py               # Main Flask web app containing routing and HTML strings
│   tailwind.config.js      # Styling themes, colors, and layout mappings
│
├───src
│       input.css           # Styling entrypoint utilizing @tailwind layers
│
└───static
        output.css          # Output asset containing compiled CSS
```

## Key Files & Entry Points
1. **Entry Point:** [web_panel/server.py](file:///D:/rustdesk_src/rustdesk/web_panel/server.py)
   - Contains SQLite initialization, routing, request filters, and API endpoints.
   - Contains all template views (`BASE_HTML`, `DASHBOARD_HTML`, etc.) represented as inline variables.
2. **Build Configurations:** [web_panel/package.json](file:///D:/rustdesk_src/rustdesk/web_panel/package.json)
   - Defines standard build target: `npm run build` generates output styles.
