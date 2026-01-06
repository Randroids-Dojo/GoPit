# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Testing Requirements

**CRITICAL: All code changes MUST be validated with PlayGodot tests before committing.**

### Running Tests

```bash
# Run all PlayGodot tests
python3 -m pytest tests/ -v --tb=short

# Run specific test file
python3 -m pytest tests/test_fire.py -v

# Run comprehensive playtest
python3 -m pytest tests/test_comprehensive_playtest.py -v
```

### Test Coverage Expectations

When implementing new features, you MUST:

1. **Run existing tests** to ensure no regressions
2. **Write new tests** for significant gameplay changes:
   - New mechanics (enemies, weapons, upgrades)
   - UI interactions (buttons, overlays)
   - Game state changes (level-up, game over)
3. **Update existing tests** if behavior changes intentionally

### Writing PlayGodot Tests

Tests live in `tests/` directory. Use this pattern:

```python
import asyncio
import pytest

@pytest.mark.asyncio
async def test_my_feature(game):
    """Test description."""
    # Interact with game
    await game.click("/root/Game/UI/SomeButton")
    await asyncio.sleep(0.2)

    # Verify results
    result = await game.call("/root/Game/SomeNode", "some_method")
    assert result == expected_value
```

### Common Node Paths

```python
PATHS = {
    "game": "/root/Game",
    "fire_button": "/root/Game/UI/HUD/InputContainer/HBoxContainer/FireButtonContainer/FireButton",
    "balls": "/root/Game/GameArea/Balls",
    "enemies": "/root/Game/GameArea/Enemies",
    "gems": "/root/Game/GameArea/Gems",
    "game_over_overlay": "/root/Game/UI/GameOverOverlay",
    "level_up_overlay": "/root/Game/UI/LevelUpOverlay",
}
```

### PlayGodot API Quick Reference

```python
# Click on UI element or coordinates
await game.click("/root/Game/UI/Button")
await game.click(300, 200)

# Call methods on nodes
result = await game.call("/root/Node", "method_name", [arg1, arg2])

# Get/set properties (returns dict for Vector2, e.g., {'x': 1.0, 'y': 2.0})
value = await game.get_property("/root/Node", "property_name")

# Get node info
node = await game.get_node("/root/Game")

# Wait for game state
await asyncio.sleep(0.5)
```

### Pre-Commit Checklist

Before committing ANY code changes:

- [ ] `python3 -m pytest tests/ -v` - All tests pass
- [ ] New features have corresponding tests
- [ ] No test regressions introduced

## Parallel Agent Coordination

**CRITICAL: PlayGodot tests use a fixed port (6007) and cannot run concurrently.**

When multiple agents are working in parallel (e.g., in different tmux windows or worktrees):

1. **Before running tests**, check if another agent is testing:
   ```bash
   lsof -i :6007  # Check if port is in use
   pgrep -f godot  # Check for running Godot processes
   ```

2. **If port is in use**, wait or coordinate:
   - Kill stale processes: `pkill -9 -f godot`
   - Wait for the other agent to finish testing
   - Use `bd show` to see what work is in progress

3. **Avoid test conflicts**:
   - Only ONE agent should run PlayGodot tests at a time
   - If you see `OSError: [Errno 48] address already in use`, another test is running
   - Coordinate via beads: check `bd list --status=in_progress` to see active work

4. **Worktree considerations**:
   - Each worktree shares the same test infrastructure
   - Tests in different worktrees still conflict on port 6007
   - Coordinate testing across worktrees

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

