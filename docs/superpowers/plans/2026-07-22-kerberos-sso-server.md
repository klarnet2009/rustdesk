# Kerberos SSO — Server Implementation Plan (Plan 1 of 2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the self-hosted RustDesk web panel authenticate domain users via Kerberos/Negotiate securely — closing the current auth-bypass — with LDAP-enriched JIT provisioning, an admin-only browser SSO path, and a client-facing `/api/login-sso` that returns the same JWT shape as `/api/login`.

**Architecture:** A new `sso_kerberos.py` turns a base64 SPNEGO token into a verified AD principal (pyspnego acceptor + keytab, SPN pinned by config). A new `ldap_lookup_user()` (service-bind, no user password) enriches the principal. `resolve_sso_user()` maps principal → panel user (LDAP enrich + JIT, graceful degradation when LDAP is off). Two thin routes consume these: `POST /api/login-sso` (desktop client → JWT) and `GET /login-sso` (browser → session cookie, admins only). The `TOCKEN_SIMULATION_` bypass is deleted.

**Tech Stack:** Python 3.12, Flask, PyJWT (HS256), `pyspnego[kerberos]` + system MIT Kerberos (GSSAPI), `ldap3`, SQLite. Runtime: gunicorn in Docker (`python:3.12-slim`).

## Global Constraints

- Repo: `klarnet2009/rustdesk-server`, branch `feat/kerberos-sso` (create off `master`). All paths below are relative to repo root; server code lives in `web_panel/`.
- Never trust the HTTP `Host` header for the SPN. The SPN comes only from config: env `SSO_SPN` (e.g. `HTTP/rustdesk.iterum.lv`).
- JWT is issued exclusively via the existing `create_token(user_id, username, is_admin)` (`web_panel/server.py:312`) — HS256, 30-day exp. Do not introduce a second token scheme.
- The response body of `POST /api/login-sso` MUST match `POST /api/login`'s success shape: `{"access_token": <jwt>, "type": "access_token", "user": {"name","email","is_admin","status"}}`.
- Browser panel access is admins only: a session is created only when `is_admin` is true; session keys are exactly `session['user_id'|'username'|'is_admin']`.
- No `TOCKEN_SIMULATION_` code path may exist after Task 1.
- SQLite `users` unique key is `username`; SSO/JIT rows store `password=''`. `verify_password` must never authenticate an empty password (verified in Task 1).
- Existing reusable helpers (do not reimplement): `get_db()` (`server.py:199`), `create_token()` (`server.py:312`), `sanitize_field(value, max_len=128)` (`server.py:235`), `get_ldap_config()` / `search_user(conn, base_dn, username)` / `sync_ldap_user_to_db(ldap_user, is_admin)->user_id` / `is_ldap_enabled()` (`ldap_auth.py`), and the `LDAP_AVAILABLE` flag.

---

## File Structure

- `web_panel/sso_kerberos.py` — **new.** SPNEGO acceptance only: `validate_negotiate_token(token_b64, spn) -> principal` + `SPNEGO_AVAILABLE` + `SsoError`. No DB, no Flask, no LDAP.
- `web_panel/ldap_auth.py` — **modify.** Add `ldap_lookup_user(username) -> dict|None` (service-bind, password-less) and `groups_grant_admin(groups) -> bool` (extracted from the duplicated logic in `sync_all_ldap_users`).
- `web_panel/server.py` — **modify.** Add `resolve_sso_user(principal) -> dict`; rewrite `api_login_sso` (`:2214`); add `web_login_sso` route; honor `RUSTDESK_DB_PATH` env in `DB_PATH` (test isolation).
- `web_panel/requirements.txt` — **modify.** Add `pyspnego[kerberos]` and `pytest`.
- `web_panel/Dockerfile` — **modify.** Install `gcc libkrb5-dev krb5-user`; document `KRB5_KTNAME` / `SSO_SPN`.
- `web_panel/tests/conftest.py` — **new.** Temp-DB fixture + Flask `test_client`.
- `web_panel/tests/test_sso.py` — **new.** All unit/route tests for this plan.

**Ops prerequisites (documented here, performed by the AD admin at deploy — NOT code tasks):** register SPN `setspn -S HTTP/rustdesk.iterum.lv <svc-account>`; generate keytab `ktpass /princ HTTP/rustdesk.iterum.lv@<REALM> /mapuser <svc> /crypto AES256-SHA1 /ptype KRB5_NT_PRINCIPAL /pass <pw> /out rustdesk.keytab`; mount keytab as a Coolify secret with `KRB5_KTNAME=/etc/rustdesk.keytab`; provide `/etc/krb5.conf` (`[realms] <REALM> = { kdc = <dc-host> }` + `domain_realm`); enable/configure LDAP in the panel (Settings) so admin mapping works — until then SSO users are non-admin and the local `admin` account is the only panel admin; add `rustdesk.iterum.lv` to the browser intranet zone via GPO for the browser SSO path.

---

## Task 0: Test infrastructure + DB path override

**Files:**
- Modify: `web_panel/server.py:45` (DB_PATH), `web_panel/ldap_auth.py:17` (DB_PATH)
- Modify: `web_panel/requirements.txt`
- Create: `web_panel/tests/conftest.py`
- Create: `web_panel/tests/__init__.py` (empty)

**Interfaces:**
- Produces: a `client` pytest fixture (Flask test client) and a `db_path` fixture; env `RUSTDESK_DB_PATH` overrides the SQLite location so tests never touch the real `rustdesk.db`.

- [ ] **Step 1: Make DB_PATH honor an env override**

In `web_panel/server.py` find the DB_PATH definition (`server.py:45`, currently `DB_PATH = os.path.join(os.path.dirname(__file__), 'rustdesk.db')`) and replace with:

```python
DB_PATH = os.environ.get('RUSTDESK_DB_PATH') or os.path.join(os.path.dirname(__file__), 'rustdesk.db')
```

In `web_panel/ldap_auth.py` replace line 17 (`DB_PATH = os.path.join(...)`) with the identical override:

```python
DB_PATH = os.environ.get('RUSTDESK_DB_PATH') or os.path.join(os.path.dirname(os.path.abspath(__file__)), 'rustdesk.db')
```

- [ ] **Step 2: Add test deps to requirements.txt**

Append to `web_panel/requirements.txt`:

```
pytest>=8.0.0
pyspnego[kerberos]>=0.10.2
```

- [ ] **Step 3: Create the conftest fixture**

Create `web_panel/tests/__init__.py` (empty) and `web_panel/tests/conftest.py`:

```python
import os
import tempfile
import pytest


@pytest.fixture()
def db_path(monkeypatch):
    fd, path = tempfile.mkstemp(suffix='.db')
    os.close(fd)
    monkeypatch.setenv('RUSTDESK_DB_PATH', path)
    monkeypatch.setenv('SSO_SPN', 'HTTP/rustdesk.test.local')
    yield path
    os.remove(path)


@pytest.fixture()
def app_module(db_path):
    # Import after RUSTDESK_DB_PATH is set so init_db() writes to the temp DB.
    import importlib
    import server as server_mod
    importlib.reload(server_mod)
    server_mod.init_db()
    return server_mod


@pytest.fixture()
def client(app_module):
    app_module.app.config.update(TESTING=True)
    return app_module.app.test_client()
```

- [ ] **Step 4: Verify the harness imports and DB is isolated**

Run: `cd web_panel && pip install -r requirements.txt && python -m pytest tests/ -q`
Expected: pytest runs and collects 0 tests (no test files yet) with exit code 5 ("no tests ran"), and no `rustdesk.db` is modified in `web_panel/`. If import errors occur, fix them before proceeding.

- [ ] **Step 5: Commit**

```bash
git add web_panel/server.py web_panel/ldap_auth.py web_panel/requirements.txt web_panel/tests/__init__.py web_panel/tests/conftest.py
git commit -m "test(web_panel): pytest harness + RUSTDESK_DB_PATH override for isolation"
```

---

## Task 1: Remove the TOCKEN_SIMULATION_ auth bypass (SECURITY)

**Files:**
- Modify: `web_panel/server.py:2214-2308` (`api_login_sso`)
- Test: `web_panel/tests/test_sso.py`

**Interfaces:**
- Produces: `/api/login-sso` no longer honors any simulation token. When SPNEGO is unavailable it returns HTTP 501. (Full rewrite of the success path lands in Task 6; this task only removes the bypass and proves it's gone.)

- [ ] **Step 1: Write the failing regression test**

Create `web_panel/tests/test_sso.py`:

```python
import base64


def _neg(header_value):
    return {'Authorization': 'Negotiate ' + header_value}


def test_simulation_token_is_rejected(client):
    # The retired dev bypass: a base64 "TOCKEN_SIMULATION_admin" must NOT yield a token.
    payload = base64.b64encode(b'TOCKEN_SIMULATION_admin').decode()
    resp = client.post('/api/login-sso', headers=_neg(payload))
    assert resp.status_code != 200
    body = resp.get_json(silent=True) or {}
    assert 'access_token' not in body


def test_login_sso_challenges_without_auth(client):
    resp = client.post('/api/login-sso')
    assert resp.status_code == 401
    assert resp.headers.get('WWW-Authenticate') == 'Negotiate'
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd web_panel && python -m pytest tests/test_sso.py::test_simulation_token_is_rejected -v`
Expected: FAIL — the current code returns 200 with an `access_token` for the simulation token.

- [ ] **Step 3: Delete the bypass branch**

In `web_panel/server.py`, in `api_login_sso`, delete the entire `except ImportError:` block that inspects `TOCKEN_SIMULATION_` (currently `server.py:2273-2305`). Replace the whole `try: import spnego … except ImportError: …` structure with a guarded import at the top of the file and a 501 when unavailable. Concretely, the body of `api_login_sso` after the `Authorization` header checks becomes (final form in Task 6; interim form here):

```python
    token_b64 = auth_header.split(' ', 1)[1]
    from sso_kerberos import SPNEGO_AVAILABLE
    if not SPNEGO_AVAILABLE:
        return jsonify({'error': 'Kerberos SSO not available on this server'}), 501
    # Verification + user resolution implemented in Task 6.
    return jsonify({'error': 'not implemented'}), 501
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd web_panel && python -m pytest tests/test_sso.py -v`
Expected: both tests PASS (simulation token → not 200; missing auth → 401 + `WWW-Authenticate: Negotiate`). `sso_kerberos.SPNEGO_AVAILABLE` is created in Task 3; for this task add a temporary shim at the top of `server.py`: `SPNEGO_AVAILABLE = False` is NOT acceptable — instead create the real `sso_kerberos.py` now if Task 3 hasn't run. If executing strictly in order, create a minimal `web_panel/sso_kerberos.py` containing only `SPNEGO_AVAILABLE = False` and `class SsoError(Exception): pass`, to be fleshed out in Task 3.

- [ ] **Step 5: Commit**

```bash
git add web_panel/server.py web_panel/sso_kerberos.py web_panel/tests/test_sso.py
git commit -m "fix(web_panel): remove TOCKEN_SIMULATION_ auth bypass in /api/login-sso"
```

---

## Task 2: Deploy enablement — Kerberos build deps

**Files:**
- Modify: `web_panel/Dockerfile`

**Interfaces:**
- Produces: an image where `import spnego` succeeds and GSSAPI can read a keytab via `KRB5_KTNAME`. No unit test — verified by build.

- [ ] **Step 1: Add krb5 build/runtime deps before pip install**

Edit `web_panel/Dockerfile` so the section reads:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Kerberos/GSSAPI headers + runtime for pyspnego's kerberos backend.
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libkrb5-dev krb5-user \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 21114

# SSO expects: env SSO_SPN (e.g. HTTP/rustdesk.iterum.lv), env KRB5_KTNAME
# (path to the mounted keytab), and /etc/krb5.conf with the realm->KDC mapping.
CMD ["gunicorn", "-w", "1", "--threads", "8", "-b", "0.0.0.0:21114", "--access-logfile", "-", "--error-logfile", "-", "server:app"]
```

- [ ] **Step 2: Verify the image builds and spnego imports**

Run: `cd web_panel && docker build -t rustdesk-panel-sso-test . && docker run --rm rustdesk-panel-sso-test python -c "import spnego; print('spnego OK')"`
Expected: build succeeds; prints `spnego OK`.

- [ ] **Step 3: Commit**

```bash
git add web_panel/Dockerfile
git commit -m "build(web_panel): install libkrb5/krb5-user for pyspnego Kerberos backend"
```

---

## Task 3: `sso_kerberos.validate_negotiate_token`

**Files:**
- Create/replace: `web_panel/sso_kerberos.py`
- Test: `web_panel/tests/test_sso.py`

**Interfaces:**
- Produces: `SPNEGO_AVAILABLE: bool`; `class SsoError(Exception)`; `validate_negotiate_token(token_b64: str, spn: str) -> str` returning the verified client principal (e.g. `"jdoe@EXAMPLE.LOCAL"`). Raises `SsoError` on bad base64, incomplete handshake, or GSSAPI failure. The `spn` is `"HTTP/<host>"`; hostname/service are parsed from it — the caller passes `SSO_SPN`, never the request Host.

- [ ] **Step 1: Write the failing tests**

Add to `web_panel/tests/test_sso.py`:

```python
import types
import base64 as _b64
import pytest
import sso_kerberos


def test_validate_returns_principal(monkeypatch):
    class FakeCtx:
        complete = True
        client_principal = 'jdoe@EXAMPLE.LOCAL'
        def step(self, token):
            assert token == b'rawtoken'
            return None
    captured = {}
    def fake_server(hostname, service):
        captured['hostname'] = hostname
        captured['service'] = service
        return FakeCtx()
    monkeypatch.setattr(sso_kerberos, 'spnego', types.SimpleNamespace(server=fake_server), raising=False)
    monkeypatch.setattr(sso_kerberos, 'SPNEGO_AVAILABLE', True, raising=False)
    principal = sso_kerberos.validate_negotiate_token(_b64.b64encode(b'rawtoken').decode(), 'HTTP/rustdesk.test.local')
    assert principal == 'jdoe@EXAMPLE.LOCAL'
    assert captured == {'hostname': 'rustdesk.test.local', 'service': 'HTTP'}


def test_validate_incomplete_handshake_raises(monkeypatch):
    class FakeCtx:
        complete = False
        client_principal = None
        def step(self, token):
            return b'continue'
    monkeypatch.setattr(sso_kerberos, 'spnego', types.SimpleNamespace(server=lambda hostname, service: FakeCtx()), raising=False)
    monkeypatch.setattr(sso_kerberos, 'SPNEGO_AVAILABLE', True, raising=False)
    with pytest.raises(sso_kerberos.SsoError):
        sso_kerberos.validate_negotiate_token(_b64.b64encode(b'x').decode(), 'HTTP/rustdesk.test.local')


def test_validate_bad_base64_raises(monkeypatch):
    monkeypatch.setattr(sso_kerberos, 'SPNEGO_AVAILABLE', True, raising=False)
    with pytest.raises(sso_kerberos.SsoError):
        sso_kerberos.validate_negotiate_token('!!!not base64!!!', 'HTTP/rustdesk.test.local')
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k validate -v`
Expected: FAIL — `validate_negotiate_token` does not exist yet (the file has only the Task 1 shim).

- [ ] **Step 3: Implement `sso_kerberos.py`**

Replace `web_panel/sso_kerberos.py` with:

```python
"""Kerberos/SPNEGO acceptance. Turns a Negotiate token into a verified AD principal.

No DB, no Flask, no LDAP here — single responsibility. The keytab is chosen by
the system GSSAPI via the KRB5_KTNAME environment variable; the SPN is supplied
by the caller from config (never from the HTTP Host header).
"""

import base64

try:
    import spnego
    SPNEGO_AVAILABLE = True
except ImportError:
    spnego = None
    SPNEGO_AVAILABLE = False


class SsoError(Exception):
    pass


def validate_negotiate_token(token_b64, spn):
    """Verify a base64 SPNEGO token against `spn` ("HTTP/<host>"). Returns principal."""
    if not SPNEGO_AVAILABLE:
        raise SsoError("pyspnego not installed")
    service, _, hostname = spn.partition('/')
    if not service or not hostname:
        raise SsoError(f"invalid SPN: {spn!r}")
    try:
        token = base64.b64decode(token_b64, validate=True)
    except Exception as e:
        raise SsoError(f"invalid base64 token: {e}")
    try:
        ctx = spnego.server(hostname=hostname, service=service)
        ctx.step(token)
    except Exception as e:
        raise SsoError(f"GSSAPI acceptance failed: {e}")
    if not ctx.complete:
        raise SsoError("Negotiate handshake incomplete (multi-leg/NTLM not supported)")
    principal = getattr(ctx, 'client_principal', None)
    if not principal:
        raise SsoError("no client principal in completed context")
    return principal
```

- [ ] **Step 4: Run to verify they pass**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k validate -v`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add web_panel/sso_kerberos.py web_panel/tests/test_sso.py
git commit -m "feat(web_panel): sso_kerberos.validate_negotiate_token (SPNEGO acceptor)"
```

---

## Task 4: `ldap_auth.ldap_lookup_user` + `groups_grant_admin`

**Files:**
- Modify: `web_panel/ldap_auth.py`
- Test: `web_panel/tests/test_sso.py`

**Interfaces:**
- Produces: `ldap_lookup_user(username) -> dict|None` (service-bind lookup, no user password; returns `{'username','email','display_name','groups'}` or None); `groups_grant_admin(groups: list[str]) -> bool` (True if any group is in the `ldap_admin_groups` setting or the built-in defaults). Consumed by `resolve_sso_user` (Task 5).

- [ ] **Step 1: Write the failing tests**

Add to `web_panel/tests/test_sso.py`:

```python
import ldap_auth


def test_groups_grant_admin_uses_defaults(db_path):
    assert ldap_auth.groups_grant_admin(['Domain Users', 'Domain Admins']) is True
    assert ldap_auth.groups_grant_admin(['Domain Users']) is False


def test_ldap_lookup_user_none_when_unconfigured(db_path, monkeypatch):
    # No ldap_* settings in the temp DB -> lookup returns None, never raises.
    monkeypatch.setattr(ldap_auth, 'LDAP_AVAILABLE', True, raising=False)
    assert ldap_auth.ldap_lookup_user('jdoe') is None
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k "grant_admin or lookup_user" -v`
Expected: FAIL — functions not defined.

- [ ] **Step 3: Implement both helpers**

Add to `web_panel/ldap_auth.py` (after `sync_ldap_user_to_db`):

```python
def groups_grant_admin(groups):
    """True if any of the user's AD groups is configured as an admin group."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    row = conn.execute("SELECT value FROM settings WHERE key = 'ldap_admin_groups'").fetchone()
    conn.close()
    if row and row['value'] and row['value'].strip():
        admin_groups = [g.strip() for g in row['value'].split(',') if g.strip()]
    else:
        admin_groups = [
            'Domain Admins', 'Administrators', 'Enterprise Admins',
            'Администраторы домена', 'Администраторы', 'Admins', 'IT Admins', 'RustDesk Admins'
        ]
    return any(g in (groups or []) for g in admin_groups)


def ldap_lookup_user(username):
    """Look up an AD user by name using the service bind (no user password).

    Returns {'username','email','display_name','groups'} or None. Never raises.
    """
    if not LDAP_AVAILABLE:
        return None
    config = get_ldap_config()
    server_url = config.get('server', '')
    base_dn = config.get('base_dn', '')
    bind_dn = config.get('bind_dn', '')
    bind_password = config.get('bind_password', '')
    if not server_url or not base_dn or not bind_dn:
        return None
    try:
        server = Server(server_url, get_info=ALL)
        conn = Connection(server, user=bind_dn, password=bind_password, authentication=NTLM)
        if not conn.bind():
            conn = Connection(server, user=bind_dn, password=bind_password, authentication=SIMPLE)
            if not conn.bind():
                return None
        info = search_user(conn, base_dn, username)
        conn.unbind()
        return info
    except Exception as e:
        print(f"[LDAP] lookup_user failed for {username}: {e}")
        return None
```

- [ ] **Step 4: Run to verify they pass**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k "grant_admin or lookup_user" -v`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add web_panel/ldap_auth.py web_panel/tests/test_sso.py
git commit -m "feat(web_panel): ldap_lookup_user (service-bind) + groups_grant_admin"
```

---

## Task 5: `server.resolve_sso_user`

**Files:**
- Modify: `web_panel/server.py` (add function near the auth section, after `create_token`)
- Test: `web_panel/tests/test_sso.py`

**Interfaces:**
- Consumes: `ldap_auth.is_ldap_enabled()`, `ldap_auth.ldap_lookup_user`, `ldap_auth.groups_grant_admin`, `ldap_auth.sync_ldap_user_to_db`, `get_db()`, `sanitize_field()`.
- Produces: `resolve_sso_user(principal: str) -> dict` returning `{'user_id','username','is_admin','email'}`. With LDAP enabled + user found: enriched + `is_admin` from groups, persisted via `sync_ldap_user_to_db`. Otherwise: minimal JIT (username from principal, `password=''`, `is_admin=0`, synthesized email), row created if absent.

- [ ] **Step 1: Write the failing tests**

Add to `web_panel/tests/test_sso.py`:

```python
def test_resolve_minimal_jit_when_ldap_off(app_module, monkeypatch):
    monkeypatch.setattr(app_module.ldap_auth, 'is_ldap_enabled', lambda: False)
    out = app_module.resolve_sso_user('Jdoe@EXAMPLE.LOCAL')
    assert out['username'] == 'jdoe'          # realm stripped, lowercased
    assert out['is_admin'] is False
    assert isinstance(out['user_id'], int)
    # Row exists with empty password
    conn = app_module.get_db()
    row = conn.execute("SELECT password, is_admin FROM users WHERE username='jdoe'").fetchone()
    conn.close()
    assert row['password'] == ''
    assert row['is_admin'] == 0


def test_resolve_admin_via_ldap_groups(app_module, monkeypatch):
    monkeypatch.setattr(app_module.ldap_auth, 'is_ldap_enabled', lambda: True)
    monkeypatch.setattr(app_module.ldap_auth, 'ldap_lookup_user',
                        lambda u: {'username': 'boss', 'email': 'boss@x.local',
                                   'display_name': 'The Boss', 'groups': ['Domain Admins']})
    out = app_module.resolve_sso_user('boss@EXAMPLE.LOCAL')
    assert out['username'] == 'boss'
    assert out['is_admin'] is True
    assert out['email'] == 'boss@x.local'
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k resolve -v`
Expected: FAIL — `resolve_sso_user` not defined.

- [ ] **Step 3: Implement `resolve_sso_user`**

Add to `web_panel/server.py` (import `ldap_auth` as a module is already available — the file uses `from ldap_auth import ...`; ensure `import ldap_auth` exists near the top, add it if missing). Place after `create_token`:

```python
def resolve_sso_user(principal):
    """Map a verified Kerberos principal to a panel user.

    LDAP enabled + found -> enrich (email, display_name, admin-by-group) + JIT.
    Otherwise -> minimal JIT (non-admin, empty password, synthesized email).
    Returns {'user_id', 'username', 'is_admin', 'email'}.
    """
    username = sanitize_field(principal.split('@')[0].strip().lower(), 64)
    realm = principal.split('@', 1)[1].lower() if '@' in principal else 'domain.local'

    if ldap_auth.is_ldap_enabled():
        info = ldap_auth.ldap_lookup_user(username)
        if info:
            is_admin = ldap_auth.groups_grant_admin(info.get('groups'))
            user_id = ldap_auth.sync_ldap_user_to_db(info, is_admin)
            return {'user_id': user_id, 'username': info['username'],
                    'is_admin': is_admin, 'email': info.get('email', '')}

    # Minimal JIT
    email = f"{username}@{realm}"
    conn = get_db()
    row = conn.execute("SELECT id FROM users WHERE username = ?", (username,)).fetchone()
    if row:
        user_id = row['id']
    else:
        cur = conn.cursor()
        cur.execute("INSERT INTO users (username, password, email, is_admin, status) VALUES (?, '', ?, 0, 1)",
                    (username, email))
        user_id = cur.lastrowid
        conn.commit()
    conn.close()
    return {'user_id': user_id, 'username': username, 'is_admin': False, 'email': email}
```

- [ ] **Step 4: Run to verify they pass**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k resolve -v`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add web_panel/server.py web_panel/tests/test_sso.py
git commit -m "feat(web_panel): resolve_sso_user (LDAP enrich + graceful minimal JIT)"
```

---

## Task 6: Rewrite `POST /api/login-sso` (desktop client → JWT)

**Files:**
- Modify: `web_panel/server.py` (`api_login_sso`, `:2214`)
- Test: `web_panel/tests/test_sso.py`

**Interfaces:**
- Consumes: `sso_kerberos.validate_negotiate_token`, `sso_kerberos.SPNEGO_AVAILABLE`, `resolve_sso_user`, `create_token`, env `SSO_SPN`.
- Produces: `POST /api/login-sso` returns `{"access_token","type":"access_token","user":{...}}` on success; 401 + `WWW-Authenticate: Negotiate` when no/invalid Negotiate header; 501 when SPNEGO unavailable; 401 on `SsoError`.

- [ ] **Step 1: Write the failing tests**

Add to `web_panel/tests/test_sso.py`:

```python
def test_login_sso_success_returns_jwt(app_module, monkeypatch):
    import sso_kerberos as sk
    monkeypatch.setattr(sk, 'SPNEGO_AVAILABLE', True, raising=False)
    monkeypatch.setattr(app_module, 'validate_negotiate_token', lambda t, spn: 'jdoe@EXAMPLE.LOCAL', raising=False)
    monkeypatch.setattr(sk, 'validate_negotiate_token', lambda t, spn: 'jdoe@EXAMPLE.LOCAL', raising=False)
    monkeypatch.setattr(app_module, 'resolve_sso_user',
                        lambda p: {'user_id': 7, 'username': 'jdoe', 'is_admin': False, 'email': 'jdoe@x'})
    resp = app_module.app.test_client().post('/api/login-sso', headers={'Authorization': 'Negotiate QQ=='})
    assert resp.status_code == 200
    body = resp.get_json()
    assert body['type'] == 'access_token'
    assert body['access_token']
    assert body['user']['name'] == 'jdoe'
    assert body['user']['is_admin'] is False


def test_login_sso_ssoerror_is_401(app_module, monkeypatch):
    import sso_kerberos as sk
    monkeypatch.setattr(sk, 'SPNEGO_AVAILABLE', True, raising=False)
    def boom(t, spn):
        raise sk.SsoError('bad ticket')
    monkeypatch.setattr(sk, 'validate_negotiate_token', boom, raising=False)
    resp = app_module.app.test_client().post('/api/login-sso', headers={'Authorization': 'Negotiate QQ=='})
    assert resp.status_code == 401
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k "login_sso_success or ssoerror" -v`
Expected: FAIL — endpoint still returns the Task 1 interim 501.

- [ ] **Step 3: Implement the final endpoint**

At the top of `web_panel/server.py` (with the other imports) add:

```python
import sso_kerberos
SSO_SPN = os.environ.get('SSO_SPN', '')
```

Replace the entire body of `api_login_sso` (`server.py:2214`) with:

```python
@app.route('/api/login-sso', methods=['GET', 'POST', 'OPTIONS'])
def api_login_sso():
    if request.method == 'OPTIONS':
        return '', 200
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Negotiate '):
        resp = make_response(jsonify({'error': 'Negotiate authentication required'}), 401)
        resp.headers['WWW-Authenticate'] = 'Negotiate'
        return resp
    if not sso_kerberos.SPNEGO_AVAILABLE:
        return jsonify({'error': 'Kerberos SSO not available on this server'}), 501
    if not SSO_SPN:
        return jsonify({'error': 'SSO_SPN not configured on this server'}), 501
    token_b64 = auth_header.split(' ', 1)[1]
    try:
        principal = sso_kerberos.validate_negotiate_token(token_b64, SSO_SPN)
    except sso_kerberos.SsoError as e:
        print(f"[SSO] validation failed: {e}")
        resp = make_response(jsonify({'error': 'Kerberos validation failed'}), 401)
        resp.headers['WWW-Authenticate'] = 'Negotiate'
        return resp
    u = resolve_sso_user(principal)
    access_token = create_token(u['user_id'], u['username'], u['is_admin'])
    print(f"[SSO] client login OK: {u['username']} (admin={u['is_admin']})")
    return jsonify({
        'access_token': access_token,
        'type': 'access_token',
        'user': {
            'name': u['username'],
            'email': u['email'],
            'is_admin': u['is_admin'],
            'status': 'active',
        },
    })
```

- [ ] **Step 4: Run the full test file**

Run: `cd web_panel && python -m pytest tests/test_sso.py -v`
Expected: all tests PASS (including the Task 1 regression tests).

- [ ] **Step 5: Commit**

```bash
git add web_panel/server.py web_panel/tests/test_sso.py
git commit -m "feat(web_panel): implement /api/login-sso (Kerberos validate -> resolve -> JWT)"
```

---

## Task 7: Browser SSO route `GET /login-sso` (admins only)

**Files:**
- Modify: `web_panel/server.py` (new route near `web_login`, `:1757`)
- Test: `web_panel/tests/test_sso.py`

**Interfaces:**
- Consumes: `sso_kerberos`, `resolve_sso_user`, Flask `session`, `SSO_SPN`.
- Produces: `GET /login-sso` — no/invalid Negotiate → 401 `WWW-Authenticate: Negotiate`; valid ticket + `is_admin` → sets `session['user_id'|'username'|'is_admin']` and 302 → `/dashboard`; valid ticket + non-admin → 302 → `/login` (no session). Reuses the same acceptor + resolver as the API route.

- [ ] **Step 1: Write the failing tests**

Add to `web_panel/tests/test_sso.py`:

```python
def test_browser_sso_admin_gets_session(app_module, monkeypatch):
    import sso_kerberos as sk
    monkeypatch.setattr(sk, 'SPNEGO_AVAILABLE', True, raising=False)
    monkeypatch.setattr(sk, 'validate_negotiate_token', lambda t, spn: 'boss@X', raising=False)
    monkeypatch.setattr(app_module, 'resolve_sso_user',
                        lambda p: {'user_id': 1, 'username': 'boss', 'is_admin': True, 'email': 'b@x'})
    c = app_module.app.test_client()
    resp = c.get('/login-sso', headers={'Authorization': 'Negotiate QQ=='})
    assert resp.status_code == 302
    assert '/dashboard' in resp.headers['Location']
    with c.session_transaction() as s:
        assert s['user_id'] == 1 and s['is_admin'] is True


def test_browser_sso_nonadmin_denied(app_module, monkeypatch):
    import sso_kerberos as sk
    monkeypatch.setattr(sk, 'SPNEGO_AVAILABLE', True, raising=False)
    monkeypatch.setattr(sk, 'validate_negotiate_token', lambda t, spn: 'jdoe@X', raising=False)
    monkeypatch.setattr(app_module, 'resolve_sso_user',
                        lambda p: {'user_id': 2, 'username': 'jdoe', 'is_admin': False, 'email': 'j@x'})
    c = app_module.app.test_client()
    resp = c.get('/login-sso', headers={'Authorization': 'Negotiate QQ=='})
    assert resp.status_code == 302
    assert '/login' in resp.headers['Location']
    with c.session_transaction() as s:
        assert 'user_id' not in s


def test_browser_sso_challenges_without_auth(app_module):
    resp = app_module.app.test_client().get('/login-sso')
    assert resp.status_code == 401
    assert resp.headers.get('WWW-Authenticate') == 'Negotiate'
```

- [ ] **Step 2: Run to verify they fail**

Run: `cd web_panel && python -m pytest tests/test_sso.py -k browser_sso -v`
Expected: FAIL — route not defined (404).

- [ ] **Step 3: Implement the route**

Add to `web_panel/server.py` near `web_login`:

```python
@app.route('/login-sso', methods=['GET'])
def web_login_sso():
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Negotiate '):
        resp = make_response('', 401)
        resp.headers['WWW-Authenticate'] = 'Negotiate'
        return resp
    if not sso_kerberos.SPNEGO_AVAILABLE or not SSO_SPN:
        return redirect(url_for('web_login'))
    try:
        principal = sso_kerberos.validate_negotiate_token(auth_header.split(' ', 1)[1], SSO_SPN)
    except sso_kerberos.SsoError as e:
        print(f"[SSO] browser validation failed: {e}")
        return redirect(url_for('web_login'))
    u = resolve_sso_user(principal)
    if not u['is_admin']:
        print(f"[SSO] browser login denied (not admin): {u['username']}")
        return redirect(url_for('web_login'))
    session['user_id'] = u['user_id']
    session['username'] = u['username']
    session['is_admin'] = True
    return redirect(url_for('web_dashboard'))
```

Note: confirm the dashboard endpoint name is `web_dashboard` (grep `def web_dashboard`); if it differs, use the actual function name in `url_for`.

- [ ] **Step 4: Run the full suite**

Run: `cd web_panel && python -m pytest tests/ -v`
Expected: all tests PASS.

- [ ] **Step 5: Commit**

```bash
git add web_panel/server.py web_panel/tests/test_sso.py
git commit -m "feat(web_panel): browser SSO /login-sso (admins only)"
```

---

## Self-Review notes (already applied)

- **Spec coverage:** bypass removal (T1), pyspnego acceptor + keytab/SPN pinning (T2, T3), LDAP enrichment + graceful degradation (T4, T5), client `/api/login-sso` JWT parity (T6), admin-only browser SSO (T7). Client-side timeout+i18n is **Plan 2** (out of scope here). AD keytab/SPN/krb5.conf and LDAP-enable are ops prerequisites (documented in File Structure).
- **Type consistency:** `resolve_sso_user` returns `{'user_id','username','is_admin','email'}` and is consumed identically in T6/T7; `validate_negotiate_token(token_b64, spn)` signature is consistent across T3/T6/T7; `create_token(user_id, username, is_admin)` matches the existing helper.
- **Verify-password guard:** during T1, confirm `verify_password('', stored)` returns False for the pbkdf2/legacy formats so `password=''` JIT rows can't log in via `/api/login`; if not, add a guard `if not password_hash: return False` at the top of `verify_password` and a test.
