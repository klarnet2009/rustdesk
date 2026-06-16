# Phase 3: Connection Flow & Integration Check - Research

**Date:** 2026-06-16

## 1. Client-Side Launcher Protocol Mappings

The RustDesk client application registers a custom URI protocol scheme `rustdesk://` during installation.

### Windows Protocol Registry
When the click-to-connect button redirects the browser to `rustdesk://connection/new/<device_id>`, Windows looks up the registry key:
`HKEY_CLASSES_ROOT\rustdesk`

Expected registry configuration:
```registry
[HKEY_CLASSES_ROOT\rustdesk]
@="URL:RustDesk Protocol"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\rustdesk\shell]

[HKEY_CLASSES_ROOT\rustdesk\shell\open]

[HKEY_CLASSES_ROOT\rustdesk\shell\open\command]
@="\"C:\\Program Files\\RustDesk\\rustdesk.exe\" \"--connect\" \"%1\""
```

### Linux Protocol Registry
Linux desktop environments resolve protocol handlers using `xdg-open` via `.desktop` file associations.

File: `~/.local/share/applications/rustdesk-link.desktop`
```ini
[Desktop Entry]
Name=RustDesk Launcher
Exec=rustdesk --connect %u
Type=Application
Terminal=false
MimeType=x-scheme-handler/rustdesk;
```

Update command:
`xdg-mime default rustdesk-link.desktop x-scheme-handler/rustdesk`

### macOS Protocol Registry
macOS uses the client app bundle's `Info.plist` file containing `CFBundleURLTypes` to map the protocol handler:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>RustDesk Protocol</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>rustdesk</string>
        </array>
    </dict>
</array>
```
When a URL like `rustdesk://connection/new/<device_id>` is invoked, the operating system launches RustDesk and passes the URI argument, allowing RustDesk to parse the connection command and initiate a session to the specified remote host.
