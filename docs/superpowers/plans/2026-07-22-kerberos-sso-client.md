# Kerberos SSO — Client Implementation Plan (Plan 2 of 2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Harden the existing client-side Kerberos SSO trigger: never let a hung SSPI call stall app startup, and replace the hard-coded Russian success toast with a translatable string.

**Architecture:** `tryKerberosSso` already runs on startup (`user_model.dart:133`, invoked from `refreshCurrentUser` at `:60` when the access token is empty on Windows). Two focused changes: (1) wrap the blocking FFI `mainGetSsoToken` call in a timeout that yields `''` (which the existing empty-token branch already treats as "SSO unavailable → fall through"); (2) swap the literal toast for `translate("sso_auto_login_tip")`, adding the key to `src/lang/en.rs` (English default + fallback for all locales) and `src/lang/ru.rs` (Russian).

**Tech Stack:** Flutter/Dart, flutter_rust_bridge FFI, RustDesk `translate()` (keys in `src/lang/*.rs`).

## Global Constraints

- Repo: `klarnet2009/rustdesk` (client), branch `feat/kerberos-sso`.
- `translate(String name)` is already imported into `user_model.dart` via `import '../common.dart'` — no new import needed.
- Do not change the fallback contract: an empty token must continue to fall through to the manual-login path (Login button); do NOT auto-open the login dialog.
- Windows-only path is unchanged (`refreshCurrentUser` already gates on `isWindows`).

---

## Task 1: Timeout guard on the SSPI token call

**Files:**
- Modify: `flutter/lib/models/user_model.dart` (inside `tryKerberosSso`, the `mainGetSsoToken` call ~line 140)

**Interfaces:**
- Consumes: `bind.mainGetSsoToken({required String spn})` (returns `Future<String>`; `''` means unavailable).
- Produces: same `tryKerberosSso` behavior, but a stuck SSPI call resolves to `''` after 8s instead of hanging startup.

- [ ] **Step 1: Replace the unguarded await with a timeout**

In `flutter/lib/models/user_model.dart`, change:

```dart
      final spn = "HTTP/$host";
      final token = await bind.mainGetSsoToken(spn: spn);
      if (token.isEmpty) {
        debugPrint("Kerberos token is empty (SSO not available or failed)");
        return;
      }
```

to:

```dart
      final spn = "HTTP/$host";
      final token = await bind.mainGetSsoToken(spn: spn).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint("Kerberos SSO token acquisition timed out");
          return '';
        },
      );
      if (token.isEmpty) {
        debugPrint("Kerberos token is empty (SSO not available or failed)");
        return;
      }
```

- [ ] **Step 2: Verify analyzer is clean**

Run: `cd flutter && flutter analyze lib/models/user_model.dart`
Expected: "No issues found!" (or only pre-existing unrelated infos). No new errors.

- [ ] **Step 3: Commit**

```bash
git add flutter/lib/models/user_model.dart
git commit -m "fix(client): timeout guard on Kerberos SSPI token so it can't stall startup"
```

---

## Task 2: Translatable success toast

**Files:**
- Modify: `flutter/lib/models/user_model.dart` (the `BotToast.showText` in `tryKerberosSso`, ~line 172)
- Modify: `src/lang/en.rs` (add key)
- Modify: `src/lang/ru.rs` (add key)

**Interfaces:**
- Consumes: `translate("sso_auto_login_tip")` → resolves via `src/lang/<locale>.rs`, falling back to the English entry, then to the key string.
- Produces: the auto-login toast is localized (English by default, Russian on ru locale).

- [ ] **Step 1: Replace the hard-coded toast**

In `flutter/lib/models/user_model.dart`, change:

```dart
          BotToast.showText(
            text: "Вход выполнен автоматически через Active Directory",
            duration: Duration(seconds: 4),
          );
```

to:

```dart
          BotToast.showText(
            text: translate("sso_auto_login_tip"),
            duration: const Duration(seconds: 4),
          );
```

- [ ] **Step 2: Add the English key**

In `src/lang/en.rs`, add a new entry inside the map (next to the other tuples, e.g. right after the `("desk_tip", ...)` line at the top of the list):

```rust
        ("sso_auto_login_tip", "Signed in automatically via Active Directory"),
```

- [ ] **Step 3: Add the Russian key**

In `src/lang/ru.rs`, add the corresponding entry inside its map:

```rust
        ("sso_auto_login_tip", "Вход выполнен автоматически через Active Directory"),
```

- [ ] **Step 4: Verify**

Run: `cd flutter && flutter analyze lib/models/user_model.dart`
Expected: No new issues.
Run: `grep -n "sso_auto_login_tip" src/lang/en.rs src/lang/ru.rs`
Expected: one match in each file.

(Rust compilation of the lang maps is exercised by CI / the release build; a lang tuple is low-risk. Do not run a full `cargo check` here.)

- [ ] **Step 5: Commit**

```bash
git add flutter/lib/models/user_model.dart src/lang/en.rs src/lang/ru.rs
git commit -m "i18n(client): translatable Kerberos auto-login toast (en + ru)"
```

---

## Self-Review notes

- **Spec coverage:** matches the spec's client-polish items ("timeout guard so a hung SSPI call cannot stall startup" and "replace the hard-coded Russian toast with translated()"). The fallback UX (silent Login button) is unchanged, as decided.
- **No new import:** `translate` and `debugPrint` are already in scope in `user_model.dart`.
- **Placeholder scan:** none — exact code and exact keys given.
