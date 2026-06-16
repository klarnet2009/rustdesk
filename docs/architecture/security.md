# Security Documentation

## 1. Authentication & Authorization
- **JWT Authorization:** API endpoints require standard bearer JSON Web Tokens (`@token_required` decorator) signature check.
- **Admin Verification:** Cookie session decorators (`@web_login_required`) verify admin authorization before rendering templates.
- **Password Hashing:** Administrative and local user accounts hash passwords using sha256 or bcrypt prior to saving them to SQLite database tables.

## 2. Network Security
- **TLS/SSL Encryption:** Configured to support HTTPS via SSL certificate/key definitions in config setups.
- **Cross-Origin Resource Sharing (CORS):** Flask-CORS is integrated to restrict API requests to approved domains.

## 3. Data Integrity
- **SQL Injection Prevention:** Utilizes parameterized SQLite SQL commands throughout the server codebase.
- **Audit Trails:** All client connection actions, file transfers, and alarms write persistent event entries in `audit_logs` table.
