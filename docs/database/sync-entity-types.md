# Sync entity types (Phase 2 baseline)

Phase 10 will upload `sync_operations` by `entity_type` / `operation_type` / `payload_json`.

## Phase 2 types

| entity_type | operation_type | Notes |
|-------------|----------------|--------|
| `app_setting` | `update` | Settings change enqueue |

## Rules (ADR-0001)

| Domain | Delete semantics |
|--------|------------------|
| Master data (Phase 5+) | `tombstone` + soft delete |
| Financial (Phase 6+) | No DELETE/tombstone; compensating operations only |

## Queue status (text)

`pending`, `blocked`, `in_flight`, `acknowledged`, `failed_retryable`, `failed_terminal`, `reconciliation_required`

Dependencies: dependents stay `blocked` until parent is `acknowledged`. Failed parents keep dependents blocked; operations are never deleted.

## Dependency cycles

Cycle prevention uses **layers**, not only enqueue-time graph walking:

| Layer | Role |
|-------|------|
| SQLite | Self-dependency blocked on INSERT/UPDATE (`depends_on_operation_id = operation_id`) |
| SQLite | `depends_on_operation_id` is **immutable** after insert (sync identity trigger) |
| Repository | `_assertNoDependencyCycle` walks ancestors when enqueueing (guards preset `operation_id` and deep chains) |

Retroactive multi-hop cycles (e.g. A→B then editing A to depend on B) are **not possible** because `depends_on` cannot change after the row is written.
