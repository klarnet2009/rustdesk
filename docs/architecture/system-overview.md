# System Overview

## Purpose
The RustDesk Web Management Panel is a central administrative interface designed for mass management of remote computers. It allows administrators to view the online/offline status, host details, and system specifications of all registered client devices, and connect to them with a single click via custom URL schemes.

## High-Level Architecture
The system utilizes a split-layer design:
1. **Frontend UI:** Responsive administrative control panel styled using Tailwind CSS and DaisyUI.
2. **Backend Server:** Light-weight Flask application exposing endpoints for client heartbeats, system info reporting, and administrator authentication.
3. **Database Layer:** SQLite database (`rustdesk.db`) storing user accounts, device metadata, audit logs, and connection logs.

## Technology Stack
- **Language:** Python 3.x
- **Web Framework:** Flask
- **Styling Framework:** Tailwind CSS & DaisyUI
- **Database:** SQLite
- **Authentication:** JSON Web Tokens (JWT) / LDAP Active Directory integration

## Architectural Philosophy
The system prioritizes simplicity, low resource overhead, and responsiveness. Direct database queries, local assets compile, and stateless sessions allow hosting the management panel on minimal hardware without external dependency requirements.
