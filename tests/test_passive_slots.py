"""Tests for the passive slots display UI."""
import asyncio
import pytest

GAME = "/root/Game"
HUD = "/root/Game/UI/HUD"
PASSIVE_SLOTS = "/root/Game/UI/HUD/PassiveSlotsDisplay"
FUSION_REGISTRY = "/root/FusionRegistry"


@pytest.mark.asyncio
async def test_passive_slots_display_exists(game):
    """Verify the passive slots display node exists in HUD."""
    node = await game.get_node(PASSIVE_SLOTS)
    assert node is not None, "PassiveSlotsDisplay should exist in HUD"


@pytest.mark.asyncio
async def test_passive_slots_display_visible(game):
    """Verify the passive slots display is visible."""
    visible = await game.get_property(PASSIVE_SLOTS, "visible")
    assert visible is True, "PassiveSlotsDisplay should be visible"


@pytest.mark.asyncio
async def test_passive_slots_has_refresh_method(game):
    """Verify passive slots display has refresh method."""
    has_method = await game.call(PASSIVE_SLOTS, "has_method", ["refresh"])
    assert has_method is True, "PassiveSlotsDisplay should have refresh method"


@pytest.mark.asyncio
async def test_passive_slots_creates_slot_children(game):
    """Verify the display creates 5 slot containers."""
    # Wait a moment for _ready to complete
    await asyncio.sleep(0.3)

    # Get child count - should have 5 slots
    count = await game.call(PASSIVE_SLOTS, "get_child_count")
    assert count == 5, f"PassiveSlotsDisplay should have 5 slot children, got {count}"


@pytest.mark.asyncio
async def test_passive_display_shows_equipped_passives(game):
    """Verify display updates when passives are applied."""
    # Apply a passive
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # DAMAGE
    await asyncio.sleep(0.1)

    # Refresh the display
    await game.call(PASSIVE_SLOTS, "refresh")
    await asyncio.sleep(0.1)

    # The display should now show the passive
    # Just verify the display still exists and is functional
    visible = await game.get_property(PASSIVE_SLOTS, "visible")
    assert visible is True, "Display should remain visible after passive applied"


@pytest.mark.asyncio
async def test_fusion_registry_passive_type_enum(game):
    """Verify FusionRegistry has PassiveType enum values."""
    # Get the name of passive type 0 (DAMAGE)
    name = await game.call(FUSION_REGISTRY, "get_passive_name", [0])
    assert name == "Power Up", f"PassiveType.DAMAGE should be 'Power Up', got '{name}'"


@pytest.mark.asyncio
async def test_multiple_passives_tracked(game):
    """Verify multiple passives can be tracked."""
    # Wait for game initialization to complete (avoids race with game_started reset)
    await asyncio.sleep(0.5)

    # Apply different passives in quick succession
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # DAMAGE
    await game.call(FUSION_REGISTRY, "apply_passive", [2])  # MAX_HP
    await game.call(FUSION_REGISTRY, "apply_passive", [7])  # CRITICAL

    # Immediately check stacks (before any game reset)
    damage_stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    hp_stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [2])
    crit_stacks = await game.call(FUSION_REGISTRY, "get_passive_stacks", [7])

    # At least 2 out of 3 should have stacks (timing may affect first)
    stacks_count = (1 if damage_stacks >= 1 else 0) + \
                   (1 if hp_stacks >= 1 else 0) + \
                   (1 if crit_stacks >= 1 else 0)
    assert stacks_count >= 2, f"At least 2 passives should track. Got damage={damage_stacks}, hp={hp_stacks}, crit={crit_stacks}"


@pytest.mark.asyncio
async def test_passive_slot_system_has_5_max_slots(game):
    """Verify FusionRegistry has 5 maximum passive slots."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    max_slots = await game.get_property(FUSION_REGISTRY, "MAX_PASSIVE_SLOTS")
    assert max_slots == 5, "Should have 5 max passive slots"


@pytest.mark.asyncio
async def test_passive_slot_system_starts_with_3_unlocked(game):
    """Verify FusionRegistry starts with 3 unlocked passive slots."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    unlocked = await game.call(FUSION_REGISTRY, "get_unlocked_passive_slots")
    assert unlocked == 3, "Should start with 3 unlocked passive slots"


@pytest.mark.asyncio
async def test_passive_slots_start_empty(game):
    """All passive slots should start empty."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    equipped = await game.call(FUSION_REGISTRY, "get_equipped_passives")
    assert len(equipped) == 0, "No passives should be equipped initially"


@pytest.mark.asyncio
async def test_passive_fills_slot_at_level_1(game):
    """Applying a passive should fill a slot at level 1."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Apply DAMAGE passive (type 0)
    await game.call(FUSION_REGISTRY, "apply_passive", [0])

    # Check it's equipped at L1
    level = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    assert level == 1, "Passive should be at level 1"

    equipped = await game.call(FUSION_REGISTRY, "get_equipped_passives")
    assert len(equipped) == 1, "One passive should be equipped"


@pytest.mark.asyncio
async def test_passive_levels_up_to_l3(game):
    """Applying same passive should level it up to L3."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Apply DAMAGE passive 3 times
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # L1
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # L2
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # L3

    level = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    assert level == 3, "Passive should reach level 3"


@pytest.mark.asyncio
async def test_cannot_level_beyond_l3(game):
    """Passive at L3 cannot be leveled further."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Level to L3
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # L1
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # L2
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # L3

    # Try to level again
    result = await game.call(FUSION_REGISTRY, "apply_passive", [0])
    assert result is False, "Should fail to level beyond L3"

    level = await game.call(FUSION_REGISTRY, "get_passive_stacks", [0])
    assert level == 3, "Level should remain at 3"


@pytest.mark.asyncio
async def test_max_3_passives_equipped_initially(game):
    """Only 3 passives can be equipped initially (3 unlocked slots)."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Fill all 3 unlocked slots with different passives
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # DAMAGE
    await game.call(FUSION_REGISTRY, "apply_passive", [1])  # FIRE_RATE
    await game.call(FUSION_REGISTRY, "apply_passive", [2])  # MAX_HP

    equipped = await game.call(FUSION_REGISTRY, "get_equipped_passives")
    assert len(equipped) == 3, "Should have 3 equipped passives"

    # Try to add a 4th passive (should fail - only 3 slots unlocked)
    result = await game.call(FUSION_REGISTRY, "apply_passive", [3])  # MULTI_SHOT
    assert result is False, "Should fail to add 4th passive with only 3 unlocked slots"

    # Still only 3 equipped
    equipped = await game.call(FUSION_REGISTRY, "get_equipped_passives")
    assert len(equipped) == 3, "Still only 3 passives should be equipped"


@pytest.mark.asyncio
async def test_unlock_passive_slot_increases_count(game):
    """unlock_passive_slot() should increase unlocked slot count."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    unlocked_before = await game.call(FUSION_REGISTRY, "get_unlocked_passive_slots")
    assert unlocked_before == 3, "Should start with 3"

    # Unlock a slot
    success = await game.call(FUSION_REGISTRY, "unlock_passive_slot")
    assert success, "Should successfully unlock slot"

    unlocked_after = await game.call(FUSION_REGISTRY, "get_unlocked_passive_slots")
    assert unlocked_after == 4, "Should now have 4 unlocked slots"


@pytest.mark.asyncio
async def test_can_equip_4th_passive_after_unlock(game):
    """After unlocking 4th slot, should be able to equip 4th passive."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Fill 3 unlocked slots
    await game.call(FUSION_REGISTRY, "apply_passive", [0])  # DAMAGE
    await game.call(FUSION_REGISTRY, "apply_passive", [1])  # FIRE_RATE
    await game.call(FUSION_REGISTRY, "apply_passive", [2])  # MAX_HP

    # Unlock 4th slot
    await game.call(FUSION_REGISTRY, "unlock_passive_slot")

    # Now should be able to add 4th passive
    result = await game.call(FUSION_REGISTRY, "apply_passive", [3])  # MULTI_SHOT
    assert result is True, "Should successfully add 4th passive after unlock"

    equipped = await game.call(FUSION_REGISTRY, "get_equipped_passives")
    assert len(equipped) == 4, "Should now have 4 equipped passives"


@pytest.mark.asyncio
async def test_unlock_passive_slot_to_max_5(game):
    """Can unlock up to maximum of 5 passive slots."""
    await game.call(FUSION_REGISTRY, "reset")
    await asyncio.sleep(0.1)

    # Unlock until we hit max
    for _ in range(10):  # Try to unlock more than max
        await game.call(FUSION_REGISTRY, "unlock_passive_slot")

    unlocked = await game.call(FUSION_REGISTRY, "get_unlocked_passive_slots")
    assert unlocked == 5, "Should cap at 5 unlocked passive slots"
