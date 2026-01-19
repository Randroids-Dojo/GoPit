---
title: Add fusion system dedicated tests
status: open
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-08T19:57:16.51316-06:00
---

## Description

Add PlayGodot tests for the fusion/evolution system.

## Context

The fusion system allows balls to evolve into more powerful forms. Key components:
- `FusionRegistry` autoload manages evolution recipes and lookups
- `ball.gd` handles evolved ball effects (lightning, explosion, void, etc.)
- Evolution triggers during gameplay based on level-up choices

Currently no dedicated tests verify this system works correctly.

## Affected Files

- NEW: `tests/test_fusion.py` - New test file
- Uses: `scripts/autoload/fusion_registry.gd`
- Uses: `scripts/entities/ball.gd` (evolved effects)

## Test Coverage Needed

### FusionRegistry Tests
1. **Recipe lookup** - `get_evolution()` returns correct evolved type for ball combinations
2. **Invalid combinations** - Returns null for non-fusable combinations
3. **Level requirements** - Evolution only available at correct level

### Evolved Ball Effects
1. **Lightning chain** - Hits multiple enemies in range
2. **Explosion** - Deals area damage on impact
3. **Void** - Alternates burn/freeze effects
4. **Glacier** - Applies freeze, increases pierce
5. **Nova** - Explodes and spawns baby balls
6. **Other evolved types** - Verify each has expected behavior

### Evolution Flow
1. **Level-up triggers evolution** - When choosing evolution upgrade
2. **Ball type changes** - `is_evolved` flag set, `evolved_type` assigned
3. **Visual changes** - Ball appearance reflects evolution

## Implementation Notes

```python
@pytest.mark.asyncio
async def test_fusion_registry_lookup(game):
    """Verify FusionRegistry returns correct evolution for ball combo."""
    # Fire + Ice = Void
    result = await game.call("/root/FusionRegistry", "get_evolution", [
        BallType.FIRE, BallType.ICE
    ])
    assert result == EvolvedType.VOID

@pytest.mark.asyncio
async def test_lightning_chain_effect(game):
    """Verify Lightning evolved ball chains to multiple enemies."""
    # Spawn cluster of 3 enemies
    # Fire lightning ball at first enemy
    # Verify damage dealt to all 3
```

## Verify

- [ ] `./test.sh tests/test_fusion.py` passes
- [ ] Tests cover FusionRegistry lookups
- [ ] Tests cover at least 3 evolved ball effects
- [ ] No flaky tests
