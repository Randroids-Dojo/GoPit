# Enemy Movement & Formations Research: BallxPit vs GoPit

Research conducted: January 2026

## Executive Summary

BallxPit (level 1: Bone x Yard) features a scrolling arena where enemies descend in organized formations. GoPit currently spawns enemies individually at random positions with occasional formations. To match BallxPit's feel, GoPit needs:

1. **Formation-first spawning** - Most spawns should be formations, not singles
2. **Row-based patterns** - Horizontal lines that descend together
3. **Consistent descent** - All formation enemies move as a cohesive unit
4. **Sequential waves** - Predictable patterns players can learn

## BallxPit Level 1 (Bone x Yard) Characteristics

### Enemy Types
| Enemy | Health | Notes |
|-------|--------|-------|
| Skeleton Warrior | x1 | Base enemy, descends straight down |
| Skeletal Archer | x1 | Ranged, fires projectiles |
| Skeletal Brute | x3 | Tanky, slower descent |

### Spawn Patterns (Observed)
Based on gameplay analysis and genre conventions:

1. **Horizontal Rows** - 3-5 enemies in a line, descending together
2. **Staggered Rows** - Two offset rows creating a checkerboard pattern
3. **V-Formations** - Arrow shape pointing down at player
4. **Wall Formations** - 2-3 rows filling screen width
5. **Mixed Type Rows** - Warriors flanking an Archer in center

### Movement Characteristics
- **Continuous scroll** - Screen scrolls upward ~50-100 px/sec
- **Enemy descent** - Enemies move down relative to screen
- **No lateral movement** - Basic enemies descend straight (level 1)
- **Formation cohesion** - Enemies in a formation maintain relative positions

### Timing
- Level 1 is ~15-20 minutes on Normal difficulty
- Early waves: sparse, single enemy types
- Mid waves: formations appear, mixed types
- Boss waves: mini-bosses at waves 15, 30; final boss at wave 45

## Current GoPit Implementation

### Spawning (enemy_spawner.gd)
- `formation_chance: 0.15` - Only 15% of spawns are formations
- `burst_chance: 0.1` - 10% chance for 2-3 random position spawns
- Default: Single enemy at random X position

### Available Formations
| Formation | Description | Usage |
|-----------|-------------|-------|
| LINE | Horizontal row | 15% of spawns |
| V_SHAPE | Arrow pointing down | 15% of spawns |
| CLUSTER | Tight random group | Not used in random |
| DIAGONAL | Slanted line | 15% of spawns |

### Gap Analysis

| Aspect | BallxPit | GoPit | Gap |
|--------|----------|-------|-----|
| Formation frequency | ~70% | 15% | Too rare |
| Row formations | Primary pattern | One of four | Under-represented |
| Staggered rows | Common | Not implemented | Missing |
| Wall formations | Common | Not implemented | Missing |
| Mixed-type formations | Yes | No | All same type |
| Formation cohesion | Tight, organized | Varies | Inconsistent |

## Recommendations

### 1. Increase Formation Frequency
```gdscript
# Current
formation_chance: float = 0.15

# Recommended
formation_chance: float = 0.60  # 60% of spawns are formations
```

### 2. Add New Formation Types

**STAGGERED_ROWS** - Two rows with offset positions
```
  O   O   O   O
    O   O   O
```

**WALL** - Dense horizontal barrier
```
O O O O O O O
O O O O O O O
```

**ARROW** - V pointing at player (inverted current V)
```
    O
  O   O
O       O
```

### 3. Implement Mixed-Type Formations
- Center enemy can be different type (Archer among Warriors)
- Tank enemies at front of formation
- Fast enemies on flanks

### 4. Formation-Specific Spawn Logic
```gdscript
# Wave 1-5: Single rows, same type
# Wave 6-10: V-formations, introduce second type
# Wave 11-15: Staggered rows, mixed types
# Wave 16+: Walls, full variety
```

### 5. Wave-Based Progression
Rather than random chance, use deterministic wave patterns:
```gdscript
var wave_patterns = [
    [Formation.LINE, 3],      # Wave 1: Line of 3
    [Formation.LINE, 4],      # Wave 2: Line of 4
    [Formation.V_SHAPE, 5],   # Wave 3: V of 5
    [Formation.STAGGERED, 6], # Wave 4: Staggered 6
    # etc.
]
```

## Implementation Priority

1. **Add STAGGERED and WALL formations** - Most impactful visual change
2. **Increase formation_chance to 60%** - Quick win
3. **Add mixed-type support** - Tactical depth
4. **Wave-based pattern system** - Long-term improvement

## Sources

- [Ball x Pit Ultimate Beginner's Guide](https://gam3s.gg/ball-x-pit/guides/ball-x-pit-ultimate-beginners-guide/)
- [Ball x Pit Beginner's Guide - NeonLightsMedia](https://www.neonlightsmedia.com/blog/ball-x-pit-beginners-guide)
- [Ball x Pit Wiki - Levels](https://ballxpit.wiki.gg/wiki/Levels)
- [Ball x Pit Tips & Tricks](https://ballxpit.org/guides/tips-tricks/)
- Genre conventions from Breakout, Space Invaders, and bullet-hell games
