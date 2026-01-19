---
title: Add visual effect particles for status effects
status: closed
priority: 3
issue-type: task
assignee: randroid
created-at: "2026-01-07T00:18:33.988475-06:00"
closed-at: "2026-01-19T09:43:35.199197-06:00"
close-reason: Added 5 new particle scenes (radiation, disease, frostburn, wind, charm) and integrated them into enemy_base.gd
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
- `scripts/entities/enemies/enemy_base.gd:46-49` - Add preload constants for new particle scenes
- `scripts/entities/enemies/enemy_base.gd:771-780` - Add cases in `_ensure_effect_particles()`

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
- Keep particle counts low (6-8 particles)
- Match colors from `scripts/effects/status_effect.gd:get_color()` (lines 137-158)
- Use lifetime 0.5-0.8 seconds with emitting=true (continuous)
- Use emission_sphere_radius 15-20 for spread

### Existing Pattern Example (burn_particles.tscn)

```tscn
[gd_scene load_steps=2 format=3 uid="uid://burn_particles"]

[sub_resource type="ParticleProcessMaterial" id="ParticleProcessMaterial_burn"]
emission_shape = 1
emission_sphere_radius = 15.0
direction = Vector3(0, -1, 0)
spread = 30.0
initial_velocity_min = 20.0
initial_velocity_max = 40.0
gravity = Vector3(0, -50, 0)
scale_min = 2.0
scale_max = 4.0
color = Color(1, 0.5, 0.1, 0.8)

[node name="BurnParticles" type="GPUParticles2D"]
amount = 6
process_material = SubResource("ParticleProcessMaterial_burn")
lifetime = 0.5
speed_scale = 1.5
```

### Implementation Steps

1. Create 5 new .tscn files following the pattern above
2. Customize each with appropriate colors from get_color()
3. Adjust motion (direction, gravity, spread) for visual theme:
   - Radiation: pulsing outward glow
   - Disease: slow dripping down
   - Frostburn: slow rising ice mist
   - Wind: circular swirling motion
   - Charm: floating hearts upward
4. Add preload constants to enemy_base.gd (after line 49)
5. Add match cases to `_ensure_effect_particles()` (after line 780)

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
