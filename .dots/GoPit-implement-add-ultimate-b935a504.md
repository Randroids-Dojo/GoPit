---
title: "implement: Add Ultimate Ability (extracted from stale salvo-firing branch)"
status: open
priority: 2
issue-type: task
created-at: "2026-01-19T11:39:02.789967-06:00"
---

## Description

Add the Ultimate ability feature to main by extracting code from the stale `feature/salvo-firing` branch. This is a screen-clearing ability that charges through enemy kills and gem collection.

## Context

The Ultimate ability was fully implemented in the salvo-firing branch, but that branch is 90+ commits behind main and cannot be merged. This spec provides the exact code to add based on research into the salvo-firing implementation.

## Affected Files

### NEW FILES (copy from salvo-firing)

1. `scripts/effects/ultimate_blast.gd`
2. `scripts/ui/ultimate_button.gd`  
3. `scenes/effects/ultimate_blast.tscn`
4. `scenes/ui/ultimate_button.tscn`

### MODIFY FILES

5. `scripts/autoload/game_manager.gd` - Add ultimate charge system
6. `scripts/autoload/sound_manager.gd` - Add ULTIMATE sound type
7. `scripts/game/game_controller.gd` - Wire charge gain and activation
8. `scenes/game.tscn` - Add ultimate button to UI

## Implementation Notes

### 1. NEW: scripts/effects/ultimate_blast.gd

Copy directly from salvo-firing branch:
```bash
git show feature/salvo-firing:scripts/effects/ultimate_blast.gd > scripts/effects/ultimate_blast.gd
```

### 2. NEW: scripts/ui/ultimate_button.gd

Copy directly from salvo-firing branch:
```bash
git show feature/salvo-firing:scripts/ui/ultimate_button.gd > scripts/ui/ultimate_button.gd
```

### 3. NEW: scenes/effects/ultimate_blast.tscn

Copy directly from salvo-firing branch:
```bash
git show feature/salvo-firing:scenes/effects/ultimate_blast.tscn > scenes/effects/ultimate_blast.tscn
```

### 4. NEW: scenes/ui/ultimate_button.tscn

Copy directly from salvo-firing branch:
```bash
git show feature/salvo-firing:scenes/ui/ultimate_button.tscn > scenes/ui/ultimate_button.tscn
```

### 5. MODIFY: scripts/autoload/game_manager.gd

Add after line 26 (after `signal leadership_changed`):
```gdscript
signal ultimate_ready
signal ultimate_used
signal ultimate_charge_changed(current: float, max_val: float)
```

Add after line 105 (after `var life_steal_percent`):
```gdscript
# Ultimate ability system
const ULTIMATE_CHARGE_MAX: float = 100.0
const CHARGE_PER_KILL: float = 10.0
const CHARGE_PER_GEM: float = 5.0
var ultimate_charge: float = 0.0
```

Add new methods (near other ability methods):
```gdscript
func add_ultimate_charge(amount: float) -> void:
    var was_ready := is_ultimate_ready()
    ultimate_charge = minf(ULTIMATE_CHARGE_MAX, ultimate_charge + amount)
    ultimate_charge_changed.emit(ultimate_charge, ULTIMATE_CHARGE_MAX)
    if not was_ready and is_ultimate_ready():
        ultimate_ready.emit()


func use_ultimate() -> bool:
    if is_ultimate_ready():
        ultimate_charge = 0.0
        ultimate_used.emit()
        ultimate_charge_changed.emit(0.0, ULTIMATE_CHARGE_MAX)
        return true
    return false


func is_ultimate_ready() -> bool:
    return ultimate_charge >= ULTIMATE_CHARGE_MAX


func get_special_fire_multiplier() -> int:
    # Empty Nester passive: 2x special abilities
    if has_passive(Passive.EMPTY_NESTER):
        return 2
    return 1
```

Add to reset() function:
```gdscript
ultimate_charge = 0.0
```

### 6. MODIFY: scripts/autoload/sound_manager.gd

Add to SoundType enum (after FISSION):
```gdscript
ULTIMATE,        # Screen-clearing blast
```

Add to SOUND_SETTINGS dict:
```gdscript
SoundType.ULTIMATE: {"pitch_var": 0.0, "vol_var": 0.0},
```

Add sound generator function (after _generate_energy_burst):
```gdscript
func _generate_ultimate_blast_sound() -> PackedByteArray:
    """Ultimate ability: Epic power blast with rising tone and explosion"""
    var samples := int(SAMPLE_RATE * 0.6)
    var data := PackedByteArray()
    data.resize(samples)
    
    for i in samples:
        var t := float(i) / SAMPLE_RATE
        var progress := float(i) / samples
        
        # Rising tone followed by explosion
        var freq: float
        var sample: float
        
        if progress < 0.3:
            # Rising phase
            freq = 200.0 + progress * 1000.0
            sample = sin(t * TAU * freq)
        else:
            # Explosion phase
            freq = 80.0
            var explosion := sin(t * TAU * freq) * (1.0 - (progress - 0.3) / 0.7)
            var noise := randf_range(-0.5, 0.5) * (1.0 - progress)
            sample = explosion + noise
        
        # Envelope
        var envelope := 1.0
        if progress > 0.7:
            envelope = 1.0 - (progress - 0.7) / 0.3
        
        sample *= envelope * 0.7
        data[i] = int(clampf(sample * 127.0 + 128.0, 0.0, 255.0))
    
    return data
```

Add case to _generate_sound match statement:
```gdscript
SoundType.ULTIMATE:
    data = _generate_ultimate_blast_sound()
```

### 7. MODIFY: scripts/game/game_controller.gd

Add to _on_enemy_died (or equivalent):
```gdscript
GameManager.add_ultimate_charge(GameManager.CHARGE_PER_KILL)
```

Add to _on_gem_collected (or equivalent):
```gdscript
GameManager.add_ultimate_charge(GameManager.CHARGE_PER_GEM)
```

Add ultimate activation handler:
```gdscript
func _on_ultimate_activated() -> void:
    var blast_scene: PackedScene = load("res://scenes/effects/ultimate_blast.tscn")
    var multiplier: int = GameManager.get_special_fire_multiplier()
    for i in range(multiplier):
        var blast: Node2D = blast_scene.instantiate()
        add_child(blast)
        blast.execute()
        if i < multiplier - 1:
            await get_tree().create_timer(0.2).timeout
```

### 8. MODIFY: scenes/game.tscn

Add UltimateButton to UI node hierarchy (near FireButton).

## Post-Implementation: Clean Up Stale Branch

After this is merged:
```bash
git push origin --delete feature/salvo-firing
git branch -D feature/salvo-firing
rm -rf GoPit-salvo-firing/
```

## Verify

- [ ] `./test.sh` passes
- [ ] Ultimate charge increases when killing enemies
- [ ] Ultimate charge increases when collecting gems
- [ ] UI shows charge progress (ring visualization)
- [ ] UI pulses when ultimate is ready (charge = 100%)
- [ ] Tapping ultimate button activates blast
- [ ] All enemies on screen take 9999 damage
- [ ] White flash effect plays
- [ ] Screen shake occurs
- [ ] Sound effect plays
- [ ] Charge resets to 0 after use
- [ ] Empty Nester character triggers double blast
- [ ] Cannot activate when charge < 100%
