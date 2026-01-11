# Godot Input Best Practices

This document captures best practices for handling input in Godot 4.x, including keyboard, touch, and gamepad support.

## Table of Contents

- [Input Map Philosophy](#input-map-philosophy)
- [Keyboard Controls Reference](#keyboard-controls-reference)
- [Input Architecture](#input-architecture)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Resources](#resources)

---

## Input Map Philosophy

The InputMap is more than just a key assignment feature - it's a design philosophy for organizing your game's entire input handling:

1. **Avoid hardcoding keys** - Define actions in Project Settings > Input Map
2. **Use descriptive action names** - `move_left`, `fire`, `toggle_mute` instead of `key_a` or `space`
3. **Assign multiple inputs to actions** - Both touch and keyboard can trigger the same action
4. **Keep game actions separate from UI actions** - Use custom actions for gameplay, built-in `ui_*` for menus

---

## Keyboard Controls Reference

### GoPit Controls

| Action | Key | Category | Description |
|--------|-----|----------|-------------|
| Move Up | W | Movement | Move player upward |
| Move Down | S | Movement | Move player downward |
| Move Left | A | Movement | Move player left |
| Move Right | D | Movement | Move player right |
| Aim Up | Up Arrow | Aiming | Aim balls upward |
| Aim Down | Down Arrow | Aiming | Aim balls downward |
| Aim Left | Left Arrow | Aiming | Aim balls left |
| Aim Right | Right Arrow | Aiming | Aim balls right |
| Fire | Space | Combat | Fire balls (manual mode) |
| Ultimate | E | Combat | Activate ultimate ability |
| Toggle Auto | Tab | Combat | Toggle autofire on/off |
| Mute | M | UI | Toggle sound mute |
| Pause | Escape | UI | Pause/unpause game |

### Design Rationale

- **WASD for movement, Arrows for aim**: Keeps hands in different positions, similar to mouse+keyboard FPS layout
- **Space for fire**: Large, easy-to-hit key for time-critical action
- **Tab for toggle**: Common convention for cycling/toggling states
- **Escape for pause**: Universal game convention, already built into Godot's `ui_cancel`

---

## Input Architecture

### Dual Input System

GoPit supports both touch (mobile) and keyboard (desktop) simultaneously:

```
┌─────────────────────┐     ┌─────────────────────┐
│   Touch/Mouse       │     │     Keyboard        │
│   Virtual Joystick  │     │     WASD/Arrows     │
└─────────┬───────────┘     └─────────┬───────────┘
          │                           │
          └─────────────┬─────────────┘
                        │
              ┌─────────▼─────────┐
              │  game_controller  │
              │  _handle_input()  │
              └─────────┬─────────┘
                        │
          ┌─────────────┴─────────────┐
          │                           │
   ┌──────▼──────┐            ┌───────▼──────┐
   │   Player    │            │ BallSpawner  │
   │ (movement)  │            │   (aiming)   │
   └─────────────┘            └──────────────┘
```

### Input Priority

When both input sources are active:
1. **Joystick takes priority** when `is_dragging` is true
2. **Keyboard fills in** when joystick is released
3. **Actions are additive** - both can trigger fire/ultimate

---

## Best Practices

### 1. Use Input Actions, Not Direct Key Checks

```gdscript
# BAD - hardcoded key
if Input.is_key_pressed(KEY_W):
    move_up()

# GOOD - uses Input Map action
if Input.is_action_pressed("move_up"):
    move_up()
```

### 2. Use `Input.get_vector()` for Movement

```gdscript
# Efficient way to get normalized 2D direction from 4 keys
var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
if move_dir.length() > 0.1:
    player.set_movement_input(move_dir)
```

### 3. Choose the Right Input Method

| Use Case | Method | Why |
|----------|--------|-----|
| Continuous input (movement) | `_process()` with `is_action_pressed()` | Needs checking every frame |
| One-shot actions (fire, jump) | `_unhandled_input()` with `is_action_pressed()` | Only triggers once per press |
| UI navigation | `_unhandled_input()` | Allows UI to consume events first |

### 4. Dead Zones for Analog Input

```gdscript
# Apply dead zone to prevent drift
var dir := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
if dir.length() > 0.1:  # 10% dead zone
    _aim_direction = dir.normalized()
```

### 5. Avoid Conflicts Between Input Sources

```gdscript
# Only apply keyboard movement if joystick isn't active
var move_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
if move_dir.length() > 0.1:
    player.set_movement_input(move_dir)
elif not joystick.is_dragging:
    # Only clear if joystick isn't providing input
    player.set_movement_input(Vector2.ZERO)
```

### 6. Process Mode for Pause Menus

```gdscript
func _ready() -> void:
    # Allow this node to process input even when game is paused
    process_mode = Node.PROCESS_MODE_ALWAYS
```

---

## Common Patterns

### Adding Input Actions in Code

For runtime-configurable controls:

```gdscript
func _ready() -> void:
    # Add action if it doesn't exist
    if not InputMap.has_action("custom_action"):
        InputMap.add_action("custom_action")
        var event := InputEventKey.new()
        event.physical_keycode = KEY_Q
        InputMap.action_add_event("custom_action", event)
```

### Detecting Input Type

```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventKey or event is InputEventMouseButton:
        _using_keyboard = true
    elif event is InputEventScreenTouch or event is InputEventScreenDrag:
        _using_keyboard = false
```

### Rebindable Controls

```gdscript
func rebind_action(action_name: String, new_event: InputEvent) -> void:
    # Clear existing events
    InputMap.action_erase_events(action_name)
    # Add new event
    InputMap.action_add_event(action_name, new_event)
    # Save to config
    _save_keybindings()
```

---

## Resources

- [Godot 4 Recipes - Input Actions](https://kidscancode.org/godot_recipes/4.x/input/input_actions/)
- [Godot 4 Recipes - Adding Input Actions in Code](https://kidscancode.org/godot_recipes/4.x/input/custom_actions/index.html)
- [Official Godot Input Examples](https://docs.godotengine.org/en/latest/tutorials/inputs/input_examples.html)
- [InputMap Management Guide](https://uhiyama-lab.com/en/notes/godot/input-map-key-binding-management/)
- [InputMap Class Reference](https://docs.godotengine.org/en/stable/classes/class_inputmap.html)
