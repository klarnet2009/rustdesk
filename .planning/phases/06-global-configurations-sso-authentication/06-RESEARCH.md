# Phase 6: Global Configurations & SSO Authentication - Research

## Windows SSPI for Kerberos Token Generation

The Security Support Provider Interface (SSPI) is the Win32 API used for security package negotiation (Kerberos, NTLM, etc.). On a domain-joined Windows desktop, the client can obtain a Kerberos service ticket for a Service Principal Name (SPN) without prompting the user for credentials.

### Key Win32 Functions (exported by `secur32.dll`):
1. **`AcquireCredentialsHandleW`**:
   - Acquires a handle to pre-existing credentials of a security principal.
   - For Kerberos client authentication, we pass `Negotiate` or `Kerberos` as the package name, and `SECPKG_CRED_OUTBOUND` as the credential use flag.
2. **`InitializeSecurityContextW`**:
   - Initiates the client-side security context.
   - Parameters:
     - `phCredential`: Handle returned by `AcquireCredentialsHandle`.
     - `pszTargetName`: The Service Principal Name (SPN) of the target service (e.g. `HTTP/rustdesk.company.local`).
     - `fContextReq`: Context requirements (e.g., `ISC_REQ_MUTUAL_AUTH`, `ISC_REQ_DELEGATE`).
     - `pInput`: Pointer to input buffer (empty for the first call).
     - `pOutput`: Pointer to output buffer (where the base64 SPNEGO token is written).
   - Returns:
     - `SEC_I_CONTINUE_NEEDED` or `SEC_E_OK` if successful.

### Rust SSPI Prototype:
```rust
use std::ffi::OsStr;
use std::os::windows::ffi::OsStrExt;
use std::ptr;

// Raw FFI bindings
#[link(name = "secur32")]
extern "system" {
    fn AcquireCredentialsHandleW(
        pszPrincipal: *const u16,
        pszPackage: *const u16,
        fCredentialUse: u32,
        pvLogonID: *const std::ffi::c_void,
        pAuthData: *const std::ffi::c_void,
        pGetKeyFn: *const std::ffi::c_void,
        pvGetKeyArgument: *const std::ffi::c_void,
        phCredential: *mut CredHandle,
        ptsExpiry: *mut i64,
    ) -> i32;

    fn InitializeSecurityContextW(
        phCredential: *const CredHandle,
        phContext: *const CredHandle,
        pszTargetName: *const u16,
        fContextReq: u32,
        Reserved1: u32,
        TargetDataRep: u32,
        pInput: *const SecBufferDesc,
        Reserved2: u32,
        phNewContext: *mut CredHandle,
        pOutput: *mut SecBufferDesc,
        pfContextAttr: *mut u32,
        ptsExpiry: *mut i64,
    ) -> i32;
}
```

---

## Python `pyspnego` Integration on the Server

On the server side, Python's `pyspnego` library abstracts SPNEGO/Negotiate token authentication across Windows and Linux platforms.

### Server-side Authentication Flow in Flask:
1. **Challenge Response**:
   When the client accesses `/api/login-sso` without an authorization header, the server returns:
   ```http
   HTTP/1.1 401 Unauthorized
   WWW-Authenticate: Negotiate
   ```
2. **Negotiate Request**:
   The client returns the request with the header:
   ```http
   Authorization: Negotiate YII... (Base64 SPNEGO Token)
   ```
3. **Validation using `pyspnego`**:
   ```python
   import spnego

   auth_header = request.headers.get("Authorization")
   if not auth_header or not auth_header.startswith("Negotiate "):
       # Send challenge
       ...

   token = auth_header.split(" ")[1]
   # Initialize spnego acceptor context
   context = spnego.client(username=None, password=None, hostname="rustdesk.company.local", service="HTTP", context_req=spnego.ContextReq.default)
   # Validate token
   try:
       server_token = context.step(base64.b64decode(token))
       if context.complete:
           username = context.client_principal  # E.g., user@COMPANY.LOCAL
           # Map user to domain and generate JWT token!
   except Exception as e:
       # Authentication failed
   ```

---

## Technical Feasibility & Co-existence
- **Co-existence**: The `/api/login-sso` route will only handle Kerberos-initiated logins. If the client fails to supply a Negotiate token or if the server returns an error, the client UI falls back to `/api/login` (manual credentials login via LDAP or local DB).
- **Android Support**: Since mobile devices are not joined to Active Directory via Kerberos locally, they will always bypass `/api/login-sso` and use standard LDAP/local credentials via the login form. This fits the requirements perfectly.
