# Enemy Comparison: BallxPit vs GoPit

Research conducted: January 2026

## BallxPit Enemy Data

### Enemy Types (from wiki.gg)

| Enemy | Health Scale | Notes |
|-------|-------------|-------|
| Skeleton Warrior | x1 | Base enemy |
| Skeletal Archer | x1 | Ranged attacks |
| Skeletal Brute | x3 | Tanky variant |
| Skeletal Beast | x3 | Tanky variant |
| Skeletal Bishop | x4 | Support/caster type |
| Skeletal Bastion | x6 | Heavy tank |

**Note:** Health scales are multipliers, not absolute HP values. Base HP value is undocumented.

### Level-Specific Enemies

- **Coast x Snowfalls**: Mounted enemies (multi-phase kills)
- **Hot Depths**: Fire-throwing enemies, lava hazards
- **Heavenly Gates**: Flying/jumping enemies, guided projectiles

### Boss Structure

- 8 stages total
- 3 bosses per stage (2 mini-bosses + 1 final)
- 24 total bosses

**Major Bosses:**
| Boss | Stage | Notable Mechanic |
|------|-------|------------------|
| Skeleton King | Bone Yard | Crown weak point, arrow barrages |
| Shroom Swarm | Fungal Forest | Multiple enemies sharing HP bar |
| Dragon Prince | Smoldering Depths | Low HP, adds provide ricochets |
| Twisted Serpent | Liminal Desert | Multi-phase, poison damage |
| Icebound Queen | Snowy Shores | Ice walls block attacks |
| Sabertooth | Gory Grasslands | Aggressive, high speed/damage |
| Lord of Owls | Heavenly Gates | Flying, requires grounding |
| The Moon | Vast Void | Final boss, very tanky |

### Damage Mechanics (BallxPit)

| Effect | Damage | Stacking |
|--------|--------|----------|
| Hemorrhage | 20% current HP | Triggers at 12+ bleed stacks |
| Radiation | +10% damage/stack | Max 5 stacks (50% amp) |
| Frostburn | +25% damage | Flat bonus |
| Burn | 5 dmg/sec/stack | Max 5 stacks (25 dps) |
| Bomb | 40 base AoE | Up to 280 with ricochets |
| Nuclear Bomb | 300-500 | Initial explosion |

### Scaling (BallxPit)

- NG+ adds +50% HP and +50% damage
- After boss waves: ~3x HP jump
- Wave 30+: Exponential HP scaling
- Wave 50+: Only percentage-based damage viable

---

## GoPit Current Stats

### Regular Enemies

| Enemy | HP | HP Mult | Speed | Speed Mult | Damage |
|-------|-----|---------|-------|------------|--------|
| Slime (base) | 10 | 1.0x | 100 | 1.0x | 10 |
| Bat | 10 | 1.0x | 130 | 1.3x | 10 |
| Crab | 15 | 1.5x | ~60 | 0.6x | 10 |
| Golem | 30 | 3.0x | 60 | 0.6x | 15 |
| Swarm | 4 | 0.4x | 100 | 1.0x | 6 |
| Bomber | 6 | 0.6x | 100 | 1.0x | 3* |
| Archer | 12 | 1.2x | 100 | 1.0x | 5** |

*Bomber: Low contact damage, explosion deals 20 to enemies, 15 to player
**Archer: Low melee, fires projectiles at 5 damage

### Bosses

| Boss | HP | Primary Attack | Special |
|------|-----|----------------|---------|
| Slime King | 500 | 30 slam | Crown weak point (2x) |
| Frost Wyrm | 600 | 20 breath | Icicles (15), Blizzard DoT |
| Sand Golem | 800 | 35 slam | Boulders (25), Sandstorm |
| Void Lord | 1000 | 40 beam | Orbs (20), Nova (50) |

### GoPit Scaling

- HP: +10% per wave
- Speed: +5% per wave (capped at 2x)
- Post-boss HP multiplier from StageManager

---

## Gap Analysis

### HP Comparison

| Aspect | BallxPit | GoPit | Gap |
|--------|----------|-------|-----|
| Base enemy HP | Unknown (x1) | 10 | Cannot compare |
| Tank multiplier | x3-x6 | x1.5-x3 | GoPit tanks less tanky |
| HP scaling | ~3x jumps after bosses | +10%/wave | GoPit more gradual |
| Late-game | Percentage damage required | Linear scaling | Different design |

### Enemy Type Comparison

| BallxPit Has | GoPit Has | Missing |
|--------------|-----------|---------|
| Skeleton variants | Slime/bat/crab | Skeleton theme |
| Ranged (Archer) | Archer | Parity |
| Heavy tanks (Bastion) | Golem | Similar |
| Mounted (multi-phase) | - | Multi-phase enemies |
| Flying/jumping | Bat (semi) | True flying enemies |
| Fire-throwing | - | Ranged elemental |

### Damage System Comparison

| Feature | BallxPit | GoPit | Notes |
|---------|----------|-------|-------|
| Hemorrhage | 20% current HP | 20% current HP | Identical |
| Radiation amp | +10%/stack (50% max) | +10%/stack (50% max) | Identical |
| Frostburn amp | +25% flat | +25% flat | Identical |
| Bleed threshold | 12 stacks | 12 stacks | Identical |

GoPit has already implemented the core BallxPit damage mechanics.

---

## Recommendations

### 1. HP Values - No Change Needed
GoPit's base 10 HP works well for the action pace. The relative multipliers (tank = 3x, swarm = 0.4x) provide good variety.

### 2. Consider Adding
- **Flying enemies**: True flying enemies that require specific timing
- **Multi-phase enemies**: Enemies that change behavior at HP thresholds
- **Ranged elemental enemies**: Fire/ice projectile shooters

### 3. Scaling Adjustments
Consider adding larger HP jumps after boss waves to match BallxPit's difficulty curve. Current +10%/wave may feel too gradual.

### 4. Keep Current System
- Hemorrhage at 12 stacks = BallxPit parity
- Damage amplification = BallxPit parity
- Status effects = BallxPit parity

---

## Sources

- [BALL x PIT Wiki (wiki.gg)](https://ballxpit.wiki.gg/)
- [BallxPit.org Guides](https://ballxpit.org/guides)
- [Boss Battle Strategies Guide](https://ballxpit.org/guides/boss-battle-strategies/)
- [Advanced Mechanics Guide](https://ballxpit.org/guides/advanced-mechanics/)
- [Steam Community Discussions](https://steamcommunity.com/app/2062430/discussions/)
- [TheGamer Boss Rankings](https://www.thegamer.com/ball-x-pit-hardest-area-bosses-to-beat/)
