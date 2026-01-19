---
title: Add visual effect particles for status effects
status: open
priority: 3
issue-type: task
assignee: randroid
created-at: 2026-01-07T00:18:33.988475-06:00
---

## Parent Task
GoPit-5tv (Visual Effects Polish)

## Description

Add visual particle effects for status effects that are currently missing particles.

## Context

Status effects provide important gameplay feedback. Currently, 4 of 9 status effects have visual particles (burn, freeze, poison, bleed). The remaining 5 need particles for visual consistency.

## Affected Files

### New Files
- `scenes/effects/radiation_particles.tscn` - Yellow-green glow/sparks
- `scenes/effects/disease_particles.tscn` - Purple/sickly particles
- `scenes/effects/frostburn_particles.tscn` - Ice-blue fading particles
- `scenes/effects/wind_particles.tscn` - Light green-white swirl
- `scenes/effects/charm_particles.tscn` - Pink hearts/sparkles

### Modify
- `scripts/entities/enemies/enemy_base.gd:45-49` - Add preload constants for new particle scenes
- `scripts/entities/enemies/enemy_base.gd` - Add spawning logic in `_spawn_effect_particles()`

## Current Implementation

```gdscript
# enemy_base.gd lines 45-49
const BURN_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/burn_particles.tscn")
const FREEZE_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/freeze_particles.tscn")
const POISON_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/poison_particles.tscn")
const BLEED_PARTICLES_SCENE: PackedScene = preload("res://scenes/effects/bleed_particles.tscn")
```

## Particle Design Guidelines

Reference existing particles for consistency:
- Use GPUParticles2D for performance
- Keep particle counts low (8-16 particles)
- Match colors from `status_effect.gd:get_color()`
- Duration should match effect duration or loop

## Status Effect Colors (from status_effect.gd)

| Effect | Color | Visual Theme |
|--------|-------|--------------|
| Radiation | Yellow-green (0.5, 1.5, 0.2) | Toxic glow |
| Disease | Purple (0.6, 0.3, 0.8) | Sickly |
| Frostburn | Pale blue (0.3, 0.6, 1.2) | Ice fading |
| Wind | Light green-white (0.8, 1.0, 0.8) | Airy swirl |
| Charm | Pink (1.0, 0.4, 0.8) | Hearts |

## Verify

- [ ] `./test.sh` passes
- [ ] Each new status effect shows visible particles when applied
- [ ] Particles match the color theme of each effect
- [ ] Performance is acceptable with multiple affected enemies
- [ ] Particles stop when effect expires
