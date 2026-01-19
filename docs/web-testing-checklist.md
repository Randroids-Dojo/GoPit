# Web Export Testing Checklist

Manual testing guide for verifying GoPit works correctly in web browsers.

## Quick Start

```bash
# Build and serve locally
./verify_web_export.sh --serve

# Or if already built, just serve
cd build && python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser.

> **Note:** You MUST use a local server. Opening `index.html` directly will fail due to CORS restrictions.

## Browser Compatibility

Test in all major browsers. Priority order based on user base:

| Browser | Priority | Known Issues |
|---------|----------|--------------|
| Chrome (Desktop) | High | None |
| Safari (iOS) | High | Audio autoplay restrictions |
| Chrome (Android) | High | None |
| Safari (Desktop) | Medium | Audio autoplay restrictions |
| Firefox (Desktop) | Medium | None |
| Edge | Low | None |

## Pre-Test Setup

Before testing, clear browser cache to ensure fresh load:

- **Chrome**: Cmd+Shift+Delete (Mac) / Ctrl+Shift+Delete (Windows)
- **Safari**: Develop > Empty Caches (enable Develop menu in Preferences)
- **Firefox**: Cmd+Shift+Delete (Mac) / Ctrl+Shift+Delete (Windows)

## Test Checklist

### 1. Game Loading

- [ ] Loading screen appears with progress indicator
- [ ] Game loads within 10 seconds on broadband
- [ ] No JavaScript errors in browser console
- [ ] Canvas displays correctly (no black screen)
- [ ] Aspect ratio is correct (portrait orientation)

### 2. Audio

- [ ] Background music plays (may require first interaction)
- [ ] Sound effects play when firing
- [ ] Sound effects play when enemies are hit
- [ ] Sound effects play when collecting gems
- [ ] Level-up sound plays
- [ ] Game over sound plays
- [ ] Mute button (M key) toggles all audio

> **Browser Autoplay Note:** Most browsers block audio until user interaction. The game should start silent and enable audio after first click/tap.

### 3. Touch Controls (Mobile/Tablet)

- [ ] Virtual joystick appears on left side
- [ ] Joystick responds to touch drag
- [ ] Fire button appears on right side
- [ ] Fire button triggers ball spawn on tap
- [ ] Aim joystick adjusts firing angle
- [ ] Autofire toggle works
- [ ] No accidental zooming or scrolling during gameplay
- [ ] Multi-touch works (move + fire simultaneously)

### 4. Keyboard Controls (Desktop)

- [ ] WASD moves player (if applicable)
- [ ] Arrow keys aim
- [ ] Space fires
- [ ] Tab toggles autofire
- [ ] E activates ultimate (if available)
- [ ] Escape pauses game
- [ ] M mutes audio

### 5. Gameplay Mechanics

- [ ] Balls spawn when firing
- [ ] Balls travel in aimed direction
- [ ] Balls collide with and damage enemies
- [ ] Enemies spawn from top of screen
- [ ] Enemies descend toward player
- [ ] Enemies take damage and die
- [ ] Gems drop from defeated enemies
- [ ] Gems can be collected
- [ ] XP bar fills when collecting gems
- [ ] Level-up triggers upgrade selection

### 6. UI Elements

- [ ] HUD displays correctly (health, XP, wave)
- [ ] Pause menu appears on Escape/pause button
- [ ] Level-up overlay shows upgrade choices
- [ ] Game over overlay appears when player dies
- [ ] Restart button works
- [ ] All text is readable (not cut off or too small)

### 7. Performance

- [ ] 60 FPS during normal gameplay
- [ ] No significant frame drops during intense combat
- [ ] Memory usage stable over time (no leaks)
- [ ] No stuttering during level transitions

To check performance:
1. Open browser DevTools (F12)
2. Go to Performance tab
3. Record during gameplay
4. Look for frame drops (should stay near 60fps)

### 8. Session Persistence

- [ ] Game state resets properly on restart
- [ ] No stale data from previous sessions
- [ ] Browser refresh returns to start screen

### 9. Cross-Origin Headers (Technical)

For SharedArrayBuffer support (multithreading):

1. Open DevTools Network tab
2. Refresh the page
3. Click on `index.html` request
4. Verify response headers include:
   - `Cross-Origin-Opener-Policy: same-origin`
   - `Cross-Origin-Embedder-Policy: require-corp`

## Known Issues

### Audio Autoplay Restrictions

**Symptom:** No audio plays when game starts.

**Cause:** Modern browsers block autoplay of audio until user interaction.

**Workaround:** This is expected behavior. Audio should start after first tap/click.

### iOS Safari Memory Limits

**Symptom:** Game crashes or reloads on iOS Safari.

**Cause:** iOS Safari has stricter memory limits than desktop browsers.

**Workaround:** Ensure textures are optimized and not excessively large.

### Firefox WebGL Context Loss

**Symptom:** Black screen after being in background for extended period.

**Cause:** Firefox may lose WebGL context when tab is backgrounded.

**Workaround:** Refresh the page to restore context.

## Reporting Issues

When reporting web-specific issues, include:

1. **Browser and version** (e.g., Chrome 120.0.6099.109)
2. **Operating system** (e.g., macOS 14.2, iOS 17.2)
3. **Device** (e.g., iPhone 15, MacBook Pro M1)
4. **Console errors** (screenshot of browser DevTools console)
5. **Steps to reproduce**
6. **Expected vs actual behavior**

## CI/CD Verification

Web export is automatically verified in CI:

1. **Build job** runs `godot --headless --export-release "Web"`
2. **Artifact** uploaded for inspection
3. **PR Preview** deployed to Vercel for testing
4. **Production** deployed on merge to main

See `.github/workflows/ci.yml` for implementation details.

## Resources

- [Godot Web Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Web Export Troubleshooting](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#troubleshooting)
- [Browser Autoplay Policy](https://developer.chrome.com/blog/autoplay/)
