# Infrastructure Documentation

## Runtime Environment
- **Python Host:** Runs on Python 3.9+ environment.
- **Process Manager:** Gunicorn WSGI HTTP server in production; standard Flask development server for local debugging.
- **Port Bindings:** Default web port is `21114`.

## Database Infrastructure
- **Storage:** Local SQLite database file (`web_panel/rustdesk.db`).
- **Backup:** Simple file copy operations on the DB file while the database is idle.

## Deployment Setup
- **Dockerization:** Configured to run in containers via `web_panel/Dockerfile`.
- **Certificates:** Uses local TLS/SSL certs `10.21.31.11+2.pem` and private key `10.21.31.11+2-key.pem` to encrypt transport connections when SSL is enabled.
- **Network Boundaries:** Requires routing TCP traffic on port `21114` from client devices to the API server.
