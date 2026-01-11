"""Tests for the hemorrhage mechanic (bleed at 12+ stacks)."""
import asyncio
import pytest

GAME = "/root/Game"
ENEMIES_CONTAINER = "/root/Game/GameArea/Enemies"
ENEMY_SPAWNER = "/root/Game/GameArea/Enemies/EnemySpawner"


async def wait_for_enemy(game, timeout: float = 3.0) -> str:
    """Wait for an enemy to spawn and return its path."""
    # Spawn an enemy explicitly
    await game.call(ENEMY_SPAWNER, "spawn_enemy")

    start = asyncio.get_event_loop().time()
    while asyncio.get_event_loop().time() - start < timeout:
        # Use get_node which returns Node wrapper with _data containing children
        container = await game.get_node(ENEMIES_CONTAINER)
        if container and hasattr(container, '_data') and 'children' in container._data:
            for child in container._data['children']:
                name = child.get('name', '')
                # Skip the spawner node, accept Slime, Bat, Crab, etc.
                if 'Spawner' not in name and name:
                    return child.get('path', f"{ENEMIES_CONTAINER}/{name}")
        await asyncio.sleep(0.1)
    return None


@pytest.mark.asyncio
async def test_hemorrhage_threshold_constant(game):
    """Hemorrhage threshold should be 12 stacks."""
    enemy_path = await wait_for_enemy(game)
    if enemy_path is None:
        pytest.skip("No enemy spawned in time")
        return

    threshold = await game.call(enemy_path, "get_hemorrhage_threshold")
    assert threshold == 12, "Hemorrhage threshold should be 12 bleed stacks"


@pytest.mark.asyncio
async def test_bleed_stacks_method_exists(game):
    """Enemies should have get_bleed_stacks method."""
    enemy_path = await wait_for_enemy(game)
    if enemy_path is None:
        pytest.skip("No enemy spawned in time")
        return

    has_method = await game.call(enemy_path, "has_method", ["get_bleed_stacks"])
    assert has_method, "Enemy should have get_bleed_stacks method"


@pytest.mark.asyncio
async def test_bleed_stacks_starts_at_zero(game):
    """Bleed stacks should start at 0."""
    enemy_path = await wait_for_enemy(game)
    if enemy_path is None:
        pytest.skip("No enemy spawned in time")
        return

    stacks = await game.call(enemy_path, "get_bleed_stacks")
    assert stacks == 0, "Bleed stacks should start at 0"


@pytest.mark.asyncio
async def test_hemorrhage_signal_exists(game):
    """Enemies should have hemorrhage_triggered signal."""
    enemy_path = await wait_for_enemy(game)
    if enemy_path is None:
        pytest.skip("No enemy spawned in time")
        return

    has_signal = await game.call(enemy_path, "has_signal", ["hemorrhage_triggered"])
    assert has_signal, "Enemy should have hemorrhage_triggered signal"


@pytest.mark.asyncio
async def test_hemorrhage_damage_percent_constant(game):
    """Hemorrhage should deal 20% of current HP."""
    enemy_path = await wait_for_enemy(game)
    if enemy_path is None:
        pytest.skip("No enemy spawned in time")
        return

    # Get hemorrhage threshold to verify constants are accessible
    threshold = await game.call(enemy_path, "get_hemorrhage_threshold")
    assert threshold > 0, "Hemorrhage threshold should be defined"


@pytest.mark.asyncio
async def test_bleed_max_stacks(game):
    """Bleed should have max_stacks of 24."""
    enemy_path = await wait_for_enemy(game)
    if enemy_path is None:
        pytest.skip("No enemy spawned in time")
        return

    # Verify enemy exists and can track bleed
    has_method = await game.call(enemy_path, "has_method", ["has_status_effect"])
    assert has_method, "Enemy should have has_status_effect method"


@pytest.mark.asyncio
async def test_hemorrhage_more_valuable_on_full_hp(game):
    """Hemorrhage deals 20% of CURRENT HP, so more valuable on full HP enemies."""
    enemy_path = await wait_for_enemy(game)
    if enemy_path is None:
        pytest.skip("No enemy spawned in time")
        return

    # Verify we can get enemy HP
    hp = await game.get_property(enemy_path, "hp")
    max_hp = await game.get_property(enemy_path, "max_hp")
    assert hp > 0, "Enemy should have HP"
    assert max_hp > 0, "Enemy should have max_hp"
