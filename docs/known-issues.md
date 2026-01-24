# Known Issues

## UI Overlay Input Blocking (2026-01-05) - RESOLVED

### Problem
Touch/click input was blocked on mobile when tutorial overlay was visible. The fire button couldn't be tapped during the FIRE tutorial step.

### Root Cause
Godot Control nodes default to `mouse_filter = MOUSE_FILTER_STOP` (0), which captures all input events. The `HighlightRing` Control node in the tutorial overlay was positioned over the fire button but didn't have `mouse_filter = 2` (IGNORE) set, causing it to intercept all touch events.

### Fix Applied
Added `mouse_filter = 2` to `HighlightRing` in `scenes/ui/tutorial_overlay.tscn`:
```
[node name="HighlightRing" type="Control" parent="DimBackground"]
mouse_filter = 2
```

### Status
- **Fixed** (2026-01-05) - Tutorial is now enabled by default and working correctly.

### Prevention
See `AGENTS.md` for Godot UI best practices on `mouse_filter` settings.

---

## Overlays Visible on Game Start (2026-01-05)

### Problem
GameOverOverlay and LevelUpOverlay were visible when the game launched on web, blocking gameplay.

### Root Cause
The overlays relied on `_ready()` scripts to set `visible = false`. In the web export, the scripts may not initialize in the expected order, or there's a timing issue with Godot 4.4.1 vs 4.5.

### Fix Applied
Set `visible = false` directly in the scene file `scenes/game.tscn` instead of relying on scripts:
```
[node name="GameOverOverlay" type="Control" parent="UI"]
visible = false
...

[node name="LevelUpOverlay" type="Control" parent="UI"]
visible = false
...
```

### Lesson Learned
For web exports, set initial visibility states in scene files rather than scripts to avoid initialization timing issues.

---

## PlayGodot Automation Not Working (2026-01-05)

### Problem
PlayGodot tests fail with:
```
TimeoutError: Node '/root/Game' not found
ERROR: Can't use get_node() with absolute paths from outside the active scene tree.
```

This happens both locally and in CI.

### Root Cause
The Godot automation fork's `RemoteDebugger::_send_node_info()` calls:
```cpp
Node *node = tree->get_root()->get_node_or_null(NodePath(p_path));
```

But `get_node_or_null()` with absolute paths requires the calling node to be inside the scene tree (`data.tree != nullptr`). The automation commands are being processed **before** `SceneTree::initialize()` calls `root->_set_tree(this)`.

### Location
- Error source: `scene/main/node.cpp:1898`
- Automation code: `core/debugger/remote_debugger.cpp:862`
- Scene tree init: `scene/main/scene_tree.cpp:579`

### Proposed Fix
Add a check in `_send_node_info()` and similar functions:
```cpp
void RemoteDebugger::_send_node_info(const String &p_path) {
    SceneTree *tree = SceneTree::get_singleton();
    ERR_FAIL_NULL(tree);

    Node *root = tree->get_root();
    ERR_FAIL_NULL(root);

    Array msg;
    // Check if root is inside tree before using absolute paths
    if (!root->is_inside_tree()) {
        msg.push_back(Variant());
        EngineDebugger::get_singleton()->send_message("automation:node", msg);
        return;
    }

    Node *node = root->get_node_or_null(NodePath(p_path));
    // ... rest of function
}
```

### Status
- **Fixed** (2026-01-05) - Added `is_inside_tree()` guards to all affected functions in `core/debugger/remote_debugger.cpp`
- Functions fixed: `_send_scene_tree()`, `_send_node_info()`, `_send_property()`, `_set_property()`, `_call_method()`, `_send_screenshot()`, `_query_nodes()`, `_count_nodes()`
- **Pushed** to https://github.com/Randroids-Dojo/godot automation branch

---

## GUI Click Input Not Working in Headless Mode (2026-01-05)

### Problem
PlayGodot `.click()` calls were not triggering button presses in headless mode. The input events were sent but GUI controls never received them.

### Root Cause
`DisplayServerHeadless::window_get_size()` returned `Size2i()` (0x0), causing the viewport to fall back to a minimum 64x64 size. When clicking at coordinates like (1235, 45), `Viewport::gui_find_control()` couldn't find any controls since they were "outside" the tiny 64x64 viewport.

### Fix Applied
Modified `servers/display/display_server_headless.h`:
1. Added `window_size` member variable to store the requested resolution
2. Updated `create_func()` to store `p_resolution` parameter
3. Updated `window_get_size()`, `screen_get_size()`, `window_set_size()` to use stored size

Also added `DisplayServer::get_singleton()->process_events()` calls in `core/debugger/remote_debugger.cpp` after input injection to ensure events are properly dispatched.

### Status
- **Fixed** (2026-01-05)
- **Pushed** to https://github.com/Randroids-Dojo/godot automation branch
- Tests updated to use `.click()` instead of `.call("_try_fire")` workaround

---

## CI/CD Godot Version Mismatch

### Problem
CI workflow uses Godot 4.4.1 but project requires 4.5+.

### Location
`.github/workflows/ci.yml`:
```yaml
- name: Setup Godot Engine
  uses: chickensoft-games/setup-godot@v2
  with:
    version: 4.5.1
```

### Impact
Scene file changes may not export correctly due to format differences between versions.

### Status
- **Fixed** (2026-01-19) - Updated CI to use Godot 4.5.1 matching project requirements.
