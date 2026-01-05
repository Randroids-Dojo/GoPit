"""Tests for UI overlay mouse_filter settings.

Ensures overlay UI elements don't accidentally block input to elements underneath.
Control nodes default to MOUSE_FILTER_STOP which captures all input events.
Overlay elements should use MOUSE_FILTER_IGNORE (2) to let events pass through.
"""
import pytest

# mouse_filter enum values
MOUSE_FILTER_STOP = 0    # Captures events, blocks pass-through (DEFAULT)
MOUSE_FILTER_PASS = 1    # Receives events AND passes to nodes below
MOUSE_FILTER_IGNORE = 2  # Ignores events, passes to nodes below

TUTORIAL_OVERLAY = "/root/Game/TutorialOverlay"
DIM_BACKGROUND = "/root/Game/TutorialOverlay/DimBackground"
HIGHLIGHT_RING = "/root/Game/TutorialOverlay/DimBackground/HighlightRing"
HINT_LABEL = "/root/Game/TutorialOverlay/DimBackground/HintLabel"
RING = "/root/Game/TutorialOverlay/DimBackground/HighlightRing/Ring"


@pytest.mark.asyncio
async def test_tutorial_overlay_mouse_filter(game):
    """Verify tutorial overlay Control nodes don't block input.

    The tutorial overlay positions a highlight ring over interactive elements
    (joystick, fire button). If any Control nodes in the overlay have
    mouse_filter = MOUSE_FILTER_STOP (0), they will capture touch/click events
    and prevent the underlying buttons from working.

    This test caught a bug where HighlightRing was blocking the fire button on mobile.
    """
    # Check if tutorial overlay exists (it may have been dismissed/freed)
    exists = await game.node_exists(TUTORIAL_OVERLAY)
    if not exists:
        pytest.skip("Tutorial overlay not present (may have been completed)")

    # Check each overlay node that should pass through input
    nodes_to_check = [
        (DIM_BACKGROUND, "DimBackground"),
        (HIGHLIGHT_RING, "HighlightRing"),
        (RING, "Ring"),
    ]

    blocking_nodes = []
    for path, name in nodes_to_check:
        if not await game.node_exists(path):
            continue

        mouse_filter = await game.get_property(path, "mouse_filter")

        # If mouse_filter is STOP (0), this node will block input
        if mouse_filter == MOUSE_FILTER_STOP:
            blocking_nodes.append(f"{name} ({path})")

    assert len(blocking_nodes) == 0, (
        f"Tutorial overlay has Control nodes with mouse_filter=STOP that will block input:\n"
        + "\n".join(f"  - {node}" for node in blocking_nodes)
        + "\n\nFix: Set mouse_filter = 2 (MOUSE_FILTER_IGNORE) on these nodes in the .tscn file"
    )


@pytest.mark.asyncio
async def test_highlight_ring_passes_input(game):
    """Verify the highlight ring doesn't block input to fire button.

    This is the specific regression test for the bug where HighlightRing
    was blocking the fire button during the FIRE tutorial step.
    """
    exists = await game.node_exists(HIGHLIGHT_RING)
    if not exists:
        pytest.skip("Tutorial overlay not present")

    mouse_filter = await game.get_property(HIGHLIGHT_RING, "mouse_filter")

    assert mouse_filter == MOUSE_FILTER_IGNORE, (
        f"HighlightRing has mouse_filter={mouse_filter}, expected MOUSE_FILTER_IGNORE (2). "
        "This blocks touch events from reaching the fire button underneath."
    )


@pytest.mark.asyncio
async def test_dim_background_passes_input(game):
    """Verify the dim background doesn't block input."""
    exists = await game.node_exists(DIM_BACKGROUND)
    if not exists:
        pytest.skip("Tutorial overlay not present")

    mouse_filter = await game.get_property(DIM_BACKGROUND, "mouse_filter")

    assert mouse_filter == MOUSE_FILTER_IGNORE, (
        f"DimBackground has mouse_filter={mouse_filter}, expected MOUSE_FILTER_IGNORE (2). "
        "This will block all input to the game underneath."
    )
