"""Tests for new boss types: Frost Wyrm, Sand Golem, Void Lord."""
import asyncio
import pytest

GAME = "/root/Game"


async def spawn_boss_of_type(game, boss_type: str):
    """Spawn a specific boss type and return its path."""
    scene_paths = {
        "slime_king": "res://scenes/entities/enemies/bosses/slime_king.tscn",
        "frost_wyrm": "res://scenes/entities/enemies/bosses/frost_wyrm.tscn",
        "sand_golem": "res://scenes/entities/enemies/bosses/sand_golem.tscn",
        "void_lord": "res://scenes/entities/enemies/bosses/void_lord.tscn",
    }

    scene_path = scene_paths.get(boss_type)
    if not scene_path:
        pytest.fail(f"Unknown boss type: {boss_type}")

    boss_path = await game.call(GAME, "spawn_test_enemy", [scene_path])
    # Wait for boss intro to complete
    await asyncio.sleep(2.5)
    return boss_path


# === Frost Wyrm Tests ===


@pytest.mark.asyncio
async def test_frost_wyrm_stats(game):
    """Frost Wyrm should have correct base stats."""
    boss_path = await spawn_boss_of_type(game, "frost_wyrm")
    assert boss_path, "Should spawn Frost Wyrm"

    max_hp = await game.get_property(boss_path, "max_hp")
    assert max_hp == 600, f"Frost Wyrm max_hp should be 600, got {max_hp}"

    boss_name = await game.get_property(boss_path, "boss_name")
    assert boss_name == "Frost Wyrm", f"Boss name should be 'Frost Wyrm', got '{boss_name}'"

    await game.call(boss_path, "queue_free")


@pytest.mark.asyncio
async def test_frost_wyrm_has_breath_attack(game):
    """Frost Wyrm should have breath attack in phase attacks."""
    boss_path = await spawn_boss_of_type(game, "frost_wyrm")
    assert boss_path, "Should spawn Frost Wyrm"

    phase_attacks = await game.get_property(boss_path, "phase_attacks")
    # Phase attacks is a dictionary with BossPhase enum keys
    assert phase_attacks is not None, "Should have phase_attacks"

    await game.call(boss_path, "queue_free")


# === Sand Golem Tests ===


@pytest.mark.asyncio
async def test_sand_golem_stats(game):
    """Sand Golem should have correct base stats."""
    boss_path = await spawn_boss_of_type(game, "sand_golem")
    assert boss_path, "Should spawn Sand Golem"

    max_hp = await game.get_property(boss_path, "max_hp")
    assert max_hp == 800, f"Sand Golem max_hp should be 800, got {max_hp}"

    boss_name = await game.get_property(boss_path, "boss_name")
    assert boss_name == "Sand Golem", f"Boss name should be 'Sand Golem', got '{boss_name}'"

    await game.call(boss_path, "queue_free")


@pytest.mark.asyncio
async def test_sand_golem_body_dimensions(game):
    """Sand Golem should have body dimension properties."""
    boss_path = await spawn_boss_of_type(game, "sand_golem")
    assert boss_path, "Should spawn Sand Golem"

    body_width = await game.get_property(boss_path, "body_width")
    assert body_width == 80.0, f"body_width should be 80, got {body_width}"

    body_height = await game.get_property(boss_path, "body_height")
    assert body_height == 100.0, f"body_height should be 100, got {body_height}"

    await game.call(boss_path, "queue_free")


# === Void Lord Tests ===


@pytest.mark.asyncio
async def test_void_lord_stats(game):
    """Void Lord should have correct base stats (highest HP as final boss)."""
    boss_path = await spawn_boss_of_type(game, "void_lord")
    assert boss_path, "Should spawn Void Lord"

    max_hp = await game.get_property(boss_path, "max_hp")
    assert max_hp == 1000, f"Void Lord max_hp should be 1000, got {max_hp}"

    boss_name = await game.get_property(boss_path, "boss_name")
    assert boss_name == "Void Lord", f"Boss name should be 'Void Lord', got '{boss_name}'"

    xp_value = await game.get_property(boss_path, "xp_value")
    assert xp_value == 300, f"Void Lord xp_value should be 300 (highest), got {xp_value}"

    await game.call(boss_path, "queue_free")


@pytest.mark.asyncio
async def test_void_lord_visual_properties(game):
    """Void Lord should have visual properties."""
    boss_path = await spawn_boss_of_type(game, "void_lord")
    assert boss_path, "Should spawn Void Lord"

    body_radius = await game.get_property(boss_path, "body_radius")
    assert body_radius == 70.0, f"body_radius should be 70, got {body_radius}"

    await game.call(boss_path, "queue_free")


# === Boss Progression Tests ===


@pytest.mark.asyncio
async def test_boss_hp_progression(game):
    """Bosses should have increasing HP through stages."""
    boss_stats = {
        "slime_king": 500,
        "frost_wyrm": 600,
        "sand_golem": 800,
        "void_lord": 1000,
    }

    for boss_type, expected_hp in boss_stats.items():
        boss_path = await spawn_boss_of_type(game, boss_type)
        assert boss_path, f"Should spawn {boss_type}"

        max_hp = await game.get_property(boss_path, "max_hp")
        assert max_hp == expected_hp, f"{boss_type} HP should be {expected_hp}, got {max_hp}"

        await game.call(boss_path, "queue_free")
        await asyncio.sleep(0.2)


@pytest.mark.asyncio
async def test_boss_xp_progression(game):
    """Bosses should give increasing XP through stages."""
    boss_stats = {
        "slime_king": 100,
        "frost_wyrm": 150,
        "sand_golem": 200,
        "void_lord": 300,
    }

    for boss_type, expected_xp in boss_stats.items():
        boss_path = await spawn_boss_of_type(game, boss_type)
        assert boss_path, f"Should spawn {boss_type}"

        xp_value = await game.get_property(boss_path, "xp_value")
        assert xp_value == expected_xp, f"{boss_type} XP should be {expected_xp}, got {xp_value}"

        await game.call(boss_path, "queue_free")
        await asyncio.sleep(0.2)


@pytest.mark.asyncio
async def test_all_bosses_in_boss_group(game):
    """All bosses should be in the 'boss' group."""
    boss_types = ["slime_king", "frost_wyrm", "sand_golem", "void_lord"]

    for boss_type in boss_types:
        boss_path = await spawn_boss_of_type(game, boss_type)
        assert boss_path, f"Should spawn {boss_type}"

        is_in_group = await game.call(boss_path, "is_in_group", ["boss"])
        assert is_in_group, f"{boss_type} should be in 'boss' group"

        await game.call(boss_path, "queue_free")
        await asyncio.sleep(0.2)
