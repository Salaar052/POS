# Mobile onboarding and launch policy (Phase 4.5 / 4.5.2)

## Launch destinations

The app resolves a single launch destination before allowing shell routes (`/`, `/pos`, etc.).

| Destination | Meaning |
|-------------|---------|
| Welcome | No READY business in the bootstrap registry |
| Provisioning recovery | Remote registration succeeded; local SQLite setup must be retried |
| Owner pending verification | Post–Phase 4.5 registration; not authenticated |
| Legacy access required | Pre–4.5 READY local business; sign-in not implemented yet |
| Local database recovery | Registry/onboarding state OK but business file could not be opened |
| Snapshot / secure-storage errors | Fail-closed; SQLite files are not modified |

**Main shell (`mainApp`)** is reserved for authenticated sessions (Phase 4.6+). Release builds do not use it until login exists.

## Legacy READY businesses

Installations with a READY registry entry but **no** `pakpos.onboarding.owner_pending` snapshot are **not** treated as `PENDING_VERIFICATION`. They see **Sign-in required** instead. Data on disk is preserved; POS routes are blocked.

## Secure storage

- Keys: `pakpos.onboarding.provisioning_recovery`, `pakpos.onboarding.owner_pending`
- Never stores passwords, tokens, or password hashes
- Corrupt JSON is **not** auto-deleted; launch fails with a support-oriented message
- Read failures fail closed (never `mainApp`)

Provisioning recovery takes precedence over owner pending when both are present.

## Bootstrap

1. Open bootstrap SQLite (`local.sqlite`) — required for launch resolution
2. Open business SQLite **only** when a valid owner-pending snapshot exists (post-registration path)
3. Business open failures set `BootstrapLaunchIssue` but do not abort bootstrap; launch moves to local-database recovery when appropriate

## API configuration

| Build | `API_BASE_URL` |
|-------|----------------|
| Debug | May omit; defaults to `http://127.0.0.1:3000` |
| Release/profile | **Required** via `--dart-define=API_BASE_URL=https://...` |
| Release | HTTPS only; localhost / loopback rejected |

Validated in `main()` before `PakPosApp` starts.

## Authentication (deferred)

Login, JWT, refresh tokens, email verification delivery, and device activation are **not** implemented. Route blocking is launch-policy only, not full authorization.
