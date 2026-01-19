# GoPit

A mobile arcade game built with Godot 4.5 where you fire balls to destroy descending enemies.

## Game Features

- **Ball firing system** - Aim with virtual joystick, fire with cooldown button
- **Enemy waves** - Slimes descend from above, scaling in difficulty
- **Gem collection** - Enemies drop gems that grant XP
- **Level-up upgrades** - Choose from damage, fire rate, or HP upgrades
- **Wave progression** - Increasing spawn rate and enemy stats

## Project Structure

```
GoPit/
├── scenes/
│   ├── game.tscn              # Main game scene
│   ├── entities/
│   │   ├── ball.tscn          # Player projectile
│   │   ├── gem.tscn           # XP pickup
│   │   └── enemies/
│   │       └── slime.tscn     # Basic enemy
│   └── input/
│       ├── virtual_joystick.tscn
│       └── fire_button.tscn
├── scripts/
│   ├── autoload/
│   │   └── game_manager.gd    # Global game state
│   ├── entities/
│   │   ├── ball.gd
│   │   ├── ball_spawner.gd
│   │   ├── gem.gd
│   │   └── enemies/
│   │       ├── enemy_base.gd
│   │       ├── enemy_spawner.gd
│   │       └── slime.gd
│   ├── game/
│   │   └── game_controller.gd # Main game logic
│   ├── input/
│   │   ├── aim_line.gd
│   │   ├── fire_button.gd
│   │   └── virtual_joystick.gd
│   └── ui/
│       ├── hud.gd
│       ├── game_over_overlay.gd
│       └── level_up_overlay.gd
├── tests/                     # PlayGodot automated tests
│   └── launch_and_fire.py
└── docs/
    └── testing.md             # Test setup documentation
```

## Requirements

- Godot 4.5+
- Portrait display (720x1280)

## Running the Game

Open the project in Godot and run `scenes/game.tscn`, or:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path . scenes/game.tscn
```

## Testing Setup

This project uses [PlayGodot](https://github.com/Randroids-Dojo/PlayGodot) for automated testing, which requires a custom Godot fork with automation protocol support.

### 1. Install Godot Automation Fork

Download the pre-built binary from GitHub Actions:

```bash
# List recent builds
gh run list -R Randroids-Dojo/godot --branch automation -w "Build Godot Automation" --limit 5

# Download macOS binary (replace RUN_ID with actual run ID)
gh run download RUN_ID -R Randroids-Dojo/godot -n macos-editor -D ~/Documents/Dev/Godot/godot/bin

# Make executable
chmod +x ~/Documents/Dev/Godot/godot/bin/godot.macos.editor.*
```

Or build from source:
```bash
git clone https://github.com/Randroids-Dojo/godot.git
cd godot && git checkout automation
scons platform=macos target=editor
```

### 2. Install PlayGodot Python Library

```bash
pip3 install playgodot

# Or from source:
git clone https://github.com/Randroids-Dojo/PlayGodot.git
pip3 install -e PlayGodot/python
```

### 3. Configure Test Environment

Update `tests/conftest.py` with your Godot path:

```python
GODOT_PATH = "/path/to/godot/bin/godot.macos.editor.arm64"
```

### 4. Run Tests

```bash
# Run all tests
python3 -m pytest tests/ -v --tb=short

# Run specific test file
python3 -m pytest tests/test_fire.py -v

# Run comprehensive playtest
python3 -m pytest tests/test_comprehensive_playtest.py -v
```

### Claude Code Integration

For AI-assisted development with testing, install the Godot skill:

```bash
# The skill is auto-loaded from ~/.claude/skills/godot
# It provides PlayGodot testing guidance and commands
```

Invoke with `/godot` or let Claude auto-use it for Godot projects.

See [docs/testing.md](docs/testing.md) for detailed API documentation.

## Web Build

GoPit can be exported for web browsers and is deployed to [go-pit.vercel.app](https://go-pit.vercel.app).

### Local Web Export

```bash
# Build and serve locally for testing
./verify_web_export.sh --serve

# Build only (no server)
./verify_web_export.sh

# Clean build
./verify_web_export.sh --clean
```

Then open http://localhost:8000 in your browser.

### CI/CD

Web builds are automatically:
- Built and tested on every PR (preview deployment)
- Deployed to production on merge to main

See [docs/web-testing-checklist.md](docs/web-testing-checklist.md) for manual testing guide.

## Documentation

- [Testing Setup](docs/testing.md) - PlayGodot automated testing
- [Web Testing Checklist](docs/web-testing-checklist.md) - Browser testing guide
- [UI Best Practices](docs/godot-ui-best-practices.md) - Godot UI/UX guidelines
- [Input Best Practices](docs/godot-input-best-practices.md) - Keyboard and touch input guidelines
- [Known Issues](docs/known-issues.md) - Current limitations and workarounds

## Controls

### Touch/Mobile
- **Left side**: Virtual joystick for movement
- **Right side**: Fire button (with autofire) and aim joystick

### Keyboard
| Action | Key |
|--------|-----|
| Move | WASD |
| Aim | Arrow Keys |
| Fire | Space |
| Ultimate | E |
| Toggle Auto | Tab |
| Mute | M |
| Pause | Escape |

## License

MIT
