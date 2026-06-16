# Deployment & Client Setup Guide

## 1. Server Deployment

### Prerequisites
- Python 3.9 or higher
- Node.js & npm (for stylesheet compilation during development)

### Quick Start
1. Install requirements:
   ```bash
   pip install -r web_panel/requirements.txt
   ```
2. Build Tailwind CSS styling:
   ```bash
   cd web_panel
   npm install
   npm run build
   ```
3. Run the application:
   ```bash
   python server.py
   ```
4. Access the web interface at `http://localhost:21114`.

### Production Deployment
In production environments, serve the app using Gunicorn:
```bash
gunicorn --bind 0.0.0.0:21114 server:app
```

---

## 2. Client-Side Protocol Registration

To allow one-click remote desktop launches directly from the web panel, the client machine must associate the custom `rustdesk://` scheme with the local RustDesk app installer.

### Windows Configuration
Windows client installers usually register the scheme automatically. If manual association is needed, import the following `.reg` file:

```registry
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\rustdesk]
@="URL:RustDesk Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\rustdesk\shell]

[HKEY_CLASSES_ROOT\rustdesk\shell\open]

[HKEY_CLASSES_ROOT\rustdesk\shell\open\command]
@="\"C:\\Program Files\\RustDesk\\rustdesk.exe\" \"--connect\" \"%1\""
```

### Linux Configuration
On Linux machines, register the URL handler with desktop entries:

1. Create file `~/.local/share/applications/rustdesk-link.desktop`:
   ```ini
   [Desktop Entry]
   Name=RustDesk Launcher
   Exec=rustdesk --connect %u
   Type=Application
   Terminal=false
   MimeType=x-scheme-handler/rustdesk;
   ```
2. Run update association command:
   ```bash
   xdg-mime default rustdesk-link.desktop x-scheme-handler/rustdesk
   ```

### macOS Configuration
On macOS, double clicking the installed RustDesk app bundle registers the `rustdesk://` custom scheme automatically based on its bundle configuration. If it does not resolve, drag and drop the app bundle to `/Applications/` folder and launch it once.
