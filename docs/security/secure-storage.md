# Secure storage (Phase 4.2)

Pak POS stores sensitive credentials in platform-protected storage through a small Dart abstraction. Feature code depends on [SecureStorageService](/mobile/lib/core/security/secure_storage_service.dart), not on `flutter_secure_storage` directly.

## Scope

**In scope (Phase 4.2):**

- Interface, production adapter, key registry, Riverpod provider, test fake, typed errors, documentation.

**Explicit exclusions (later phases):**

- Authentication, login/logout, JWT handling, refresh-token rotation, device activation/revocation, offline unlock, password hashing, onboarding UI, business schema changes, NestJS identity APIs, or writing real credentials at app startup.

Secure storage **protects data at rest** using OS mechanisms. It does **not** implement authentication and does **not** guarantee safety on a compromised device or under malware with user privileges.

## Architecture

```text
Feature / future auth code
        │
        ▼
 secureStorageServiceProvider (Riverpod)
        │
        ▼
 createPlatformSecureStorage()  ── web ──► Unsupported (throws)
        │
        ├─ Android / Windows ──► FlutterSecureStorageService
        └─ other dart:io desktops / mobile ──► Unsupported (throws)
```

There is **no plaintext fallback** (no SQLite, SharedPreferences, files, or environment variables for secrets).

## Key registry

Keys live under the `pakpos.` namespace in [SecureStorageKeys](/mobile/lib/core/security/secure_storage_keys.dart). Names do not depend on business IDs.

| Key | Intended future use |
|-----|---------------------|
| `pakpos.installation.credential` | Installation-level credential material |
| `pakpos.auth.refresh_token` | Session refresh token |
| `pakpos.auth.offline_verifier` | Offline verifier material |
| `pakpos.device.credential` | Device trust / activation credential |

`deleteAll()` removes only keys listed in `applicationOwnedKeys`, not unrelated Windows Credential Manager entries.

## Windows

**Package:** `flutter_secure_storage` 11.2.0 (`flutter_secure_storage_windows` 4.2.2).

**Mechanism (per plugin documentation):** Values are encrypted with **AES-GCM**. A per-entry encryption key is managed via the **Windows Credential Manager**. Encrypted payloads are stored under the application support directory; optional backward-compatible Credential Manager paths exist when `useBackwardCompatibility` is enabled (we use default `false`).

**Limitations:**

- Protection is **OS-user-scoped** (DPAPI / Credential Manager), not verified TPM-only hardware isolation for every deployment.
- Secrets remain accessible to code running as the same user if the machine is compromised.
- Reinstalling the app or clearing app data can orphan or lose stored values depending on backup and profile state.

## Android

**Mechanism (default `AndroidOptions`):** RSA/ECB/OAEPWithSHA-256AndMGF1Padding wraps an AES key; values use **AES/GCM/NoPadding**. Namespace isolation uses `storageNamespace: com.pakpos.pos.secure` and `preferencesKeyPrefix: pakpos`.

**Requirements:** Plugin v11 expects **API 23+** (Android 6.0+).

**Manifest:** `android:allowBackup="false"` on `<application>` reduces restore-related key unwrap failures (see plugin README).

**Limitations:**

- Factory reset, uninstall, or backup/restore misconfiguration can make stored values unreadable.
- Optional biometric modes are not enabled in Phase 4.2.

## Unsupported platforms

- **Web:** Factory throws `SecureStorageUnsupportedPlatformException` without calling the web implementation (avoids browser “secure” storage that is not in Pak POS’s threat model for this phase).
- **iOS, macOS, Linux, Fuchsia:** Explicit unsupported error until product requirements include them.

## Errors

Typed exceptions in [secure_storage_exceptions.dart](/mobile/lib/core/security/secure_storage_exceptions.dart). Messages include operation names and sanitized codes only—never secret values or raw plugin payloads.

## Testing

[FakeSecureStorageService](/mobile/test/fakes/fake_secure_storage_service.dart) provides deterministic in-memory behavior. Override `secureStorageServiceProvider` in tests.

Unit tests do **not** prove Windows Credential Manager or Android Keystore behavior; they validate the abstraction, fake, provider override, and error mapping with the plugin’s test platform where applicable.

## Backup and reinstallation

Treat secure storage as **device-local**. Users may lose credentials after reinstall, profile wipe, or failed Android backup restore. Recovery flows belong to later authentication phases.
