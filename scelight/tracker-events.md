---

## Scelight tracker events: three API traps for player and unit identification

**ID:** GE-20260412-fec397
**Stack:** Scelight scelight-s2protocol, SC2 replay parsing, Java
**Symptom:**
1. Filtering `PlayerStatsEvent` by `event.getUserId()` silently applies no stats — all tracker events return `userId = -1`.
2. Casting a UnitDied event (id=2) to `IBaseUnitEvent` throws `ClassCastException: Event cannot be cast to IBaseUnitEvent` at runtime.
3. `UnitDoneEvent` Javadoc says "appears with the same unit tag" but the interface has no typed accessor for it — raw struct access required.

**Context:** When consuming SC2 replay tracker events via the Scelight Java API (scelight-s2protocol).

### What was tried (didn't work)
- Used `event.getUserId() == watchedPlayerId - 1` to filter `PlayerStatsEvent` — silently matched nothing; minerals stayed 0
- Cast tracker event id=2 to `IBaseUnitEvent` to read `getUnitTagIndex()` — ClassCastException at runtime
- Expected typed `UnitDoneEvent` accessors for unit tag per Javadoc — methods don't exist

### Root cause
1. `Protocol.decodeTrackerEvents()` calls `decodeEventStream(..., decodeUserId=false, ...)` — the decoder hard-codes `userId = -1` for the entire tracker stream. Player identity in tracker events uses a `playerId` struct field, not `userId`. Call `event.getPlayerId()` (1-indexed player ID).
2. `TrackerEventFactory` creates typed classes for ids 0,1,5,6,7,9 but has no case for id=2 (UnitDied) — falls through to `super.create()` returning plain `Event`. The source has a `// TODO` but the typed class was never added.
3. `UnitDoneEvent extends Event` (not `BaseUnitEvent`) — the typed unit tag interface was never implemented. The raw struct contains `unitTagIndex`/`unitTagRecycle` accessible via `StructView.get()`.

### Fix
```java
// 1. Identify player — use getPlayerId() not getUserId() for tracker events
if (event.getId() == ITrackerEvents.ID_PLAYER_STATS) {
    Integer playerId = event.getPlayerId(); // 1-indexed; userId is always -1 for tracker stream
    if (playerId != null && playerId == watchedPlayerId) {
        IPlayerStatsEvent stats = (IPlayerStatsEvent) event;
        setMinerals(stats.getMineralsCurrent());
    }
}

// 2. UnitDied — plain Event, access tag via raw struct
if (event.getId() == ITrackerEvents.ID_UNIT_DIED) {
    Event e = event; // NOT (IBaseUnitEvent) event — ClassCastException
    Integer tagIndex   = e.get("unitTagIndex");
    Integer tagRecycle = e.get("unitTagRecycle");
}

// 3. UnitDone — same raw struct approach (Javadoc promises typed access, unimplemented)
if (event.getId() == ITrackerEvents.ID_UNIT_DONE) {
    Event e = event;
    Integer tagIndex   = e.get("unitTagIndex");
    Integer tagRecycle = e.get("unitTagRecycle");
}
```

### Why this is non-obvious
`IEvent` declares `getUserId()` on every event — it's the natural first pick to identify players. Nothing warns that the tracker stream hard-codes -1; the `decodeUserId=false` flag is buried inside `Protocol.decodeTrackerEvents()`. `IBaseUnitEvent` is implemented for UnitBorn and UnitInit, so you'd expect UnitDied to follow the same pattern — but `TrackerEventFactory` has a silent gap (source says `// TODO`). `UnitDoneEvent` Javadoc explicitly states "appears with the same unit tag" but the implementation is unfinished with `// TODO` and no accessors — contradicts its own documentation.
