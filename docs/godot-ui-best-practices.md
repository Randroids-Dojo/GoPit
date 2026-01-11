# Godot UI/UX Best Practices

This document captures best practices for building user interfaces in Godot 4.x, learned from this project and community resources.

## Table of Contents

- [Control Node Fundamentals](#control-node-fundamentals)
- [Layout Containers](#layout-containers)
- [Sizing and Expansion](#sizing-and-expansion)
- [Mouse Filter Behavior](#mouse-filter-behavior)
- [Responsive Design](#responsive-design)
- [Theming and Consistency](#theming-and-consistency)
- [Performance Considerations](#performance-considerations)
- [Common Pitfalls](#common-pitfalls)
- [Project-Specific Conventions](#project-specific-conventions)

---

## Control Node Fundamentals

Control nodes form the foundation of all UI elements in Godot. They differ from other nodes by supporting:

- **Anchors**: Define where corners pin relative to parent (Top Left, Full Rect, Center, etc.)
- **Offsets**: Pixel-based deviations from anchor positions
- **Size Flags**: Determine how nodes behave within container layouts
- **Mouse Filter**: Control how mouse events propagate through the UI hierarchy

### Key Properties

| Property | Purpose |
|----------|---------|
| `anchors_preset` | Quick anchor configuration (centered, full rect, etc.) |
| `offset_left/right/top/bottom` | Fine-tune position relative to anchors |
| `size_flags_horizontal/vertical` | How the node behaves in containers |
| `custom_minimum_size` | Ensures minimum dimensions |
| `mouse_filter` | Event propagation control |

---

## Layout Containers

**Always prefer containers over manual positioning.** Containers automatically manage child node placement, enabling responsive UI.

### Container Types

| Container | Purpose | Ideal Use |
|-----------|---------|-----------|
| `VBoxContainer` | Vertical child arrangement | Menus, lists, dialogs |
| `HBoxContainer` | Horizontal child arrangement | Toolbars, button groups |
| `GridContainer` | Grid-based layout | Inventories, skill trees |
| `MarginContainer` | Uniform edge spacing | Safe screen margins |
| `PanelContainer` | Background styling | Windows, sections |
| `ScrollContainer` | Scrollable content | Long lists, text |
| `CenterContainer` | Center single child | Centered elements |

### Nesting Strategy

Combine containers hierarchically for complex layouts:

```
MarginContainer           <- Screen edge safety
  └─ VBoxContainer        <- Vertical arrangement
      ├─ Label            <- Title
      ├─ HBoxContainer    <- Horizontal toolbar
      │   ├─ Button
      │   └─ Button
      └─ ScrollContainer  <- Scrollable content area
          └─ VBoxContainer
              └─ ...items
```

### Layout Mode

When placing a Control inside a Container:

- **`layout_mode = 2`** (Container): The container controls sizing. Use this for children inside VBox/HBox/Grid containers.
- **`layout_mode = 1`** (Anchors): Manual anchor-based positioning. Use for overlays or elements that must fill a Panel.

**Critical**: When a Control uses `layout_mode = 1` (anchors) inside a Panel, the Panel cannot calculate its minimum size from the child. Either:
1. Set `custom_minimum_size` on the Panel, or
2. Change the child to `layout_mode = 2`

---

## Sizing and Expansion

### Size Flags

| Flag | Value | Behavior |
|------|-------|----------|
| `SIZE_SHRINK_BEGIN` | 0 | Shrink to minimum, align to start |
| `SIZE_FILL` | 1 | Fill available space |
| `SIZE_EXPAND` | 2 | Request extra space from container |
| `SIZE_EXPAND_FILL` | 3 | Expand AND fill the expanded space |
| `SIZE_SHRINK_CENTER` | 4 | Shrink to minimum, center |
| `SIZE_SHRINK_END` | 8 | Shrink to minimum, align to end |

### Stretch Ratio

When multiple children have `SIZE_EXPAND`, `stretch_ratio` determines proportional distribution:

```gdscript
# Child A: stretch_ratio = 1
# Child B: stretch_ratio = 2
# Result: B gets twice the extra space as A
```

### Minimum Size

Always set `custom_minimum_size` when:
- A Panel contains anchor-based children
- You need guaranteed minimum dimensions
- Content might be empty but space should be reserved

---

## Mouse Filter Behavior

Mouse filter controls how Control nodes handle mouse input. **This is one of the most common sources of UI bugs.**

### Filter Modes

| Mode | Value | Behavior |
|------|-------|----------|
| `MOUSE_FILTER_STOP` | 0 | Consumes event, blocks propagation |
| `MOUSE_FILTER_PASS` | 1 | Consumes event, also passes to parent |
| `MOUSE_FILTER_IGNORE` | 2 | Ignores event entirely (passes through) |

### Common Patterns

```gdscript
# Visual-only overlay (locked indicator, dim background)
overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Value: 2

# Interactive button (default)
button.mouse_filter = Control.MOUSE_FILTER_STOP  # Value: 0

# Label over a button (clicks pass to button)
label.mouse_filter = Control.MOUSE_FILTER_PASS  # Value: 1
```

### In Scene Files (.tscn)

```
# For visual-only elements
mouse_filter = 2

# For interactive elements (usually default)
mouse_filter = 0
```

### Critical Warning

**MOUSE_FILTER_IGNORE discards the event entirely** - it does NOT pass to sibling controls behind the current node. The mouse filter system only affects parent-child propagation, not overlapping siblings in the scene tree.

For overlapping panels at the same level:
- The topmost (last in tree order) with `STOP` or `PASS` receives the event
- Use CanvasLayer with different layer values to control which UI receives input first

---

## Responsive Design

### Project Settings

Configure `Project Settings > Display > Window > Stretch`:

| Setting | Recommended | Purpose |
|---------|-------------|---------|
| Mode | `canvas_items` | Scales UI with window |
| Aspect | `keep` | Maintains ratio with letterboxing |

### Anchor Presets

Use anchor presets for common positioning:

- **Full Rect** (`anchors_preset = 15`): Fills entire parent
- **Center** (`anchors_preset = 8`): Centered in parent
- **Top-Left** (`anchors_preset = 0`): Fixed to corner

### CanvasLayer for HUD

Use CanvasLayer for persistent UI elements:
- Separates UI from game world rendering
- Consistent visibility across resolution changes
- Different layer values control render order

---

## Theming and Consistency

### Theme Resources

Create a Theme resource for project-wide UI consistency:

```gdscript
# Apply to root Control node
var theme = preload("res://themes/game_theme.tres")
root_control.theme = theme
```

### Benefits
- Consistent fonts, colors, and styles
- Single source of truth
- Easy global updates

### Don't
- Style individual nodes with `theme_override_*` unless necessary
- Mix different font sizes randomly
- Use hardcoded colors throughout

---

## Performance Considerations

### Minimize Hierarchy Depth

Deep container nesting increases layout recalculation costs:

```
# Avoid excessive nesting
MarginContainer
  └─ CenterContainer
      └─ PanelContainer
          └─ MarginContainer      <- Often unnecessary
              └─ VBoxContainer
                  └─ Content
```

### Visibility Optimization

Hide unused UI elements:
```gdscript
overlay.visible = false  # Stops rendering and input processing
```

### Custom Drawing

For complex visualizations (graphs, gauges), consider `_draw()` instead of many Control nodes:

```gdscript
func _draw():
    draw_rect(Rect2(0, 0, 100, 20), Color.GREEN)
    # More efficient than multiple ColorRect children
```

---

## Common Pitfalls

### 1. Overlapping Content

**Problem**: Text or elements overlap with siblings.

**Cause**: Parent container doesn't know child's size (anchor-based layout with no minimum size).

**Solution**:
```
# In .tscn
custom_minimum_size = Vector2(0, 90)  # Set appropriate minimum
```

### 2. Clicks Not Registering

**Problem**: Buttons don't respond to clicks.

**Cause**: Another Control with `MOUSE_FILTER_STOP` is blocking.

**Solution**: Set overlays to `mouse_filter = 2` (IGNORE).

### 3. UI Not Scaling

**Problem**: UI has fixed size, doesn't adapt to screen.

**Cause**: Using fixed offsets instead of anchors/containers.

**Solution**: Use containers and anchor presets. Set stretch mode in project settings.

### 4. Modal Dialogs Passing Clicks

**Problem**: Clicking modal dialog also triggers elements behind it.

**Cause**: Godot's mouse filter system quirk - events can reach siblings.

**Solution**: Add a full-screen ColorRect behind the modal with `MOUSE_FILTER_STOP` to block all clicks.

### 5. Container Children Not Sizing

**Problem**: Children in VBox/HBox don't expand as expected.

**Cause**: `size_flags_horizontal/vertical` not set correctly.

**Solution**: Set `size_flags_horizontal = 3` (EXPAND_FILL) for children that should grow.

---

## Project-Specific Conventions

### This Project (GoPit)

1. **Overlays**: Use `mouse_filter = 2` for visual-only elements (locked indicators, backgrounds)

2. **Modals**: Always include a dim background ColorRect that blocks clicks

3. **Panels with anchor-based children**: Always set `custom_minimum_size`

4. **UI CanvasLayer**: Use layer 10+ for UI to render above game elements

5. **Testing**: Verify UI interactions work with PlayGodot tests after changes

---

## Resources

- [Godot Official UI Documentation](https://docs.godotengine.org/en/stable/tutorials/ui/index.html)
- [Control Node Class Reference](https://docs.godotengine.org/en/stable/classes/class_control.html)
- [Making Responsive UI in Godot (Kodeco)](https://www.kodeco.com/45869762-making-responsive-ui-in-godot)
- [Control Node Fundamentals (Uhiyama Lab)](https://uhiyama-lab.com/en/notes/godot/control-layout-containers/)
