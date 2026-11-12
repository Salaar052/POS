# Business registration API (Phase 4.4)

Public endpoint to create a business, owner user, OWNER membership, and registration audit event in one transaction. **No login, session, or device is created.**

## Endpoint

`POST /businesses/register`

**Status:** `201 Created` on success.

### Request body

| Field | Required | Notes |
|-------|----------|--------|
| `businessName` | Yes | 2–200 chars |
| `ownerName` | Yes | 2–200 chars |
| `ownerEmail` | Yes | Valid email; normalized to lowercase for uniqueness |
| `password` | Yes | Min 12 chars, at least one letter and one number |
| `businessPhone` | No | Maps to `Business.phone` |
| `businessEmail` | No | Maps to `Business.email` |

Unknown fields (e.g. `businessId`, `role`) are rejected with `400`.

There are **no** address/city/country fields on the current schema.

### Example

```json
{
  "businessName": "Karachi Electronics",
  "businessPhone": "+923001234567",
  "ownerName": "Ali Khan",
  "ownerEmail": "ali@example.com",
  "password": "my-secure-pass-12"
}
```

### Success response

```json
{
  "business": {
    "id": "uuid",
    "name": "Karachi Electronics",
    "phone": "+923001234567",
    "email": null,
    "currencyCode": "PKR",
    "timezone": "Asia/Karachi",
    "status": "ACTIVE",
    "createdAt": "2026-11-10T10:00:00.000Z"
  },
  "owner": {
    "id": "uuid",
    "name": "Ali Khan",
    "email": "ali@example.com",
    "status": "PENDING_VERIFICATION",
    "createdAt": "2026-11-10T10:00:00.000Z"
  },
  "membership": {
    "id": "uuid",
    "role": "OWNER",
    "status": "ACTIVE"
  }
}
```

Passwords and password hashes are **never** returned.

### Errors

| Code | When |
|------|------|
| `400` | Validation failure (email, password, unknown fields) |
| `409` | Duplicate owner email (`normalizedEmail` unique) |
| `500` | Unexpected registration failure (transaction rolled back) |

Duplicate email messages do not reveal other businesses’ data.

## Security

- Passwords hashed with **Argon2id** (`PasswordHashingService`) before insert.
- Registration audit metadata uses safe keys only (`registrationChannel`).
- `AuditLog` remains append-only at the database layer.

## Deferred

Login, refresh tokens, devices, email verification, Flutter UI — later phases.

See [identity-phase-4.3.md](./identity-phase-4.3.md#future-authentication-requirements-phase-48) for how user verification, membership, and tenancy interact after login is implemented.

## Integration tests (Phase 4.4.2)

PostgreSQL integration tests require **`TEST_DATABASE_URL`** (dedicated test DB, not `DATABASE_URL`). Run:

```bash
cd server
npm run test:integration
```

Tests are **skipped** when `TEST_DATABASE_URL` is unset or fails the test-database guard.
