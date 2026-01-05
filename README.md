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

## Testing

Automated tests use [PlayGodot](https://github.com/Randroids-Dojo/PlayGodot) with a custom Godot fork.

See [docs/testing.md](docs/testing.md) for setup instructions.

Quick start:
```bash
python3 tests/launch_and_fire.py
```

## Controls

- **Left side**: Virtual joystick to aim
- **Right side**: Fire button (with cooldown)

## License

MIT
