## feat(world): extract WorldStateManager for time and bell state

Closes #3

## Summary

Moved all world-time and bell-toll logic out of `main.gd` and into a dedicated `WorldStateManager` node (`scripts/world/world_state_manager.gd`). The main scene now reads a single source of truth for time, day count, and bell state instead of owning scattered timing vars and private helpers.

## Changes

**`scripts/world/world_state_manager.gd`** (new)
- Owns `day_number`, `day_timer`, and all bell state (`_last_bell_hour`, `_pending_tolls`, `_toll_cooldown`, `_bell_player`)
- Exposes `tick(delta)` — called once per frame from `_process`; advances the clock and fires bell strikes
- Read-only helpers: `get_cycle_progress()`, `get_current_hour()`, `get_pending_tolls()`, `format_clock_time()`
- `get_world_state(social_hub_position)` returns the canonical dict consumed by NPC brains (no change to dict shape)
- `set_time_to_hour(hour)` for dev-time jump
- `setup_bell_audio()` attaches `AudioStreamPlayer` as a child

**`scripts/main.gd`** (modified)
- Removed: `DAY_DURATION_SECONDS`, `day_number`, `day_timer`, `bell_player`, `_last_bell_hour`, `_pending_tolls`, `_toll_cooldown`, `_TOLL_INTERVAL`, `_BELL_SCHEDULE`, `_tick_bell()`, `_setup_bell_audio()`, `_format_clock_time()`
- `_ready` creates and adds `WorldStateManager`; calls `setup_bell_audio()` on it
- `_process` calls `world_state.tick(delta)` and reads `get_cycle_progress()` — no direct timing mutation remains
- `_update_npc_schedules` delegates world-state dict construction to `world_state.get_world_state()`
- `_update_day_night` reads `world_state.day_number` and `world_state.format_clock_time()`
- `_set_time_to_hour` delegates to `world_state.set_time_to_hour()`

## Acceptance Criteria Verification

- [x] World time, bell state, and derived facts exposed by `WorldStateManager` API
- [x] Main loop delegates to world-state manager with no behavior regression
- [x] Legacy schedule logic still works (NPC schedule dict shape unchanged)
- [x] No direct timing/bell mutation remains in main orchestration outside world-state module
